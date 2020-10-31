//
// SSDT-SSD0
// Revision 1
//
// Copyleft (c) 2020 by bb. No rights reserved.
//
//
// Abstract:
// Experimental port of the sleep-handling for the PCIe-port of the NVME
//
// Real-life-benefit yet to be proven.
//
// Changelog:
// Revision 1 - Initial implementation
//
DefinitionBlock ("", "SSDT", 2, "THKP", "_SSD0", 0x00001000)
{
    External (_SB.PCI0.RP05, DeviceObj)
    External (_SB.PCI0.RP05.PXSX, DeviceObj)
    External (_SB.PCI0.RP05.PXSX._DSM, MethodObj)
    External (_SB.PCI0.RP05.LDIS, FieldUnitObj)
    External (_SB.PCI0.RP05.LEDM, FieldUnitObj)
    External (_SB.PCI0.RP05.L23E, FieldUnitObj)
    External (_SB.PCI0.RP05.L23R, FieldUnitObj)
    External (_SB.PCI0.RP05.D3HT, FieldUnitObj)

    // External method from SSDT-UTILS.dsl
    External (OSDW, MethodObj) // 0 Arguments
    External (DTGP, MethodObj) // 5 Arguments


    Scope (_SB.PCI0.RP05.PXSX)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            Debug = "_SB.PCI0.RP05.PXSX:_STA"

            If (OSDW ())
            {
                Return (Zero) // hidden
            }

            Return (0x0F)
        }
    }

    // SSD
    Scope (_SB.PCI0.RP05)
    {
        OperationRegion (A1E0, PCI_Config, Zero, 0x40)
        Field (A1E0, ByteAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            BMIE,   3, 
            Offset (0x19), 
            SECB,   8, 
            SBBN,   8, 
            Offset (0x1E), 
                ,   13, 
            MABT,   1
        }

        OperationRegion (A1E1, PCI_Config, Zero, 0x0380)
        Field (A1E1, ByteAcc, NoLock, Preserve)
        {
            Offset (0x4A), 
                ,   5, 
            TPEN,   1, 
            Offset (0x50), 
            ASPM,   2, 
                ,   2, 
            // LDIS,   1, 
            LRTN,   1, 
            Offset (0x52), 
            LSPD,   4, 
                ,   7, 
            LTRN,   1, 
                ,   1, 
            LACT,   1, 
            Offset (0x64), 
                ,   11, 
            LTRS,   1, 
            Offset (0x68), 
                ,   10, 
            LTRE,   1, 
            Offset (0xA4), 
            // PSTA,   2, -> D3HT
            Offset (0xE2), 
                ,   2, 
            // L23E,   1, 
            // L23D,   1, -> L23R
            Offset (0x324), 
                ,   3, 
            // LEDM,   1
        }

        Method (_PS3, 0, Serialized)  // _PS3: Power State 3
        {
            If (OSDW ())
            {
                Debug = "_SB.PCI0.SSD0._PS3"
                L23E = One
                Sleep (One)
                Local0 = Zero
                While (L23E)
                {
                    If (Local0 > 0x04)
                    {
                        Break
                    }

                    Sleep (One)
                    Local0++
                }

                LEDM = One
                D3HT = 0x03
                Local0 = Zero
                While (D3HT != 0x03)
                {
                    If (Local0 > 0x1388)
                    {
                        Break
                    }

                    Sleep (One)
                    Local0++
                }

                // Debug = "Set PCI port to D3"
                // SGOV (0x02070001, Zero)
                // SGDO (0x02070001)
                // Sleep (0x1E)
                // SGOV (0x02040016, Zero)
                // SGDO (0x02040016)
                Sleep (One)
            }
        }

        Method (_PS0, 0, Serialized)  // _PS0: Power State 0
        {
            Debug = "SSD0:_SB.PCI0.SSD0._PS0"
            // SGDI (0x02040016)
            // Sleep (One)
            // SGDI (0x02070001)
            // Sleep (0x1E)

            D3HT = Zero

            Local0 = Zero

            While (D3HT != Zero)
            {
                If (Local0 > 0x1388)
                {
                    Break
                }

                Sleep (One)
                Local0++
            }

            L23R = One

            Sleep (One)
            Local0 = Zero

            While (Local0 <= 0x04)
            {
                Local2 = L23R /* \_SB_.PCI0.RP05.L23R */

                Debug = Concatenate( "SSD0:L23R = ", Local2)

                If (Local2 == Zero)
                {
                    Break
                }

                Sleep (One)
                Local0++
            }

            LEDM = Zero

            Local0 = (Timer + 0x01C9C380)
            Local1 = One

            While (Timer <= Local0)
            {
                Local2 = LACT /* \_SB_.PCI0.RP05.LACT */

                Debug = Concatenate( "SSD0:LACT = ", Local2)

                If (Local2 == One)
                {
                    Local1 = Zero
                    Break
                }

                Sleep (One)
            }

            If (Local1 != Zero)
            {
                Return (Zero)
            }

            Local0 = (Timer + 0x01C9C380)
            Local1 = 0x02

            While (Timer <= Local0)
            {
                Local2 = ^SSD0.CLAS /* \_SB_.PCI0.RP05.SSD0.CLAS */

                Debug = Concatenate( "SSD0:Class code = ", Local2)

                If (Local2 == One)
                {
                    Local1 = Zero
                    Break
                }

                Sleep (0x0A)
            }

            LTRS = One
            LTRE = One

            Return (Zero)
        }

        Device (SSD0)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
            {
                Return (Zero)
            }

            OperationRegion (SSE1, PCI_Config, Zero, 0x1000)
            Field (SSE1, ByteAcc, NoLock, Preserve)
            {
                SVID,   16, 
                SDID,   16, 
                Offset (0x0B), 
                CLAS,   8, 
                Offset (0xC00), 
                L1EL,   32
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package (0x06)
                    {
                        "deep-idle", 
                        One, 
                        "use-msi", 
                        One, 
                        "nvme-LPSR-during-S3-S4", 
                        One
                    }

                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }
}
// EOF
