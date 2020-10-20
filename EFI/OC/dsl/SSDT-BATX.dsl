//
// References:
// https://github.com/coreboot/coreboot/blob/master/src/ec/quanta/it8518/acpi/ec.asl
// https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf
// https://github.com/acidanthera/VirtualSMC/blob/master/Docs/Battery%20Information%20Supplement.md
//
// <dict>
// 	<key>Comment</key>
// 	<string>BAT: Change HWAC to XWAC EC reads</string>
// 	<key>Count</key>
// 	<integer>0</integer>
// 	<key>Enabled</key>
// 	<true/>
// 	<key>Find</key>
// 	<data>RUNfX0hXQUM=</data>
// 	<key>Limit</key>
// 	<integer>0</integer>
// 	<key>Mask</key>
// 	<data></data>
// 	<key>OemTableId</key>
// 	<data></data>
// 	<key>Replace</key>
// 	<data>RUNfX1hXQUM=</data>
// 	<key>ReplaceMask</key>
// 	<data></data>
// 	<key>Skip</key>
// 	<integer>0</integer>
// 	<key>TableLength</key>
// 	<integer>0</integer>
// 	<key>TableSignature</key>
// 	<data>RFNEVA==</data>
// </dict>
//
// <dict>
//  <key>Comment</key>
//  <string>BAT: Fix Notify BAT0 to BATX</string>
//  <key>Count</key>
//  <integer>0</integer>
//  <key>Enabled</key>
//  <true/>
//  <key>Find</key>
//  <data>hkJBVDAK</data>
//  <key>Limit</key>
//  <integer>0</integer>
//  <key>Mask</key>
//  <data></data>
//  <key>OemTableId</key>
//  <data></data>
//  <key>Replace</key>
//  <data>hkJBVFgK</data>
//  <key>ReplaceMask</key>
//  <data></data>
//  <key>Skip</key>
//  <integer>0</integer>
//  <key>TableLength</key>
//  <integer>0</integer>
//  <key>TableSignature</key>
//  <data>RFNEVA==</data>
// </dict>
//
DefinitionBlock ("", "SSDT", 2, "X1C6", "_BATX", 0x00001000)
{
    External (_SB.PCI0.LPCB.EC, DeviceObj)
    External (_SB.PCI0.LPCB.EC.BATM, MutexObj)
    External (_SB.PCI0.LPCB.EC.BAT0, DeviceObj)
    External (_SB.PCI0.LPCB.EC.BAT0._STA, MethodObj)
    External (_SB.PCI0.LPCB.EC.BAT0._INI, MethodObj)
    External (_SB.PCI0.LPCB.EC.BAT0._HID, IntObj)
    External (_SB.PCI0.LPCB.EC.BAT0.B0ST, IntObj)

    // HB0S: [Battery 0 status (read only)]
    //   bit 3-0 level
    //     F: Unknown
    //     2-n: battery level
    //     1: low level
    //     0: (critical low battery, suspend/ hibernate)
    //   bit 4 error
    //   bit 5 charge
    //   bit 6 discharge
    External (_SB.PCI0.LPCB.EC.HB0S, FieldUnitObj)

    // HIID: [Battery information ID for 0xA0-0xAF]
    //   (this byte is depend on the interface, 62&66 and 1600&1604)
    External (_SB.PCI0.LPCB.EC.HIID, FieldUnitObj)
    
    // External Methods from SSDT-UTILS.dsl
    External(_SB.PCI0.LPCB.EC.RE1B, MethodObj)
    External(_SB.PCI0.LPCB.EC.RECB, MethodObj)

    External(B1B2, MethodObj)
    External(B1B4, MethodObj)
    External(OSDW, MethodObj)

    Scope (\_SB.PCI0.LPCB.EC)
    {
        // Method used for replacing reads to HWAC in _L17() & OWAK().
        Method(XWAC, 0, NotSerialized)
        {
            Return (B1B2(WAC0, WAC1))
        }

        //
        // EC region overlay.
        //
        OperationRegion (ERAM, EmbeddedControl, 0x00, 0x0100)
        Field(ERAM, ByteAcc, NoLock, Preserve)
        {
            Offset(0x36),
            WAC0, 8, WAC1, 8,

            Offset (0x38),
            B0ST, 4,	/* Battery 0 state */
                , 1,
            B0CH, 1,	/* Battery 0 charging */
            B0DI, 1,	/* Battery 0 discharging */
            B0PR, 1,	/* Battery 0 present */
        }

        //
        // EC Registers 
        // HIID == 0x00
        //
        Field (ERAM, ByteAcc, NoLock, Preserve)
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
        Field (ERAM, ByteAcc, NoLock, Preserve)
        {
            Offset(0xA0),
                        // Battery Mode(w)
                , 15,
            SBCM, 1,     //  bit 15 - CAPACITY_MODE
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
        Field (ERAM, ByteAcc, NoLock, Preserve)
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
        Field (ERAM, ByteAcc, NoLock, Preserve)
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
        // Field (ERAM, ByteAcc, NoLock, Preserve)
        // {
        //     Offset(0xA0),
        //     SBMN, 128,   // Manufacture Name (s)
        // }

        // //
        // // EC Registers 
        // // HIID == 0x06: Battery name
        // //
        // Field (ERAM, ByteAcc, NoLock, Preserve)
        // {
        //     Offset(0xA0),
        //     SBDN, 128,   // Device Name (s)
        // }

        Device (BATX)
        {
            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB
            })

            /* Battery Capacity warning at 15% */
            Name (DWRN, 15)

            /* Battery Capacity low at 10% */
            Name (DLOW, 10)

            /* Method to read 128byte-field SBMN */
            Method (SBMN, 0, NotSerialized)
            {
                //
                // Information Page 5 -
                //
                HIID = 0x05
                
                Return (RECB (0xA0, 128)) // SBMN
            }

            // Method to read 128byte-field SBDN
            Method (SBDN, 0, NotSerialized)
            {
                //
                // Information Page 6 -
                //
                HIID = 0x06
                
                Return (RECB (0xA0, 128)) // SBDN
            }

            Method (_INI, 0, NotSerialized)
            {
                If (OSDW ())
                {
                    // disable original battery objects by setting invalid _HID
                    ^^BAT0._HID = 0

                    // disable bat0-device. As we are reimplementing the device entirely and accessing the EC directly, it is not needed.
                    ^^BAT0.B0ST = Zero
                }
            }

	        // Battery Slot Status
            Method (_STA, 0, NotSerialized)
            {
                If (OSDW ())
                {
                    // call original _STA for BAT0 and BAT1
                    // result is bitwise OR between them
                    Return (^^BAT0._STA ())
                }

                Return (Zero)
            }

            /**
             *  Extended Battery Static Information pack layout
             */
            Name (PBIX, Package () {
                0x01,        // 0x00: BIXRevision - Revision - Integer
                0x00000000,  // 0x01: BIXPowerUnit - Power Unit: mAh - Integer (DWORD)
                             //       SMART battery : 1 - 10mWh : 0 - mAh
                             //       ACPI spec     : 0 - mWh   : 1 - mAh                
                             //       We are always outputting mWh.
                0xFFFFFFFF,  // 0x02: BIXDesignCapacity - Design Capacity - Integer (DWORD)
                0xFFFFFFFF,  // 0x03: BIXLastFullChargeCapacity - Last Full Charge Capacity - Integer (DWORD)
                0x00000001,  // 0x04: BIXBatteryTechnology - Battery Technology: Rechargeable - Integer (DWORD)
                0xFFFFFFFF,  // 0x05: BIXDesignVoltage - Design Voltage - Integer (DWORD)
                0x000000FA,  // 0x06: BIXDesignCapacityOfWarning - Design Capacity of Warning - Integer (DWORD)
                0x00000064,  // 0x07: BIXDesignCapacityOfLow - Design Capacity of Low - Integer (DWORD)
                0xFFFFFFFF,  // 0x08: BIXCycleCount - Cycle Count - Integer (DWORD)
                0x00017318,  // 0x09: BIXMeasurementAccuracy - Measurement Accuracy (98.3%?) - Integer (DWORD)
                0xFFFFFFFF,  // 0x0a: BIXMaxSamplingTime - Max Sampling Time (500ms) - Integer (DWORD)
                0xFFFFFFFF,  // 0x0b: BIXMinSamplingTime - Min Sampling Time (10ms) - Integer (DWORD)
                5000,        // 0x0c: BIXMaxAveragingInterval - Max Averaging Interval - Integer (DWORD)
                500,         // 0x0d: BIXMinAveragingInterval - Min Averaging Interval - Integer (DWORD)
                0x0000000A,  // 0x0e: BIXBatteryCapacityGranularity1 - Capacity Granularity 1
                0x0000000A,  // 0x0f: BIXBatteryCapacityGranularity2 - Capacity Granularity 2
                " ",         // 0x10: BIXModelNumber - Model Number - String
                " ",         // 0x11: BIXSerialNumber - Serial Number - String
                " ",         // 0x12: BIXBatteryType - Battery Type - String
                " ",         // 0x13: BIXOEMInformation - OEM Information - String
                0x00000000   // 0x14: ??? - Battery Swapping Capability, 0x00000000 = non-swappable - Integer (DWORD)
                             //       added in Revision 1: Zero means Non-swappable, One – Cold-swappable, 0x10 – Hot-swappable
            })

            /**
             * Acpi-Spec:
             * 10.2.2.2 _BIX (Battery Information Extended)
             * The _BIX object returns the static portion of the Control Method Battery information. This information
             * remains constant until the battery is changed. The _BIX object returns all information available via the
             * _BIF object plus additional battery information. The _BIF object is deprecated in lieu of _BIX in ACPI 4.0
             */
            Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
            {
                // Debug = "BATX:_BIX"

                If (Acquire (^^BATM, 1000))
                {
                    Return (PBIX)
                }

                //
                // Information Page 1 -
                //
                HIID = 0x01

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
                PBIX[0x01] = SBCM ^ 0x01

                //  Cycle count
                PBIX[0x08] = B1B2 (CC00, CC01)

                //
                // Information Page 0 -
                //
                HIID = Zero

                // Last Full Charge Capacity
                PBIX[0x03] = B1B2 (FC00, FC01)

                //
                // Information Page 2 -
                //
                HIID = 0x02

                // Design capacity
                Local0 = B1B2 (DC00, DC01)

                PBIX[0x02] = Local0

                // Design capacity of High
                PBIX[0x06] = Local0 / 100 * DWRN

                // Design capacity of Low 
                PBIX[0x07] = Local0 / 100 * DLOW

                // Design voltage
                PBIX[0x05] = B1B2 (DV00, DV01)

                // Serial Number
                PBIX[0x11] = ToHexString (B1B2 (SN00, SN01))

                //
                // Information Page 4 -
                //
                HIID = 0x04

                // Battery Type - Device Chemistry
                PBIX[0x12] = ToString (Concatenate (B1B4 (CH00, CH01, CH02, CH03), 0x00))

                // OEM Information - Manufacturer Name
                PBIX[0x13] = ToString (Concatenate(SBMN(), 0x00))

                // Model Number - Device Name
                PBIX[0x10] = ToString (Concatenate(SBDN(), 0x00))

                // Concatenate ("BATX:BIXRevision: ", PBIX[0x00], Debug)
                // Concatenate ("BATX:BIXPowerUnit: ", PBIX[0x01], Debug)
                // Concatenate ("BATX:BIXDesignCapacity: ", ToDecimalString(DerefOf(Index(PBIX, 0x02))), Debug)
                // Concatenate ("BATX:BIXLastFullChargeCapacity: ", ToDecimalString(DerefOf(Index(PBIX, 0x03))), Debug)
                // Concatenate ("BATX:BIXBatteryTechnology: ", ToDecimalString(DerefOf(Index(PBIX, 0x04))), Debug)
                // Concatenate ("BATX:BIXDesignVoltage: ", ToDecimalString(DerefOf(Index(PBIX, 0x05))), Debug)
                // Concatenate ("BATX:BIXDesignCapacityOfWarning: ", ToDecimalString(DerefOf(Index(PBIX, 0x06))), Debug)
                // Concatenate ("BATX:BIXDesignCapacityOfLow: ", ToDecimalString(DerefOf(Index(PBIX, 0x07))), Debug)
                // Concatenate ("BATX:BIXCycleCount: ", ToDecimalString(DerefOf(Index(PBIX, 0x08))), Debug)
                // Concatenate ("BATX:BIXMeasurementAccuracy: ", ToDecimalString(DerefOf(Index(PBIX, 0x09))), Debug)
                // Concatenate ("BATX:BIXMaxSamplingTime: ", ToDecimalString(DerefOf(Index(PBIX, 0x0a))), Debug)
                // Concatenate ("BATX:BIXMinSamplingTime: ", ToDecimalString(DerefOf(Index(PBIX, 0x0b))), Debug)
                // Concatenate ("BATX:BIXMaxAveragingInterval: ", ToDecimalString(DerefOf(Index(PBIX, 0x0c))), Debug)
                // Concatenate ("BATX:BIXMinAveragingInterval: ", ToDecimalString(DerefOf(Index(PBIX, 0x0d))), Debug)
                // Concatenate ("BATX:BIXBatteryCapacityGranularity1: ", ToDecimalString(DerefOf(Index(PBIX, 0x0e))), Debug)
                // Concatenate ("BATX:BIXBatteryCapacityGranularity2: ", ToDecimalString(DerefOf(Index(PBIX, 0x0f))), Debug)
                // Concatenate ("BATX:BIXModelNumber: ", PBIX[0x10], Debug)
                // Concatenate ("BATX:BIXSerialNumber: ", PBIX[0x11], Debug)
                // Concatenate ("BATX:BIXBatteryType: ", PBIX[0x12], Debug)
                // Concatenate ("BATX:BIXOEMInformation: ", PBIX[0x13], Debug)

                // Debug = "BATX:_BIX end"

                Release (^^BATM)

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
                0xFFFFFFFF,  // 0x02: BISPackLotCode - PackLotCode 
                0xFFFFFFFF,  // 0x03: BISPCBLotCode - PCBLotCode
                0xFFFFFFFF,  // 0x04: BISFirmwareVersion - FirmwareVersion
                0xFFFFFFFF,  // 0x05: BISHardwareVersion - HardwareVersion
                0xFFFFFFFF,  // 0x06: BISBatteryVersion - BatteryVersion 
                0xFFFFFFFF,
            })

            Method (CBIS, 0, Serialized)
            {
                If (Acquire (^^BATM, 1000))
                {
                    Return (PBST)
                }

                //
                // Information Page 2 -
                //
                HIID = 0x02

                // 0x01: ManufactureDate (0x1), AppleSmartBattery format
                PBST[0x01] = B1B2 (DT00, DT01)

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
                0xFFFFFFFF,  // 0x01: BSTPresentRate - Battery Present Rate
                0xFFFFFFFF,  // 0x02: BSTRemainingCapacity - Battery Remaining Capacity
                0xFFFFFFFF,  // 0x03: BSTPresentVoltage - Battery Present Voltage
            })

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                // Battery error state
                If (((HB0S & 0x07) == 0x07))
                {
                    PBST[0x00] = 0x04
                    PBST[0x01] = 0x00
                    PBST[0x02] = 0x00
                    PBST[0x03] = 0x00
                }
                Else
                {
                    If (Acquire (^^BATM, 1000))
                    {
                        Return (PBST)
                    }

                    Local0 = 0x00

                    //
                    // Information Page 0 -
                    //
                    HIID = 0x00 /* Battery dynamic information */

                    // Present rate is a 16bit signed int, positive while charging
                    // and negative while discharging.
                    Local1 = B1B2 (AC00, AC01)

                    If (B0CH) // Charging
                    {
                        Or(2, Local0, Local0)
                    }
                    Else
                    {
                        If (B0DI) // Discharging
                        {
                            Or(1, Local0, Local0)

                            // Negate present rate
                            Subtract(0x10000, Local1, Local1)
                        }
                        Else // Full battery, force to 0
                        {
                            Store(0, Local1)
                        }
                    }

                    /*
                     * The present rate value must be positive now, if it is not we have an
                     * EC bug or inconsistency and force the value to 0.
                     */
                    If (LGreaterEqual (Local1, 0x8000)) {
                        Store(0, Local1)
                    }

                    PBST[0x00] = Local0
                    PBST[0x01] = Local1
                    PBST[0x02] = B1B2 (RC00, RC01)
                    PBST[0x03] = B1B2 (VO00, VO01)

                    Release (^^BATM)
                }

                // Concatenate ("BATX:BSTState: ", DerefOf(Index(PBST, 0x00)), Debug)
                // Concatenate ("BATX:BSTPresentRate: ", ToDecimalString(DerefOf(Index(PBST, 0x01))), Debug)
                // Concatenate ("BATX:BSTRemainingCapacity: ", ToDecimalString(DerefOf(Index(PBST, 0x02))), Debug)
                // Concatenate ("BATX:BSTPresentVoltage: ", ToDecimalString(DerefOf(Index(PBST, 0x03))), Debug)

                Return (PBST)
            }

            /**
             *  Battery Status Supplement pack layout
             */
            Name (PBSS, Package ()
            {
                0xFFFFFFFF,  // 0x00: BSSTemperature - Temperature, AppleSmartBattery format
                0xFFFFFFFF,  // 0x01: BSSTimeToFull - TimeToFull, minutes (0xFF)
                0xFFFFFFFF,  // 0x02: BSSTimeToEmpty - TimeToEmpty, minutes (0)
                0xFFFFFFFF,  // 0x03: BSSChargeLevel - ChargeLevel, percentage
                0xFFFFFFFF,  // 0x04: BSSAverageRate - AverageRate, mA (signed)
                0xFFFFFFFF,  // 0x05: BSSChargingCurrent - ChargingCurrent, mA
                0xFFFFFFFF,  // 0x06: BSSChargingVoltage - ChargingVoltage, mV
                0xFFFFFFFF,
            })

            Method (CBSS, 0, Serialized)
            {
                If (Acquire (^^BATM, 1000))
                {
                    Return (PBSS)
                }

                //
                // Information Page 0 -
                //
                HIID = 0x00

                // 0x01: TimeToFull (0x11), minutes (0xFF)
                PBSS[0x01] = B1B2 (AF00, AF01) // ??

                // 0x02: TimeToEmpty (0x12), minutes (0)
                PBSS[0x02] = B1B2 (AE00, AE01) // ??

                // 0x03: BSSChargeLevel - ChargeLevel, percentage
                PBSS[0x03] = B1B2 (RS00, RS01)
                
                // 0x04: AverageRate (0x14), mA (signed)
                // PBSS[0x04] = B1B2 (AC00, AC01)

                // 0x05: ChargingCurrent (0x15), mA
                // PBSS[0x05] = B1B2 (CC00, CC01)

                // 0x06: ChargingVoltage (0x16), mV
                // PBSS[0x06] = B1B2 (CV00, CV01)

                // Concatenate ("BATX:BSSTimeToFull: ", ToDecimalString(DerefOf(Index(PBSS, 0x01))), Debug)
                // Concatenate ("BATX:BSSTimeToEmpty: ", ToDecimalString(DerefOf(Index(PBSS, 0x02))), Debug)
                // Concatenate ("BATX:BSSChargeLevel: ", ToDecimalString(DerefOf(Index(PBSS, 0x03))), Debug)
                // Concatenate ("BATX:BSSAverageRate: ", ToDecimalString(DerefOf(Index(PBSS, 0x04))), Debug)
                // Concatenate ("BATX:BSSChargingCurrent: ", ToDecimalString(DerefOf(Index(PBSS, 0x05))), Debug)
                // Concatenate ("BATX:BSSChargingVoltage: ", ToDecimalString(DerefOf(Index(PBSS, 0x06))), Debug)

                Release (^^BATM)

                Return (PBSS)
            }
        }
    }
}