//
// References:
// https://github.com/coreboot/coreboot/blob/master/src/ec/quanta/it8518/acpi/ec.asl
// https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf
// https://github.com/acidanthera/VirtualSMC/blob/master/Docs/Battery%20Information%20Supplement.md
//
// Changelog:
// 23.10. - Raised timeout for mutexes, factored bank-switching out, added sleep to bank-switching, moved HWAC to its own SSDT
// 25.10. - Prelimitary dual-battery-support, large refactoring
// 26.10. - Remove need of patched notifies, handle battery attach/detach inside, make the whole device self-contained (exept for the EC-helpers)
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


    // External Methods from SSDT-EC.dsl
    External (_SB.PCI0.LPCB.EC.RECB, MethodObj)	

    External (B1B2, MethodObj)	
    External (B1B4, MethodObj)

    // @see https://en.wikipedia.org/wiki/Bank_switching
    //
    // HIID: [Battery information ID for 0xA0-0xAF]
    //   (this byte is depend on the interface, 62&66 and 1600&1604)
    External (_SB.PCI0.LPCB.EC.HIID, FieldUnitObj)
    

    Scope (\_SB.PCI0.LPCB.EC)
    {

        //
        // EC region overlay.
        //
        OperationRegion (BRAM, EmbeddedControl, 0x00, 0x0100)

        Device (BATX)
        {
            Name (BDBG, Zero)

            /* Battery Capacity warning at 25% */
            Name (DWRN, 25)

            /* Battery Capacity low at 20% */
            Name (DLOW, 20)

            /* BATTERY_PAGE_DELAY_MS */
            Name (BDEL, 20)

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
                HB0S, 7,	/* Battery 0 state */
                HB0A, 1,	/* Battery 0 present */
                
                Offset (0x39),
                HB1S, 7,	/* Battery 0 state */
                HB1A, 1		/* Battery 1 present */
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

            // 128-byte fields are replaced with read-methods below
            // //
            // // EC Registers 
            // // HIID == 0x05: Battery OEM information
            // //
            // Field (BRAM, ByteAcc, NoLock, Preserve)
            // {
            //     Offset(0xA0),
            //     SBMN, 128,   // Manufacture Name (s)
            // }

            // //
            // // EC Registers 
            // // HIID == 0x06: Battery name
            // //
            // Field (BRAM, ByteAcc, NoLock, Preserve)
            // {
            //     Offset(0xA0),
            //     SBDN, 128,   // Device Name (s)
            // }

            /**
             * Method to read 128byte-field SBMN 
             */
            Method (SBMN, 1, NotSerialized)
            {
                //
                // Information Page 5 -
                //
                BPAG(Arg0 | 0x05)
                
                Return (RECB (0xA0, 128)) // SBMN
            }

            /**
             * Method to read 128byte-field SBDN
             */
            Method (SBDN, 1, NotSerialized)
            {
                //
                // Information Page 6 -
                //
                BPAG(Arg0 | 0x06)
                
                Return (RECB (0xA0, 128)) // SBDN
            }

            /**
             * Called from RECB, grabs a single byte from EC
             * Arg0 - offset in bytes from zero-based EC
             */
            Method (RE1B, 1, Serialized)
            {
                OperationRegion (ERAM, EmbeddedControl, Arg0, One)
                Field (ERAM, ByteAcc, NoLock, Preserve)
                {
                    BYTE,   8
                }

                Return (BYTE) /* \RE1B.BYTE */
            }

            /** 
             * Read specified number of bytes from EC
             *
             * Arg0 - offset in bytes from zero-based EC
             * Arg1 - size of buffer in bits
             */
            Method (RECB, 2, Serialized)
            {
                Arg1 = ((Arg1 + 0x07) >> 0x03)
                Name (TEMP, Buffer (Arg1) {})
                Arg1 += Arg0
                Local0 = Zero
                While ((Arg0 < Arg1))
                {
                    TEMP [Local0] = RE1B (Arg0)
                    Arg0++
                    Local0++
                }

                Return (TEMP) /* \RECB.TEMP */
            }

            /**
             * Status from two EC fields
             * 
             * e.g. B1B2 (0x3A, 0x03) -> 0x033A
             */
            Method (B1B2, 2, NotSerialized)
            {
                Return ((Arg0 | (Arg1 << 0x08)))
            }

            /**
             * Status from four EC fields
             */
            Method (B1B4, 4, NotSerialized)
            {
                Local0 = (Arg2 | (Arg3 << 0x08))
                Local0 = (Arg1 | (Local0 << 0x08))
                Local0 = (Arg0 | (Local0 << 0x08))

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
            Method(BPAG, 1, NotSerialized)
            {
                HIID = Arg0

                Sleep(BDEL)
            }

            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB
            })

	        // Battery Slot Status
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
                             //       SMART battery : 1 - 10mWh : 0 - mAh
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
                             //       added in Revision 1: Zero means Non-swappable, One – Cold-swappable, 0x10 – Hot-swappable
            })

            Method(BINF, 2, Serialized)
            {
                If (Acquire (^^BATM, 65535))
                {
                    Return (Arg0)
                }

                BPAG(Arg1 | 0x01) 

                // Needs conversion?
		        Local7 = SBCM != 0x01

                //  Cycle count
                Arg0[0x08] = B1B2 (CC00, CC01)

                //
                // Information Page 0 -
                //
                BPAG(Arg1 | 0x00)

                // Last Full Charge Capacity
                If (Local7)
                {
                    Arg0[0x03] = B1B2 (FC00, FC01) * 10
                }
                Else
                {
                    Arg0[0x03] = B1B2 (FC00, FC01)
                }


                //
                // Information Page 2 -
                //
                BPAG(Arg1 | 0x02)

                // Design capacity
                If (Local7)
                {
                    Local0 = B1B2 (DC00, DC01) * 10
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

                // Design voltage
                Arg0[0x05] = B1B2 (DV00, DV01)

                // Serial Number
                Arg0[0x11] = ToHexString (B1B2 (SN00, SN01))

                //
                // Information Page 4 -
                //
                BPAG(Arg1 | 0x04)

                // Battery Type - Device Chemistry
                Arg0[0x12] = ToString (Concatenate (B1B4 (CH00, CH01, CH02, CH03), 0x00))

                // OEM Information - Manufacturer Name
                Arg0[0x13] = ToString (Concatenate(SBMN(0x00), 0x00))

                // Model Number - Device Name
                Arg0[0x10] = ToString (Concatenate(SBDN(0x00), 0x00))

                Release(^^BATM)

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

                Local0 = PBIX

                If (HB0A) 
                {
                    Local0 = BINF(PBIX, 0x0)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BIXRevision: BAT0 ", Local0[0x00], Debug)
                        Concatenate ("BATX:BIXPowerUnit: BAT0 ", Local0[0x01], Debug)
                        Concatenate ("BATX:BIXDesignCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BIXLastFullChargeCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                        Concatenate ("BATX:BIXBatteryTechnology: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x04))), Debug)
                        Concatenate ("BATX:BIXDesignVoltage: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x05))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfWarning: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x06))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfLow: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x07))), Debug)
                        Concatenate ("BATX:BIXCycleCount: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x08))), Debug)
                        Concatenate ("BATX:BIXMeasurementAccuracy: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x09))), Debug)
                        Concatenate ("BATX:BIXMaxSamplingTime: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0a))), Debug)
                        Concatenate ("BATX:BIXMinSamplingTime: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0b))), Debug)
                        Concatenate ("BATX:BIXMaxAveragingInterval: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0c))), Debug)
                        Concatenate ("BATX:BIXMinAveragingInterval: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0d))), Debug)
                        Concatenate ("BATX:BIXBatteryCapacityGranularity1: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0e))), Debug)
                        Concatenate ("BATX:BIXBatteryCapacityGranularity2: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x0f))), Debug)
                        Concatenate ("BATX:BIXModelNumber: BAT0 ", Local0[0x10], Debug)
                        Concatenate ("BATX:BIXSerialNumber: BAT0 ", Local0[0x11], Debug)
                        Concatenate ("BATX:BIXBatteryType: BAT0 ", Local0[0x12], Debug)
                        Concatenate ("BATX:BIXOEMInformation: BAT0 ", Local0[0x13], Debug)
                    }
                } 

                Local1 = PBIX

                If (HB1A) 
                {
                    Local1 = BINF(PBIX, 0x10)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BIXRevision: BAT1 ", Local1[0x00], Debug)
                        Concatenate ("BATX:BIXPowerUnit: BAT1 ", Local1[0x01], Debug)
                        Concatenate ("BATX:BIXDesignCapacity: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x02))), Debug)
                        Concatenate ("BATX:BIXLastFullChargeCapacity: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x03))), Debug)
                        Concatenate ("BATX:BIXBatteryTechnology: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x04))), Debug)
                        Concatenate ("BATX:BIXDesignVoltage: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x05))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfWarning: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x06))), Debug)
                        Concatenate ("BATX:BIXDesignCapacityOfLow: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x07))), Debug)
                        Concatenate ("BATX:BIXCycleCount: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x08))), Debug)
                        Concatenate ("BATX:BIXMeasurementAccuracy: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x09))), Debug)
                        Concatenate ("BATX:BIXMaxSamplingTime: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0a))), Debug)
                        Concatenate ("BATX:BIXMinSamplingTime: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0b))), Debug)
                        Concatenate ("BATX:BIXMaxAveragingInterval: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0c))), Debug)
                        Concatenate ("BATX:BIXMinAveragingInterval: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0d))), Debug)
                        Concatenate ("BATX:BIXBatteryCapacityGranularity1: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0e))), Debug)
                        Concatenate ("BATX:BIXBatteryCapacityGranularity2: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x0f))), Debug)
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
                    // PBIX[0x10] = Concatenate (Concatenate (DerefOf (Local0[0x10]), " / "), DerefOf (Local1[0x10]))

                    // _BIX 11 Serial Number - concatenate BAT0 and BAT1 values
                    // PBIX[0x11] = Concatenate (Concatenate (DerefOf (Local0[0x11]), " / "), DerefOf (Local1[0x11]))

                    // _BIX 12 Battery Type - concatenate BAT0 and BAT1 values
                    // PBIX[0x12] = Concatenate (Concatenate (DerefOf (Local0[0x12]), " / "), DerefOf (Local1[0x12]))

                    // _BIX 13 OEM Information - concatenate BAT0 and BAT1 values
                    // PBIX[0x13] = Concatenate (Concatenate (DerefOf (Local0[0x13]), " / "), DerefOf (Local1[0x13]))

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
                    Concatenate ("BATX:BIXRevision: BATX ", PBIX[0x00], Debug)
                    Concatenate ("BATX:BIXPowerUnit: BATX ", PBIX[0x01], Debug)
                    Concatenate ("BATX:BIXDesignCapacity: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x02))), Debug)
                    Concatenate ("BATX:BIXLastFullChargeCapacity: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x03))), Debug)
                    Concatenate ("BATX:BIXBatteryTechnology: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x04))), Debug)
                    Concatenate ("BATX:BIXDesignVoltage: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x05))), Debug)
                    Concatenate ("BATX:BIXDesignCapacityOfWarning: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x06))), Debug)
                    Concatenate ("BATX:BIXDesignCapacityOfLow: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x07))), Debug)
                    Concatenate ("BATX:BIXCycleCount: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x08))), Debug)
                    Concatenate ("BATX:BIXMeasurementAccuracy: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x09))), Debug)
                    Concatenate ("BATX:BIXMaxSamplingTime: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0a))), Debug)
                    Concatenate ("BATX:BIXMinSamplingTime: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0b))), Debug)
                    Concatenate ("BATX:BIXMaxAveragingInterval: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0c))), Debug)
                    Concatenate ("BATX:BIXMinAveragingInterval: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0d))), Debug)
                    Concatenate ("BATX:BIXBatteryCapacityGranularity1: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0e))), Debug)
                    Concatenate ("BATX:BIXBatteryCapacityGranularity2: BATX ", ToDecimalString(DerefOf(Index(PBIX, 0x0f))), Debug)
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

            Method (CBIS, 0, Serialized)
            {
                Debug = "BATX:CBIS()"

                If (Acquire (^^BATM, 65535))
                {
                    Return (PBIS)
                }

                //
                // Information Page 2 -
                //
                BPAG(0x00 | 0x02)

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
                0,           // 0x01: BSTPresentRate - Battery Present Rate
                0,           // 0x02: BSTRemainingCapacity - Battery Remaining Capacity
                0,           // 0x03: BSTPresentVoltage - Battery Present Voltage
            })


            /* Arg0: Battery
             * Arg1: Battery Status Package
             * Arg2: Battery EC status
             */
            Method(BSTA, 3, NotSerialized)
            {
                If (Acquire (^^BATM, 65535))
                {
                    Return (Arg1)
                }
                
                Local0 = 0


                BPAG(Arg0 | 0x01) 

                // Needs conversion?
                //
                // For reference: (ignored here for the moment):
                //  `On Lenovo Thinkpad models from 2010 and 2011, the power unit
                //  switches between mWh and mAh depending on whether the system
                //  is running on battery or not.  When mAh is the unit, most
                //  reported values are incorrect and need to be adjusted by
                //  10000/design_voltage.  Verified on x201, t410, t410s, and x220.
                //  Pre-2010 and 2012 models appear to always report in mWh and
                //  are thus unaffected (tested with t42, t61, t500, x200, x300,
                //  and x230).  Also, in mid-2012 Lenovo issued a BIOS update for
                //  the 2011 models that fixes the issue (tested on x220 with a
                //  post-1.29 BIOS), but as of Nov. 2012, no such update is
                //  available for the 2010 models.`
                //  src: https://github.com/torvalds/linux/blob/9ff9b0d392ea08090cd1780fb196f36dbb586529/drivers/acpi/battery.c#L82
		        Local7 = SBCM != One


                BPAG(Arg0 | 0x00) /* Battery dynamic information */

                //
                // 0: BATTERY STATE
                //
                // bit 0 = discharging
                // bit 1 = charging
                // bit 2 = critical level
                //

                // Get battery state from EC
                If (Arg2 & 0x20) // Charging
                {
                    Local0 = 2
                }
                Else
                {
                    If (Arg2 & 0x40) // Discharging
                    {
                        Local0 = 2
                    }
                    Else // Full battery, force to 0
                    {
                        Local0 = 0
                    }
                }

                // Set critical flag if battery is empty
                If (Arg2 & 0x0F <= 0)
                {
                    Local0 = Local0 ^ 4
                }

                Arg1[0x00] = Local0

                //
                // 1: BATTERY PRESENT RATE/CURRENT
                //

                /*
                 * Present rate is a 16bit signed int, positive while charging
                 * and negative while discharging.
                 */
                Local1 = B1B2 (AC00, AC01)

                If (Local1 >= 0x8000) 
                {
                    /*
                     * The present rate value must be positive now, if it is not we have an
                     * EC bug or inconsistency and force the value to 0.
                     */
                    If (Local0 & 1)
                    {
                        // Negate present rate
                        Local1 = 0x10000 - Local1
                    }
                    Else
                    {
                        // Error
                        Local1 = 0
                    }
                }
                Else
                {
                    If (!Local0 & 2)
                    {
                        // Battery is not charging
                        Local1 = 0
                    }
                }

                // _BST 1 - Battery Present Rate 
                Local6 = B1B2 (VO00, VO01)

                If (Local7)
                {
                    Local1 = Local1 * Local6 / 1000
                }

                Arg1[0x01] = Local1

                //
                // 2: BATTERY REMAINING CAPACITY
                //
                If (Local6)
                {
                    Arg1[0x02] = B1B2 (RC00, RC01) * 10
                }
                Else
                {
                    Arg1[0x02] = B1B2 (RC00, RC01)
                }

                //
                // 3: BATTERY PRESENT VOLTAGE
                //
                Arg1[0x03] = Local6

                If (DerefOf (Arg1[0x03]) == 0xffff) 
                {
                    Arg1[0x03] = 0
                }

                Release(^^BATM)

                Return (Arg1)
            }

            /**
             *  Battery availability info
             */
            Name (PBAI, Package ()
            {
                0xFF,        // 0x00: BAT0 present or not
                0xFF,        // 0x01: BAT1 present or not
            })


            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                Debug = "BATX:_BST()"

                Local0 = PBST
                Local1 = PBST

                If (HB0A) 
                {
                    Local0 = BSTA (0x00, PBST, HB0S)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSTState: BAT0 ", DerefOf(Index(Local0, 0x00)), Debug)
                        Concatenate ("BATX:BSTPresentRate: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x01))), Debug)
                        Concatenate ("BATX:BSTRemainingCapacity: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BSTPresentVoltage: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                    }
                } 

                If (HB1A) 
                {
                    Local1 = BSTA (0x10, PBST, HB1S)

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

                    If (Local4 != Local5)
                    {
                        If (Local4 == 2 || Local5 == 2)
                        {
                            // 2 = charging
                            PBST[0x00] = 2
                        }
                        ElseIf (Local4 == 1 || Local5 == 1)
                        {
                            // 1 = discharging
                            PBST[0x00] = 1
                        }
                        ElseIf (Local4 == 3 || Local5 == 3)
                        {
                            PBST[0x00] = 3
                        }
                        ElseIf (Local4 == 4 || Local5 == 4)
                        {
                            // critical
                            PBST[0x00] = 4
                        }
                        ElseIf (Local4 == 5 || Local5 == 5)
                        {
                            // critical and discharging
                            PBST[0x00] = 5
                        }
                        // if none of the above, just leave as BAT0 is
                    }

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


                Local3 = DerefOf(PBAI[0x00])
                Local4 = DerefOf(PBAI[0x01])

                If (Local3 != HB0A || Local4 != HB1A)
                {
                    PBAI[0x00] = HB0A
                    PBAI[0x01] = HB1A

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:_BST() - PBAI:HB0A (old): ", Local3, Debug)
                        Concatenate ("BATX:_BST() - PBAI:HB1A (old): ", Local4, Debug)
                        Concatenate ("BATX:_BST() - PBAI:HB0A (new): ", HB0A, Debug)
                        Concatenate ("BATX:_BST() - PBAI:HB1A (new): ", HB1A, Debug)
                    }

                    If (Local3 != 0xFF || Local4 != 0xFF)
                    {
                        //
                        // Here we actually would need an option to tell VirtualSMC to refresh the static battery data
                        // because a battery was dettached or attached.
                        // I'm not aware of any method to do that yet as VirtualSMC doesn't seem to react on ACPI-notifies.
                        //
                        // @TODO Try to investigate or open a bug.
                        //
                        // Notify (BATX, 0x80) // Information Change
                    }
                }

                If (BDBG == One)
                {
                    Concatenate ("BATX:BSTState: BATX ", DerefOf(Index(PBST, 0x00)), Debug)
                    Concatenate ("BATX:BSTPresentRate: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x01))), Debug)
                    Concatenate ("BATX:BSTRemainingCapacity: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x02))), Debug)
                    Concatenate ("BATX:BSTPresentVoltage: BATX ", ToDecimalString(DerefOf(Index(PBST, 0x03))), Debug)

                    Concatenate ("BATX:BST BATX:HB0A ", HB0A, Debug)
                    Concatenate ("BATX:BST BATX:HB1A ", HB1A, Debug)
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
                0xFF,        // 0x01: BSSTimeToFull - TimeToFull, minutes (0xFF)
                0x0,         // 0x02: BSSTimeToEmpty - TimeToEmpty, minutes (0)
                100,         // 0x03: BSSChargeLevel - ChargeLevel, percentage
                0xFFFFFFFF,  // 0x04: BSSAverageRate - AverageRate, mA (signed)
                0xFFFFFFFF,  // 0x05: BSSChargingCurrent - ChargingCurrent, mA
                0xFFFFFFFF,  // 0x06: BSSChargingVoltage - ChargingVoltage, mV
                0xFFFFFFFF,
            })

            Method (CBSS, 0, Serialized)
            {
                Debug = "BATX:CBSS()"

                // BAT0
                Local0 = PBSS

                If (HB0A)
                {
                    If (Acquire (^^BATM, 65535))
                    {
                        Return (PBSS)
                    }

                    //
                    // Information Page 0 -
                    //
                    BPAG(0x00 | 0x00)

                    // 0x01: TimeToFull (0x11), minutes (0xFF)
                    Local6 = B1B2 (AF00, AF01)

                    If (Local6 == 0xFFFF)
                    {
                        Local0[0x01] = 0
                    }
                    Else
                    {
                        Local0[0x01] = Local6
                    }

                    // 0x02: TimeToEmpty (0x12), minutes (0)
                    Local6 = B1B2 (AE00, AE01)

                    If (Local6 == 0xFFFF)
                    {
                        // Charging
                        Local0[0x02] = 0
                    }
                    Else
                    {
                        // Discharging
                        Local0[0x02] = Local6
                    }

                    // 0x03: BSSChargeLevel - ChargeLevel, percentage
                    Local0[0x03] = B1B2 (RS00, RS01)
                    
                    // 0x04: AverageRate (0x14), mA (signed)
                    Local0[0x04] = B1B2 (AC00, AC01) // & 0xFFFF

                    // 0x05: ChargingCurrent (0x15), mA
                    // Local0[0x05] = B1B2 (CC00, CC01)

                    // 0x06: ChargingVoltage (0x16), mV
                    // Local0[0x06] = B1B2 (CV00, CV01)

                    Release (^^BATM)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSSTimeToFull: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x01))), Debug)
                        Concatenate ("BATX:BSSTimeToEmpty: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x02))), Debug)
                        Concatenate ("BATX:BSSChargeLevel: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x03))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT0 ", ToDecimalString(DerefOf(Index(Local0, 0x04))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT0 x ", DerefOf(Index(Local0, 0x04)), Debug)
                        // Concatenate ("BATX:BSSChargingCurrent: ", ToDecimalString(DerefOf(Index(Local0, 0x05))), Debug)
                        // Concatenate ("BATX:BSSChargingVoltage: ", ToDecimalString(DerefOf(Index(Local0, 0x06))), Debug)
                    }
                }

                // BAT1
                Local1 = PBSS

                If (HB0A)
                {
                    If (Acquire (^^BATM, 65535))
                    {
                        Return (PBSS)
                    }

                    //
                    // Information Page 0 -
                    //
                    BPAG(0x10 | 0x00)

                    // 0x01: TimeToFull (0x11), minutes (0xFF)
                    Local6 = B1B2 (AF00, AF01)

                    If (Local6 == 0xFFFF)
                    {
                        Local1[0x01] = 0
                    }
                    Else
                    {
                        Local1[0x01] = Local6
                    }

                    // 0x02: TimeToEmpty (0x12), minutes (0)
                    Local6 = B1B2 (AE00, AE01)

                    If (Local6 == 0xFFFF)
                    {
                        // Charging
                        Local1[0x02] = 0
                    }
                    Else
                    {
                        // Discharging
                        Local1[0x02] = Local6
                    }

                    // 0x03: BSSChargeLevel - ChargeLevel, percentage
                    Local1[0x03] = B1B2 (RS00, RS01)
                    
                    // 0x04: AverageRate (0x14), mA (signed)
                    Local1[0x04] = B1B2 (AC00, AC01) // & 0xFFFF

                    Release (^^BATM)

                    If (BDBG == One)
                    {
                        Concatenate ("BATX:BSSTimeToFull: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x01))), Debug)
                        Concatenate ("BATX:BSSTimeToEmpty: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x02))), Debug)
                        Concatenate ("BATX:BSSChargeLevel: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x03))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x04))), Debug)
                        Concatenate ("BATX:BSSAverageRate: BAT1 x ", DerefOf(Index(Local1, 0x04)), Debug)
                        // Concatenate ("BATX:BSSChargingCurrent: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x05))), Debug)
                        // Concatenate ("BATX:BSSChargingVoltage: BAT1 ", ToDecimalString(DerefOf(Index(Local1, 0x06))), Debug)
                    }
                }

                // BATX

                // combine batteries into Local2 result if possible
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

                    PBSS[0x04] = (Local4 + Local5)

                    // Concatenate ("BATX:BSSChargingCurrent: BATX ", ToDecimalString(DerefOf(Index(Local2, 0x05))), Debug)
                    // Concatenate ("BATX:BSSChargingVoltage: BATX ", ToDecimalString(DerefOf(Index(Local2, 0x06))), Debug)
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
                    // charging
                    PBSS[0x02] = 0
                }
                Else
                {
                    // discharging
                    PBSS[0x01] = 0xFF

                    // Negate present rate
                    // PBSS[0x04] = 0x10000 - DerefOf(PBSS[0x04])
                }

                If (BDBG == One)
                {
                    Concatenate ("BATX:BSSTimeToFull: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x01))), Debug)
                    Concatenate ("BATX:BSSTimeToEmpty: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x02))), Debug)
                    Concatenate ("BATX:BSSChargeLevel: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x03))), Debug)
                    Concatenate ("BATX:BSSAverageRate: BATX ", ToDecimalString(DerefOf(Index(PBSS, 0x04))), Debug)
                    Concatenate ("BATX:BSSAverageRate: BATX x ", DerefOf(Index(PBSS, 0x04)), Debug)
                }

                Return (PBSS)
            }
        }
    }
}
//EOF
