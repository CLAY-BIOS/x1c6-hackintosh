//
// SSDT-BATX
// Version 2.0
//
// Copyleft (c) 2020 by bb. No rights reserved.
//
//
// Abstract:
// This SSDT is a complete, (mostly) self-contained replacement for all(?) battery-patches on Thinkpads which share
// the same EC-layout. It should be compatible with all(?) T- and X-series Thinkpads and maybe more.
//
// It doesn't need any patches to the original DSDT, handles single- and dual-battery-systems gracefully and adds
// support for `Battery Information Supplement` (see: https://github.com/acidanthera/VirtualSMC/blob/master/Docs/Battery%20Information%20Supplement.md)
//
// It is faster, more compatbile and much more robust than existing patches as it doesn't relie on the original DSDT-implementation 
// for battery-handling and EC-access. It therefor doesn't need to patch the existing DSDT-accesses to various 16-bit EC-fields.
//
// It's only dependencies are the memory-layout of the Embedded Controller (EC), which is mostly the same for all modern thinkpads and 3 helper methods 
// to access those memory-fields. These methods are not included as they are used in multiple places (f.e. by YogaSMC) but can be found in SSDT-EC.dsl.
//
// It replaces any batterie-related DSDT-patches and any SSDT like SSDT-BAT0, SSDT-BATT, SSDT-BATC, SSDT-BATN and similar.
//
// For most thinkpads, this should be the only thing you need to handle your batteries. Nothing more, nothing less.
//
// But be aware: this is newly created stuff, not much tested or battle proven yet. May contain bugs and edgecases. 
// If so, please open a bug @ https://github.com/benbender/x1c6-hackintosh/issues
//
// 
// References:
// https://github.com/coreboot/coreboot/blob/master/src/ec/quanta/it8518/acpi/ec.asl
// https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf
// https://github.com/acidanthera/VirtualSMC/blob/master/Docs/Battery%20Information%20Supplement.md
//
//
// Changelog:
// 23.10. - Raised timeout for mutexes, factored bank-switching out, added sleep to bank-switching, moved HWAC to its own SSDT
// 25.10. - Prelimitary dual-battery-support, large refactoring
// 26.10. - Remove need of patched notifies, handle battery attach/detach inside, make the whole device self-contained (exept for the EC-helpers)
// 28.10. - Waits on initialization of the batts now. Besides that: Optimization, rework, cleanup, fixes. Truely self-contained now. And faster. 
//
// Add the following methods if didn't have them defined anyways:
DefinitionBlock ("", "SSDT", 2, "X1C6", "_BATX", 0x00001000)
{
    External (_SB.PCI0.LPCB.EC, DeviceObj)
    External (_SB.PCI0.LPCB.EC.BATM, MutexObj)
    
    External (_SB.PCI0.LPCB.EC.BAT0, DeviceObj)
    External (_SB.PCI0.LPCB.EC.BAT0._STA, MethodObj)
    External (_SB.PCI0.LPCB.EC.BAT0._HID, IntObj)

    External (_SB.PCI0.LPCB.EC.BAT1, DeviceObj)
    External (_SB.PCI0.LPCB.EC.BAT1._STA, MethodObj)
    External (_SB.PCI0.LPCB.EC.BAT1._HID, IntObj)

    // @see https://en.wikipedia.org/wiki/Bank_switching
    //
    // HIID: [Battery information ID for 0xA0-0xAF]
    //   (this byte is depend on the interface, 62&66 and 1600&1604)
    External (_SB.PCI0.LPCB.EC.HIID, FieldUnitObj)

    External (H8DR, FieldUnitObj)


    Scope (\_SB.PCI0.LPCB.EC)
    {
        //
        // EC region overlay.
        //
        OperationRegion (BRAM, EmbeddedControl, 0x00, 0x0100)

        /**
         * New battery device
         */
        Device (BATX)
        {
            Name (BDBG, One)

            /* Battery Capacity warning at 25% */
            Name (DWRN, 25)

            /* Battery Capacity low at 20% */
            Name (DLOW, 20)


            Field(BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset (0x38),
                            // HB0S: [Battery 0 status (read only)]
                            //   bit 3-0 level
                            //     F: Unknown
                            //     2-n: battery level
                            //     1: low level
                            //     0: (critical low battery, suspend/ hibernate)
                            //   bit 4 error
                            //   bit 5 charge
                            //   bit 6 discharge
                HB0S, 7,    /* Battery 0 state */
                HB0A, 1,    /* Battery 0 present */
                
                Offset (0x39),
                HB1S, 7,    /* Battery 1 state */
                HB1A, 1,    /* Battery 1 present */

                Offset (0xC9), 
                HWAT, 8,    /* Wattage of AC/DC */

                // Zero on the X1C6. Probably because of the charging is handled by the TI USB-C-PD-chip.
                // Offset (0xCC), 
                // PWMH, 8,    /* CC : AC Power Consumption (MSB) */
                // PWML, 8,    /* CD : AC Power Consumption (LSB) - unit: 100mW */
            }

            //
            // EC Registers 
            // HIID == 0x00
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                // SBRC, 16,    // Remaining Capacity
                RC00,   8,
                RC01,   8,
                // SBFC, 16,    // Fully Charged Capacity
                FC00,   8,
                FC01,   8,
                // SBAE, 16,    // Average Time To Empty
                AE00,   8,
                AE01,   8,
                // SBRS, 16,    // Relative State Of Charge
                RS00,   8,
                RS01,   8,
                // SBAC, 16,    // Average Current / present rate
                AC00,   8,
                AC01,   8,
                // SBVO, 16,    // Voltage
                VO00,   8,
                VO01,   8,
                // SBAF, 16,    // Average Time To Full
                AF00,   8,
                AF01,   8,
                // SBBS, 16,    // Battery State
                BS00,   8,
                BS01,   8,
            }

            //
            // EC Registers 
            // HIID == 0x01
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                                // Battery Mode(w)
                    , 15,
                SBCM, 1,        //  bit 15 - CAPACITY_MODE
                                //   0: Report in mA/mAh ; 1: Enabled
                // SBMD, 16,    // Manufacture Data
                MD00,   8,
                MD01,   8,
                // SBCC, 16,    // Cycle Count
                CC00,   8,
                CC01,   8,
            }

            //
            // EC Registers 
            // HIID == 0x02
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                // SBDC, 16,    // Design Capacity
                DC00,   8,
                DC01,   8,
                // SBDV, 16,    // Design Voltage
                DV00,   8,
                DV01,   8,
                // SBOM, 16,    // Optional Mfg Function 1
                OM00,   8,
                OM01,   8,
                // SBSI, 16,    // Specification Info
                SI00,   8,
                SI01,   8,
                // SBDT, 16,    // Manufacture Date
                DT00,   8,
                DT01,   8,
                // SBSN, 16,    // Serial Number
                SN00,   8,
                SN01,   8,
            }

            //
            // EC Registers 
            // HIID == 0x04: Battery type
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                // SBCH, 32,    // Device Checmistory (string)
                CH00,    8,
                CH01,    8,
                CH02,    8,
                CH03,    8
            }

            //
            // EC Registers 
            // HIID == 0x05: Battery OEM information
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                // SBMN, 128,   // Manufacture Name (s)
                MN00,   8,
                MN01,   8,
                MN02,   8,
                MN03,   8,
                MN04,   8,
                MN05,   8,
                MN06,   8,
                MN07,   8,
                MN08,   8,
                MN09,   8,
                MN0A,   8,
                MN0B,   8,
                MN0C,   8,
                MN0D,   8,
                MN0E,   8,
                MN0F,   8,
            }

            //
            // EC Registers 
            // HIID == 0x06: Battery name
            //
            Field (BRAM, ByteAcc, NoLock, Preserve)
            {
                Offset(0xA0),
                // SBDN, 128,   // Device Name (s)
                DN00,   8,
                DN01,   8,
                DN02,   8,
                DN03,   8,
                DN04,   8,
                DN05,   8,
                DN06,   8,
                DN07,   8,
                DN08,   8,
                DN09,   8,
                DN0A,   8,
                DN0B,   8,
                DN0C,   8,
                DN0D,   8,
                DN0E,   8,
                DN0F,   8,
            }

            /**
             * Method to read 128byte-field SBMN 
             */
            Method (SBMN, 1, Serialized)
            {
                //
                // Information Page 5 -
                //
                BPAG (Arg0 | 0x05)

                Local0 = Buffer (0x10) {}

                Local0[0x00] = MN00
                Local0[0x01] = MN01
                Local0[0x02] = MN02
                Local0[0x03] = MN03
                Local0[0x04] = MN04
                Local0[0x05] = MN05
                Local0[0x06] = MN06
                Local0[0x07] = MN07
                Local0[0x08] = MN08
                Local0[0x09] = MN09
                Local0[0x0A] = MN0A
                Local0[0x0B] = MN0B
                Local0[0x0C] = MN0C
                Local0[0x0D] = MN0D
                Local0[0x0E] = MN0E
                Local0[0x0F] = MN0F

                Return (Local0)
            }

            /**
             * Method to read 128byte-field SBDN
             */
            Method (SBDN, 1, Serialized)
            {
                //
                // Information Page 6 -
                //
                BPAG (Arg0 | 0x06)
                
                Local0 = Buffer (0x10) {}

                Local0[0x00] = DN00
                Local0[0x01] = DN01
                Local0[0x02] = DN02
                Local0[0x03] = DN03
                Local0[0x04] = DN04
                Local0[0x05] = DN05
                Local0[0x06] = DN06
                Local0[0x07] = DN07
                Local0[0x08] = DN08
                Local0[0x09] = DN09
                Local0[0x0A] = DN0A
                Local0[0x0B] = DN0B
                Local0[0x0C] = DN0C
                Local0[0x0D] = DN0D
                Local0[0x0E] = DN0E
                Local0[0x0F] = DN0F

                Return (Local0)
            }

            /**
             * Switches the battery information page (16 bytes BRAM @0xa0) with an
             * optional compile-time delay.
             *
             * Arg0:
             *   bit7-4: Battery number
             *   bit3-0: Information page number
             */
            Method (BPAG, 1, Serialized)
            {
                HIID = Arg0

                Sleep (50)
            }

            /**
             * Status from two EC fields
             * 
             * e.g. B1B2 (0x3A, 0x03) -> 0x033A
             */
            Method (B1B2, 2, Serialized)
            {
                Return ((Arg0 | (Arg1 << 0x08)))
            }

            /**
             * Status from four EC fields
             */
            Method (B1B4, 4, Serialized)
            {
                Local0 = (Arg2 | (Arg3 << 0x08))
                Local0 = (Arg1 | (Local0 << 0x08))
                Local0 = (Arg0 | (Local0 << 0x08))

                Return (Local0)
            }


            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB
            })

            /**
             * Battery Slot Status
             */
            Method (_STA, 0, NotSerialized)
            {
                // call original _STA for BAT0 and BAT1
                // result is bitwise OR between them
                If (_OSI ("Darwin"))
                {
                    If (CondRefOf (^^BAT0))
                    {
                        Local0 = ^^BAT0._STA()
                    }

                    If (CondRefOf (^^BAT1))
                    {
                        Local1 = ^^BAT1._STA()

                        Return (Local0 | Local1)
                    }
                    Else
                    {
                        Return (Local0)
                    }
                }

                Return (Zero)
            }

            Method (_INI, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    If (CondRefOf (^^BAT0))
                    {
                        // disable original battery objects by setting invalid _HID
                        ^^BAT0._HID = 0
                    }

                    If (CondRefOf (^^BAT1))
                    {
                        // disable original battery objects by setting invalid _HID
                        ^^BAT1._HID = 0
                    }
                }
            }

            /**
             *  Extended Battery Static Information pack layout
             */
            Name (PBIX, Package () {
                0x01,        // 0x00: BIXRevision - Revision - Integer
                0x01,        // 0x01: BIXPowerUnit - Power Unit: mAh - Integer (DWORD)
                             //       ACPI spec     : 0 - mWh   : 1 - mAh                
                             //       We are always outputting mAh.
                0xFFFFFFFF,  // 0x02: BIXDesignCapacity - Design Capacity - Integer (DWORD)
                0xFFFFFFFF,  // 0x03: BIXLastFullChargeCapacity - Last Full Charge Capacity - Integer (DWORD)
                0x01      ,  // 0x04: BIXBatteryTechnology - Battery Technology: Rechargeable - Integer (DWORD)
                10800,       // 0x05: BIXDesignVoltage - Design Voltage - Integer (DWORD)
                0x000000FA,  // 0x06: BIXDesignCapacityOfWarning - Design Capacity of Warning - Integer (DWORD)
                0x00000064,  // 0x07: BIXDesignCapacityOfLow - Design Capacity of Low - Integer (DWORD)
                0xFFFFFFFF,  // 0x08: BIXCycleCount - Cycle Count - Integer (DWORD)
                0x00017318,  // 0x09: BIXMeasurementAccuracy - Measurement Accuracy (98.3%?) - Integer (DWORD)
                500,         // 0x0a: BIXMaxSamplingTime - Max Sampling Time (500ms) - Integer (DWORD)
                10,          // 0x0b: BIXMinSamplingTime - Min Sampling Time (10ms) - Integer (DWORD)
                5000,        // 0x0c: BIXMaxAveragingInterval - Max Averaging Interval - Integer (DWORD)
                500,         // 0x0d: BIXMinAveragingInterval - Min Averaging Interval - Integer (DWORD)
                0x1,         // 0x0e: BIXBatteryCapacityGranularity1 - Capacity Granularity 1
                0x1,         // 0x0f: BIXBatteryCapacityGranularity2 - Capacity Granularity 2
                " ",         // 0x10: BIXModelNumber - Model Number - String
                " ",         // 0x11: BIXSerialNumber - Serial Number - String
                " ",         // 0x12: BIXBatteryType - Battery Type - String
                " ",         // 0x13: BIXOEMInformation - OEM Information - String
                0x00000000   // 0x14: ??? - Battery Swapping Capability, 0x00000000 = non-swappable - Integer (DWORD)
                             //       added in Revision 1: Zero means Non-swappable, One ? Cold-swappable, 0x10 ? Hot-swappable
            })

            Method (GBIX, 2, Serialized)
            {
                If (Acquire (^^BATM, 65535))
                {
                    Debug = "BATX:AcquireLock failed in GBIX"

                    Return (Arg0)
                }


                //
                // Information Page 1 -
                //
                BPAG (Arg1 | 0x01) 

                // Needs conversion to mA/mAh?
                Local7 = (SBCM ^ Zero)

                //  Cycle count
                Arg0[0x08] = B1B2 (CC00, CC01)


                //
                // Information Page 2 -
                //
                BPAG (Arg1 | 0x02)

                // Design voltage
                Local6 = B1B2 (DV00, DV01)

                Arg0[0x05] = Local6

                // Serial Number
                Arg0[0x11] = B1B2 (SN00, SN01)

                // Design capacity
                If (Local7)
                {
                    Local0 = 1000 * B1B2 (DC00, DC01) / Local6
                }
                Else
                {
                    Local0 = B1B2 (DC00, DC01)
                }

                Arg0[0x02] = Local0

                // Design capacity of High
                Arg0[0x06] = Local0 / 100 * DWRN

                // Design capacity of Low 
                Arg0[0x07] = Local0 / 100 * DLOW


                //
                // Information Page 0 -
                //
                BPAG (Arg1 | 0x00)

                // Last Full Charge Capacity
                If (Local7)
                {
                    Arg0[0x03] = 1000 * B1B2 (FC00, FC01) / Local6
                }
                Else
                {
                    Arg0[0x03] = B1B2 (FC00, FC01)
                }


                //
                // Information Page 4 -
                //
                BPAG (Arg1 | 0x04)

                // Battery Type - Device Chemistry
                Arg0[0x12] = B1B4 (CH00, CH01, CH02, CH03)

                // OEM Information - Manufacturer Name
                Arg0[0x13] = SBMN (0x00)

                // Model Number - Device Name
                Arg0[0x10] = SBDN (0x00)

                Release (^^BATM)

                Return (Arg0)
            }

            /**
             * Acpi-Spec:
             * 10.2.2.2 _BIX (Battery Information Extended)
             * The _BIX object returns the static portion of the Control Method Battery information. This information
             * remains constant until the battery is changed. The _BIX object returns all information available via the
             * _BIF object plus additional battery information. The _BIF object is deprecated in lieu of _BIX in ACPI 4.0
             */
            Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
            {
                Debug = "BATX:_BIX"

                // Wait for the battery to become available
                Local7 = 0x00
                Local6 = 30

                While ((!Local7 && Local6))
                {
                    If (HB0A)
                    {
                        If (((HB0S & 0x07) == 0x07))
                        {
                            Sleep (1000)
                            Local6--
                        }
                        Else
                        {
                            Local7 = 0x01
                        }
                    }
                    Else
                    {
                        Local6 = 0x00
                    }
                }

                // Fetch data
                Local0 = PBIX

                If (HB0A) 
                {
                    Local0 = GBIX (Local0, 0x00)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BIXPowerUnit: BAT0 ", Local0[0x01], Debug)
                        Concatenate ("BATX:BIXDesignCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BIXLastFullChargeCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                        Concatenate ("BATX:BIXBatteryTechnology: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x04))), Debug)
                        Concatenate ("BATX:BIXDesignVoltage: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x05))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfWarning: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x06))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfLow: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x07))), Debug)
                        Concatenate ("BATX:BIXCycleCount: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x08))), Debug)
                        Concatenate ("BATX:BIXModelNumber: BAT0 ", Local0[0x10], Debug)
                        Concatenate ("BATX:BIXSerialNumber: BAT0 ", Local0[0x11], Debug)
                        Concatenate ("BATX:BIXBatteryType: BAT0 ", Local0[0x12], Debug)
                        Concatenate ("BATX:BIXOEMInformation: BAT0 ", Local0[0x13], Debug)
                    }
                } 

                Local1 = PBIX

                If (HB1A) 
                {
                    Local1 = GBIX (Local1, 0x10)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BIXPowerUnit: BAT1 ", Local1[0x01], Debug)
                        Concatenate ("BATX:BIXDesignCapacity: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x02))), Debug)
                        Concatenate ("BATX:BIXLastFullChargeCapacity: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x03))), Debug)
                        Concatenate ("BATX:BIXBatteryTechnology: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x04))), Debug)
                        Concatenate ("BATX:BIXDesignVoltage: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x05))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfWarning: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x06))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfLow: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x07))), Debug)
                        Concatenate ("BATX:BIXCycleCount: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x08))), Debug)
                        Concatenate ("BATX:BIXModelNumber: BAT1 ", Local1[0x10], Debug)
                        Concatenate ("BATX:BIXSerialNumber: BAT1 ", Local1[0x11], Debug)
                        Concatenate ("BATX:BIXBatteryType: BAT1 ", Local1[0x12], Debug)
                        Concatenate ("BATX:BIXOEMInformation: BAT1 ", Local1[0x13], Debug)
                    }
                }

                If (HB0A && HB1A)
                {
                    PBIX = Local0

                    // _BIX 0 Revision - leave BAT0 value
                    // _BIX 1 Power Unit - leave BAT0 value
                    // _BIX 2 Design Capacity - add BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x02])
                    Local5 = DerefOf (Local1[0x02])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x02] = Local4 + Local5
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 3 Last Full Charge Capacity - add BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x03])
                    Local5 = DerefOf (Local1[0x03])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x03] = Local4 + Local5
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 4 Battery Technology - leave BAT0 value
                    // _BIX 5 Design Voltage - average between BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x05])
                    Local5 = DerefOf (Local1[0x05])
 
                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x05] = (Local4 + Local5) / 2
                    }

                    // _BIX 6 Design Capacity of Warning - add BAT0 and BAT1 values
                    PBIX[0x06] = DerefOf (Local0[0x06]) + DerefOf (Local1[0x06])

                    // _BIX 7 Design Capacity of Low - add BAT0 and BAT1 values
                    PBIX[0x07] = DerefOf (Local0[0x07]) + DerefOf (Local1[0x07])

                    // _BIX 8 Cycle Count - average between BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x08])
                    Local5 = DerefOf (Local1[0x08])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x08] = (Local4 + Local5) / 2
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 9 Measurement Accuracy - average between BAT0 and BAT1 values
                    PBIX[0x09] = (DerefOf (Local0[0x09]) + DerefOf (Local1[0x09])) / 2

                    // _BIX 0xa Max Sampling Time - average between BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x0a])
                    Local5 = DerefOf (Local1[0x0a])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x0a] = (Local4 + Local5) / 2
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 0xb Min Sampling Time - average between BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x0b])
                    Local5 = DerefOf (Local1[0x0b])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x0b] = (Local4 + Local5) / 2
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 0xc Max Averaging Interval - average between BAT0 and BAT1 values
                    PBIX[0x0c] = (DerefOf (Local0[0x0c]) + DerefOf (Local1 [0x0c])) / 2

                    // _BIX 0xd Min Averaging Interval - average between BAT0 and BAT1 values
                    PBIX[0x0d] = (DerefOf (Local0[0x0d]) + DerefOf (Local1 [0x0d])) / 2

                    // _BIX 0xe Battery Capacity Granularity 1 - add BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x0e])
                    Local5 = DerefOf (Local1[0x0e])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x0e] = Local4 + Local5
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 0xf Battery Capacity Granularity 2 - add BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x0f])
                    Local5 = DerefOf (Local1[0x0f])

                    If (0xffffffff != Local4 && 0xffffffff != Local5)
                    {
                        PBIX[0x0f] = Local4 + Local5
                    }
                    ElseIf (0xffffffff != Local5)
                    {
                        PBIX[0x08] = Local5
                    }

                    // _BIX 10 Model Number - concatenate BAT0 and BAT1 values
                    PBIX[0x10] = Concatenate (Concatenate (DerefOf (Local0[0x10]), " / "), DerefOf (Local1[0x10]))

                    // _BIX 11 Serial Number - concatenate BAT0 and BAT1 values
                    PBIX[0x11] = Concatenate (Concatenate (DerefOf (Local0[0x11]), " / "), DerefOf (Local1[0x11]))

                    // _BIX 12 Battery Type - concatenate BAT0 and BAT1 values
                    PBIX[0x12] = Concatenate (Concatenate (DerefOf (Local0[0x12]), " / "), DerefOf (Local1[0x12]))

                    // _BIX 13 OEM Information - concatenate BAT0 and BAT1 values
                    PBIX[0x13] = Concatenate (Concatenate (DerefOf (Local0[0x13]), " / "), DerefOf (Local1[0x13]))

                    // _BIX 14 Battery Swapping Capability - leave BAT0 value for now
                }
                ElseIf (!HB0A && HB1A)
                {
                    PBIX = Local1
                }
                Else
                {
                    PBIX = Local0
                }

                If (BDBG == One)
                {
                    // Concatenate ("BATX:BIXRevision: BATX ", PBIX[0x00], Debug)
                    Concatenate ("BATX:BIXPowerUnit: BATX ", PBIX[0x01], Debug)
                    Concatenate ("BATX:BIXDesignCapacity: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x02))), Debug)
                    Concatenate ("BATX:BIXLastFullChargeCapacity: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x03))), Debug)
                    Concatenate ("BATX:BIXBatteryTechnology: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x04))), Debug)
                    Concatenate ("BATX:BIXDesignVoltage: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x05))), Debug)
                    Concatenate ("BATX:BIXDesignCapacityOfWarning: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x06))), Debug)
                    Concatenate ("BATX:BIXDesignCapacityOfLow: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x07))), Debug)
                    Concatenate ("BATX:BIXCycleCount: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x08))), Debug)
                    Concatenate ("BATX:BIXModelNumber: BATX ", PBIX[0x10], Debug)
                    Concatenate ("BATX:BIXSerialNumber: BATX ", PBIX[0x11], Debug)
                    Concatenate ("BATX:BIXBatteryType: BATX ", PBIX[0x12], Debug)
                    Concatenate ("BATX:BIXOEMInformation: BATX ", PBIX[0x13], Debug)
                }

                Return (PBIX)
            }

            /**
             *  Battery Information Supplement pack layout
             */
            Name (PBIS, Package (0x08)
            {
                0x007F007F,  // 0x00: BISConfig - config, double check if you have valid AverageRate before
                             //       fliping that bit to 0x007F007F since it will disable quickPoll
                0xFFFFFFFF,  // 0x01: BISManufactureDate - ManufactureDate (0x1), AppleSmartBattery format
                0x00002342,  // 0x02: BISPackLotCode - PackLotCode 
                0x00002342,  // 0x03: BISPCBLotCode - PCBLotCode
                0x00002342,  // 0x04: BISFirmwareVersion - FirmwareVersion
                0x00002342,  // 0x05: BISHardwareVersion - HardwareVersion
                0x00002342,  // 0x06: BISBatteryVersion - BatteryVersion 
                0xFFFFFFFF,
            })

            /**
             *  Battery Information Supplement 
             */
            Method (CBIS, 0, Serialized)
            {
                Debug = "BATX:CBIS()"

                If (!H8DR)
                {
                    Return (PBIS)
                }

                If (Acquire (^^BATM, 65535))
                {
                    Debug = "BATX:AcquireLock failed in CBIS"

                    Return (PBIS)
                }


                //
                // Information Page 2 -
                //
                BPAG (0x00 | 0x02)

                // 0x01: ManufactureDate (0x1), AppleSmartBattery format
                PBIS[0x01] = B1B2 (DT00, DT01)

                Release (^^BATM)

                Return (PBIS)
            }

            /**
             *  Battery Real-time Information pack layout
             */
            Name (PBST, Package ()
            {
                0x00000000,  // 0x00: BSTState - Battery State
                             //       Bit 0 - discharge
                             //       Bit 1 - charge
                             //       Bit 2 - critical state
                0,           // 0x01: BSTPresentRate - Battery Present Rate [mW], 0xFFFFFFFF if unknown rate
                0,           // 0x02: BSTRemainingCapacity - Battery Remaining Capacity [mWh], 0xFFFFFFFF if unknown capacity
                0,           // 0x03: BSTPresentVoltage - Battery Present Voltage [mV], 0xFFFFFFFF if unknown voltage
            })

            /**
             * Get Battery Status per battery
             *
             * Arg0: Battery Real-time Information pack
             * Arg1: Battery id 0x00 / 0x10
             * Arg2: Battery EC status
             */
            Method (GBST, 3, Serialized)
            {
                If (Acquire (^^BATM, 65535))
                {
                    Debug = "BATX:AcquireLock failed in GBST"

                    Return (Arg0)
                }


                //
                // Information Page 1 -
                //
                BPAG (Arg1 | 0x01) 

                // Needs conversion to mA/mAh?
               Local7 = (SBCM ^ Zero)


                //
                // Information Page 0 -
                //
                BPAG (Arg1 | 0x00) /* Battery dynamic information */

                // get voltage for conversion
                Local6 = B1B2 (VO00, VO01)

                // Present rate is a 16bit signed int, positive while charging
                // and negative while discharging.
                Local1 = B1B2 (AC00, AC01)


                //
                // 0: BATTERY STATE
                //
                // bit 0 = discharging
                // bit 1 = charging
                // bit 2 = critical level
                //
                Local0 = 0

                // Get battery state from EC
                If (Arg2 & 0x20) // Charging
                {
                    // 2 = charging
                    Local0 = 0x02
                }
                Else
                {
                    If (Arg2 & 0x40) // Discharging
                    {
                        // 1 = discharging
                        Local0 = 0x01

                        // Negate present rate
                        Local1 = (0x00010000 - Local1)
                    }
                    Else // Full battery, force to 0
                    {
                        Local0 = 0x00
                    }
                }

                Arg0[0x00] = Local0


                //
                // 1: BATTERY PRESENT RATE/CURRENT
                //

                If (Local1 <= 0x8000) 
                {
                    /*
                     * The present rate value must be positive now, if it is not we have an
                     * EC bug or inconsistency and force the value to 0.
                     */
                    Local1 = 0x00
                }

                If (Local7)
                {
                    Local1 = 1000 * Local1 / Local6
                }

                Arg0[0x01] = Local1


                //
                // 2: BATTERY REMAINING CAPACITY
                //
                Local1 = B1B2 (RC00, RC01)

                If (Local7)
                {
                    Local1 = 1000 * Local1 / Local6
                }

                Arg0[0x02] = Local1


                //
                // 3: BATTERY PRESENT VOLTAGE
                //
                If (Local6 == 0xffff) 
                {
                    Local6 = 0
                }

                Arg0[0x03] = Local6


                Release (^^BATM)

                Return (Arg0)
            }

            /**
             *  Battery availability info
             */
            Name (PBAI, Package ()
            {
                0xFF,        // 0x00: BAT0 present or not
                0xFF,        // 0x01: BAT1 present or not
            })

            /**
             * Battery status
             */
            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                Debug = "BATX:_BST()"

                Local0 = PBST

                If (HB0A) 
                {
                    Local0 = GBST (Local0, 0x00, HB0S)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSTState: BAT0 ", DerefOf(Index(Local0, 0x00)), Debug)
                        Concatenate ("BATX:BSTPresentRate: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x01))), Debug)
                        Concatenate ("BATX:BSTRemainingCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BSTPresentVoltage: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                    }
                } 

                Local1 = PBST

                If (HB1A) 
                {
                    Local1 = GBST (Local1, 0x10, HB1S)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSTState: BAT1 ", DerefOf(Index(Local1, 0x00)), Debug)
                        Concatenate ("BATX:BSTPresentRate: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x01))), Debug)
                        Concatenate ("BATX:BSTRemainingCapacity: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x02))), Debug)
                        Concatenate ("BATX:BSTPresentVoltage: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x03))), Debug)
                    }
                } 

                // combine batteries into Local2 result if possible
                If (HB0A && HB1A)
                {
                    PBST = Local0
                    
                    // _BST 0 - Battery State - if one battery is charging, then charging, else discharging
                    Local4 = DerefOf (Local0[0x00])
                    Local5 = DerefOf (Local1[0x00])

                    If (Local4 == 0x02 || Local5 == 0x02)
                    {
                        // 2 = charging
                        PBST[0x00] = 0x02
                    }
                    ElseIf (Local4 == 0x01 || Local5 == 0x01)
                    {
                        // 1 = discharging
                        PBST[0x00] = 0x01
                    }
                    ElseIf (Local4 == 0x00 && Local5 == 0x00)
                    {
                        // Full battery, force to 0
                        PBST[0x00] = 0x00
                    }
                    // if none of the above, just leave as BAT0 is

                    // _BST 1 - Battery Present Rate - add BAT0 and BAT1 values
                    PBST[0x01] = DerefOf (Local0[0x01]) + DerefOf (Local1[0x01])

                    // _BST 2 - Battery Remaining Capacity - add BAT0 and BAT1 values
                    PBST[0x02] = DerefOf (Local0[0x02]) + DerefOf (Local1[0x02])

                    // _BST 3 - Battery Present Voltage - average between BAT0 and BAT1 values
                    Local4 = DerefOf (Local0[0x03])
                    Local5 = DerefOf (Local1[0x03])

                    If (0x0000 != Local4 && 0x0000 != Local5)
                    {
                        PBST[0x03] = (Local4 + Local5) / 2
                    }
                    ElseIf (0x0000 != Local5)
                    {
                        PBST[0x03] = Local5
                    }
                    Else
                    {
                        PBST[0x03] = Local4
                    }
                }
                ElseIf (!HB0A && HB1A)
                {
                    PBST = Local1
                }
                Else
                {
                    PBST = Local0
                }

                // Check if battery is added or removed
                Local3 = DerefOf(PBAI[0x00])
                Local4 = DerefOf(PBAI[0x01])

                If (Local3 != HB0A || Local4 != HB1A)
                {
                    PBAI[0x00] = HB0A
                    PBAI[0x01] = HB1A

                    If (Local3 != 0xFF || Local4 != 0xFF)
                    {
                        If (BDBG == One)
                        {
                            Concatenate ("BATX:_BST() - PBAI:HB0A (old): ", Local3, Debug)
                            Concatenate ("BATX:_BST() - PBAI:HB1A (old): ", Local4, Debug)
                            Concatenate ("BATX:_BST() - PBAI:HB0A (new): ", HB0A, Debug)
                            Concatenate ("BATX:_BST() - PBAI:HB1A (new): ", HB1A, Debug)
                        }

                        //
                        // Here we actually would need an option to tell VirtualSMC to refresh the static battery data
                        // because a battery was dettached or attached.
                        // I'm not aware of any method to do that yet as VirtualSMC doesn't seem to react on ACPI-notifies.
                        //
                        // @TODO Try to investigate or open a bug.
                        //
                        Notify (BATX, 0x81) // Status Change
                    }
                }

                If (BDBG == One)
                {
                    Concatenate ("BATX:BSTState: BATX ", DerefOf(Index(PBST, 0x00)), Debug)
                    Concatenate ("BATX:BSTPresentRate: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x01))), Debug)
                    Concatenate ("BATX:BSTRemainingCapacity: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x02))), Debug)
                    Concatenate ("BATX:BSTPresentVoltage: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x03))), Debug)
                }

                // Return combined battery
                Return (PBST)
            }

            /**
             *  Battery Status Supplement pack layout
             */
            Name (PBSS, Package ()
            {
                0x28,        // 0x00: BSSTemperature - Temperature, AppleSmartBattery format
                0xFF,        // 0x01: BSSTimeToFull - TimeToFull [minutes] (0xFF)
                0x0,         // 0x02: BSSTimeToEmpty - TimeToEmpty [minutes] (0)
                100,         // 0x03: BSSChargeLevel - ChargeLevel [percent]
                0xFFFFFFFF,  // 0x04: BSSAverageRate - AverageRate [mA] (signed)
                0xFFFFFFFF,  // 0x05: BSSChargingCurrent - ChargingCurrent [mA]
                0xFFFFFFFF,  // 0x06: BSSChargingVoltage - ChargingVoltage [mV]
                0xFFFFFFFF,
            })

            /**
             * Get Battery Status Supplement per battery
             *
             * Arg0: package
             * Arg1: Battery 0x00/0x10
             */
            Method (GBSS, 2, Serialized)
            {
                If (Acquire (^^BATM, 65535))
                {
                    Debug = "BATX:AcquireLock failed in GBSS"

                    Return (PBSS)
                }

                //
                // Information Page 0 -
                //
                BPAG (Arg1 | 0x00)

                // 0x01: TimeToFull (0x11), minutes (0xFF)
                Local6 = B1B2 (AF00, AF01)

                If (Local6 == 0xFFFF)
                {
                    Arg0[0x01] = 0
                }
                Else
                {
                    Arg0[0x01] = Local6
                }

                // 0x02: TimeToEmpty (0x12), minutes (0)
                Local6 = B1B2 (AE00, AE01)

                If (Local6 == 0xFFFF)
                {
                    // Charging
                    Arg0[0x02] = 0
                }
                Else
                {
                    // Discharging
                    Arg0[0x02] = Local6
                }

                // 0x03: BSSChargeLevel - ChargeLevel, percentage
                Arg0[0x03] = B1B2 (RS00, RS01)
                
                // 0x04: AverageRate (0x14), mA (signed)
                Arg0[0x04] = B1B2 (AC00, AC01) // & 0xFFFF

                // 0x05: ChargingCurrent (0x15), mA
                // Arg0[0x05] = B1B2 (CC00, CC01)

                // 0x06: ChargingVoltage (0x16), mV
                // Arg0[0x06] = B1B2 (CV00, CV01)

                Release (^^BATM)

                Return (Arg0)
            }


            /**
             *  Battery Status Supplement
             */
            Method (CBSS, 0, Serialized)
            {
                Debug = "BATX:CBSS()"

                If (!H8DR)
                {
                    Return (PBSS)
                }

                // BAT0
                Local0 = PBSS

                If (HB0A)
                {
                    Local0 = GBSS (Local0, 0x00)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSSTimeToFull: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x01))), Debug)
                        Concatenate ("BATX:BSSTimeToEmpty: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BSSChargeLevel: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x04))), Debug)
                        // Concatenate ("BATX:BSSChargingCurrent: ", ToDecimalString(DerefOf(Index(Local0, 0x05))), Debug)
                        // Concatenate ("BATX:BSSChargingVoltage: ", ToDecimalString(DerefOf(Index(Local0, 0x06))), Debug)
                    }
                }

                // BAT1
                Local1 = PBSS

                If (HB1A)
                {
                    Local1 = GBSS (Local1, 0x10)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSSTimeToFull: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x01))), Debug)
                        Concatenate ("BATX:BSSTimeToEmpty: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x02))), Debug)
                        Concatenate ("BATX:BSSChargeLevel: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x03))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x04))), Debug)
                        // Concatenate ("BATX:BSSChargingCurrent: ", ToDecimalString(DerefOf(Index(Local0, 0x05))), Debug)
                        // Concatenate ("BATX:BSSChargingVoltage: ", ToDecimalString(DerefOf(Index(Local0, 0x06))), Debug)
                    }
                }

                // BATX
                // combine batteries into PBSS result if possible
                If (HB0A && HB1A)
                {
                    PBSS = Local0

                    // 0x01: TimeToFull (0x11), minutes (0xFF)
                    // Valid integer in minutes when charging, otherwise 0xFF.
                    Local4 = DerefOf (Local0 [0x01])
                    Local5 = DerefOf (Local1 [0x01])

                    PBSS[0x01] = (Local4 + Local5)


                    // 0x02: BSSTimeToEmpty - TimeToEmpty, minutes (0)
                    // Valid integer in minutes when discharging, otherwise 0.
                    Local4 = DerefOf (Local0 [0x02])
                    Local5 = DerefOf (Local1 [0x02])

                    PBSS[0x02] = (Local4 + Local5)


                    // 0x03: BSSChargeLevel - ChargeLevel, percentage
                    // 0 - 100 for percentage.
                    Local4 = DerefOf (Local0 [0x03])
                    Local5 = DerefOf (Local1 [0x03])

                    PBSS[0x03] = (Local4 + Local5) / 2


                    // 0x04: BSSAverageRate - AverageRate, mA (signed)
                    // Valid signed integer in mA. Double check if you have valid value since this bit will disable quickPoll.
                    Local4 = DerefOf (Local0 [0x04])
                    Local5 = DerefOf (Local1 [0x04])

                    If (Local4 > 0 && Local5 > 0)
                    {
                        PBSS[0x04] = (Local4 + Local5)
                    }
                    ElseIf (Local5 > 0)
                    {
                        PBSS[0x04] = Local5
                    }
                    Else
                    {
                        PBSS[0x04] = Local4
                    }
                }
                ElseIf (!HB0A && HB1A)
                {
                    PBSS = Local1
                }
                Else
                {
                    PBSS = Local0
                }

                If (HB0S & 0x20 || HB1S & 0x20)
                {
                    // 0x02: BSSTimeToEmpty - TimeToEmpty, minutes (0) while charging always 0
                    PBSS[0x02] = 0
                }
                Else
                {
                    // 0x01: TimeToFull (0x11), minutes (0xFF) while discharging
                    PBSS[0x01] = 0xFF
                }

                If (BDBG == One)
                {
                    Concatenate ("BATX:BSSTimeToFull: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x01))), Debug)
                    Concatenate ("BATX:BSSTimeToEmpty: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x02))), Debug)
                    Concatenate ("BATX:BSSChargeLevel: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x03))), Debug)
                    Concatenate ("BATX:BSSAverageRate: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x04))), Debug)
                }

                Return (PBSS)
            }
        }
    }
}
//EOF
