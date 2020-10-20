/**
 */
DefinitionBlock ("", "SSDT", 1, "X1C6", "_LID", 0x00001000)
{
    External (DTGP, MethodObj) // 5 Arguments
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.LID, DeviceObj)
    External (_SB.PCI0.LPCB.EC, DeviceObj)

    External (XQ2A, MethodObj) // 0 Arguments
    External (XQ2B, MethodObj) // 0 Arguments

    External (_SB.PCI0.LPCB.EC.HWLO, FieldUnitObj) // LID open
    External (_SB.PCI0.LPCB.EC.HPLD, FieldUnitObj) // LID open
    External (_SB.PCI0.IGPU.CLID, FieldUnitObj) // iGPU lid state

    External (LIDS, FieldUnitObj) // Lid state
    External (H8DR, FieldUnitObj) // EC Ready?
    External (LWCP, FieldUnitObj)
    External (LWEN, FieldUnitObj)

    Scope (\_SB.LID)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (OSDW ())
            {
                Return (Zero)
            }

            Return (0x0F)
        }
    }

    Scope (\_SB)
    {
        Device (LID0)
        {
            Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                If (\LWCP)
                {
                    Return (Package (0x02)
                    {
                        0x17, 
                        0x04
                    })
                }
                Else
                {
                    Return (Package (0x02)
                    {
                        0x17, 
                        0x03
                    })
                }
            }

            Method (_LID, 0, NotSerialized)  // _LID: Lid Status
            {
                LIDS = ^^PCI0.LPCB.EC.HPLD /* \_SB_.PCI0.LPCB.EC__.HPLD */
                ^^PCI0.IGPU.CLID = ^^PCI0.LPCB.EC.HPLD /* \_SB_.PCI0.LPCB.EC__.HPLD */

                Return (LIDS) /* \LIDS */
            }

            Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
            {
                If (\H8DR)
                {
                    If (Arg0)
                    {
                        ^^PCI0.LPCB.EC.HWLO = One
                    }
                    Else
                    {
                        ^^PCI0.LPCB.EC.HWLO = Zero
                    }
                }

                If (\LWCP)
                {
                    If (Arg0)
                    {
                        \LWEN = 0x01
                    }
                    Else
                    {
                        \LWEN = 0x00
                    }
                }
            }
        }
    }

    Scope (\_SB.PCI0.LPCB.EC)
    {
        Method (_Q2A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "Lid open event (_Q2A)"

            If (OSDW ())
            {
                LIDU()
            }
            Else
            {
                XQ2A()
            }

            // ADBG ("LIDO")
            // \VCMS (0x01, \_SB.LID._LID ())
            // \_SB.PCI0.LPCB.EC.LED (0x00, 0x80)
            // If ((\ILNF == 0x00))
            // {
            //     If (\IOST)
            //     {
            //         If (!\ISOC (0x00))
            //         {
            //             \IOST = 0x00
            //             \_SB.PCI0.LPCB.EC.HKEY.MHKQ (0x60D0)
            //         }
            //     }

            //     \_SB.PCI0.LPCB.EC.HKEY.MHKQ (0x5002)
            //     If ((\PLUX == 0x00))
            //     {
            //         If (VIGD)
            //         {
            //             \_SB.PCI0.GFX0.VLOC (0x01)
            //         }

            //         Notify (\_SB.LID, 0x80) // Status Change
            //     }
            // }
        }

        Method (_Q2B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "Lid close event (_Q2B)"

            If (OSDW ())
            {
                LIDU()
            }
            Else
            {
                XQ2B()
            }

            // ADBG ("LIDC")
            // \UCMS (0x0D)
            // \_SB.PCI0.LPCB.EC.LED (0x00, 0x00)
            // \VCMS (0x01, \_SB.LID._LID ())
            // If ((\ILNF == 0x00))
            // {
            //     If ((\IOEN && !\IOST))
            //     {
            //         If (!\ISOC (0x01))
            //         {
            //             \IOST = 0x01
            //             \_SB.PCI0.LPCB.EC.HKEY.MHKQ (0x60D0)
            //         }
            //     }

            //     \_SB.PCI0.LPCB.EC.HKEY.MHKQ (0x5001)
            //     If ((\PLUX == 0x00))
            //     {
            //         If (VIGD)
            //         {
            //             \_SB.PCI0.GFX0.VLOC (0x00)
            //         }

            //         Notify (\_SB.LID, 0x80) // Status Change
            //     }
            // }
        }

        // Update lid-state
        Method (LIDU, 0, NotSerialized)  // _Qxx: EC Query
        {
            LIDS = HPLD /* \_SB_.PCI0.LPCB.EC__.HPLD */
            Debug = "LidState - HPLD ="
            Debug = HPLD /* \_SB_.PCI0.LPCB.EC__.HPLD */
            ^^^IGPU.CLID = HPLD /* \_SB_.PCI0.LPCB.EC__.HPLD */
            Debug = "LidState - CLID ="
            Debug = ^^^IGPU.CLID /* \_SB_.PCI0.IGPU.CLID */
            Notify (LID0, 0x80) // Status Change
        }
    }
}