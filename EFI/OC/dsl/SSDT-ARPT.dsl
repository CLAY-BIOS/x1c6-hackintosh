DefinitionBlock ("", "SSDT", 2, "X1C6", "_ARPT", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0.RP01, DeviceObj)
    External (_SB.PCI0.RP01.PXSX, DeviceObj)
    External (PCRO, MethodObj) // 3 Arguments
    External (PCRA, MethodObj) // 3 Arguments
    External (XLTP, FieldUnitObj)

    // WIFI
    Scope (_SB.PCI0.RP01)
    {
        // Test
        Name (WOWE, Zero)
        Name (TAPD, Zero)
        Name (APWC, Zero)

        OperationRegion (A1E0, PCI_Config, Zero, 0x0380)
        Field (A1E0, ByteAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            BMIE,   3, 
            Offset (0x19), 
            SECB,   8, 
            SBBN,   8, 
            Offset (0x1E), 
                ,   13, 
            MABT,   1, 
            Offset (0x4A), 
                ,   5, 
            TPEN,   1, 
            Offset (0x50), 
                ,   4, 
            LDIX,   1, 
                ,   24, 
            LACT,   1, 
            Offset (0xA4), 
            PSTA,   2, 
            Offset (0xE2), 
                ,   2, 
            L23X,   1, 
            L23D,   1, 
            Offset (0x324), 
                ,   3, 
            LEDX,   1
        }

        Name (SCLK, Package (0x03)
        {
            One, 
            0x08, 
            Zero
        })
        OperationRegion (A1E1, PCI_Config, 0x18, 0x04)
        Field (A1E1, DWordAcc, NoLock, Preserve)
        {
            BNIR,   32
        }

        Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
        {
            Debug = "ARPT:_BBN()"

            If ((BMIE == Zero) && (SECB == 0xFF))
            {
                Return (SNBS) /* \_SB_.PCI0.RP09.SNBS */
            }
            Else
            {
                Return (SECB) /* \_SB_.PCI0.RP09.SECB */
            }
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            Return (0x0F)
        }

        Name (BMIS, Zero)
        Name (SNBS, Zero)
        Name (BNIS, Zero)
        Method (DPWR, 1, Serialized)
        {
            Debug = "ARPT:DPWR()"

            If (!OSDW ())
            {
                Return (0xFF)
            }

            If (Arg0 == Zero)
            {
                Debug = "RP01:DPWR(Zero)"
                // ^^LPCB.EC.APWC = Zero
                APWC = Zero
                Sleep (0x5A)
                Return (Zero)
            }

            If (Arg0 == One)
            {
                Debug = "RP01:DPWR(One)"
                // ^^LPCB.EC.APWC = One
                APWC = One
                Sleep (0xFA)
                Return (One)
            }

            // Return (^^LPCB.EC.APWC) /* \_SB_.PCI0.LPCB.EC__.APWC */
            Return (APWC)
        }

        Method (DRST, 1, Serialized)
        {
            Debug = "ARPT:DRST()"

            If (!OSDW ())
            {
                Return (0xFF)
            }

            If (Arg0 == Zero)
            {
                Debug = "RP01:DRST(Zero)"
                // SGDI (0x02060006)
                Sleep (0x64)
                Return (One)
            }

            If (Arg0 == One)
            {
                Debug = "RP01:DRST(One)"
                // SGOV (0x02060006, Zero)
                // SGDO (0x02060006)
                Sleep (0x64)
                Return (Zero)
            }

            // Return (!GGDV (0x02060006))
            Return (One)
        }

        Method (APPD, 0, Serialized)
        {
            Debug = "ARPT:APPD()"

            If (!OSDW ())
            {
                Return (Zero)
            }

            If ((WOWE == One) && (XLTP != Zero))
            {
                Return (Zero)
            }

            If ((TAPD == Zero) && (XLTP != Zero))
            {
                Return (Zero)
            }

            Debug = "APPD: Put airport module to D3"
            ^PXSX.PSTA = 0x03
            If (XLTP == Zero)
            {
                Debug = "APPD: Airport Root Port Send PME_Turn_Off"
                L23X = One
                Local0 = Zero
                While (L23X)
                {
                    If (Local0 > 0x04)
                    {
                        Break
                    }

                    Sleep (One)
                    Local0++
                }

                LEDX = One
                If ((TAPD == Zero) || (WOWE == One))
                {
                    DRST (One)
                    Local1 = Zero
                    If (DerefOf (SCLK [Zero]) != Zero)
                    {
                        PCRO (0xDC, 0x100C, DerefOf (SCLK [One]))
                        Sleep (0x10)
                    }
                }
            }

            If (WOWE == One)
            {
                Debug = "APPD: Mux Select POR set default output low"
                // SGOV (0x02020010, Zero)
                // SGDO (0x02020010)
                Debug = "APPD: Mux Select for POR"
                // SGOV (0x02020010, One)
            }

            If (((BMIE != Zero) && (BMIE != BMIS)) && (
                ((SECB != Zero) && (SECB != SNBS)) && ((BNIR != 
                Zero) && (BNIR != BNIS))))
            {
                BMIS = BMIE /* \_SB_.PCI0.RP09.BMIE */
                SNBS = SECB /* \_SB_.PCI0.RP09.SECB */
                BNIS = BNIR /* \_SB_.PCI0.RP09.BNIR */
            }

            BMIE = Zero
            BNIR = 0x00FEFF00
            Local0 = TPEN /* \_SB_.PCI0.RP09.TPEN */
            Debug = "APPD: Put airport root port to D3"
            PSTA = 0x03
            Local0 = TPEN /* \_SB_.PCI0.RP09.TPEN */
            Local0 = (Timer + 0x00989680)
            While (Timer <= Local0)
            {
                If (LACT == Zero)
                {
                    Break
                }

                Sleep (0x0A)
            }

            If (WOWE == One)
            {
                Return (Zero)
            }

            If (TAPD == One)
            {
                If (WOWE == Zero)
                {
                    DRST (One)
                }

                DPWR (Zero)
            }

            Return (Zero)
        }

        Method (APPU, 0, Serialized)
        {
            Debug = "ARPT:APPU()"

            If (!OSDW ())
            {
                WOWE = Zero
                Return (Zero)
            }

            If ((WOWE == One) && (XLTP != Zero))
            {
                WOWE = Zero
                Return (Zero)
            }

            If ((TAPD == Zero) && (XLTP != Zero))
            {
                WOWE = Zero
                Return (Zero)
            }

            Debug = "APPU: Restore airport root port back to D0"
            PSTA = Zero
            If (SECB != 0xFF)
            {
                Debug = "APPU: Valid config, no restore needed"
                WAPS ()
                Return (Zero)
            }

            BNIR = BNIS /* \_SB_.PCI0.RP09.BNIS */
            If (XLTP == Zero)
            {
                If ((TAPD == Zero) || (WOWE == One))
                {
                    If (DerefOf (SCLK [Zero]) != Zero)
                    {
                        PCRA (0xDC, 0x100C, ~DerefOf (SCLK [One]))
                        Sleep (0x10)
                    }

                    Debug = "APPU: Airport assert reset signal"
                    DRST (One)
                    Debug = "APPU: Airport release reset signal"
                    DRST (Zero)
                }

                Debug = "APPU: Airport Root Port moved from L23 to Detect"
                L23D = One
                Local0 = Zero
                While (L23D)
                {
                    If (Local0 > 0x04)
                    {
                        Break
                    }

                    Sleep (One)
                    Local0++
                }

                LEDX = Zero
                If ((TAPD == Zero) || (WOWE == One))
                {
                    Local2 = (Timer + 0x00989680)
                    While (Timer <= Local2)
                    {
                        If ((LACT == One) && (^PXSX.AVND != 0xFFFF))
                        {
                            Debug = "APPU: Link active."
                            Break
                        }

                        Sleep (0x0A)
                    }

                    WOWE = Zero
                    Return (Zero)
                }
            }

            WOWE = Zero
            If (DPWR (0xFF) == One)
            {
                Local2 = (Timer + 0x00989680)
                While (Timer <= Local2)
                {
                    If (LACT == One)
                    {
                        Break
                    }

                    Sleep (0x0A)
                }

                WAPS ()
                Return (Zero)
            }

            Local0 = Zero
            While (One)
            {
                Debug = "APPU: Restore Power"
                DPWR (One)
                If ((TAPD == One) && (WOWE == Zero))
                {
                    DRST (Zero)
                }

                Local1 = Zero
                Local2 = (Timer + 0x00989680)
                While (Timer <= Local2)
                {
                    If ((LACT == One) && (^PXSX.AVND != 0xFFFF))
                    {
                        Local1 = One
                        Break
                    }

                    Sleep (0x0A)
                }

                If (Local1 == One)
                {
                    WAPS ()
                    MABT = One
                    Break
                }

                If (Local0 == 0x04)
                {
                    Break
                }

                Local0++
                DPWR (Zero)
            }

            Return (Zero)
        }

        Method (ALPR, 1, NotSerialized)
        {
            Debug = "ARPT:ALPR()"

            If (Arg0 == One)
            {
                APPD ()
            }
            Else
            {
                APPU ()
            }
        }

        // Method (_PS0, 0, Serialized)  // _PS0: Power State 0
        // {
        //     If (OSDW ())
        //     {
        //         ALPR (Zero)
        //         MPPG = Zero
        //         HCPG = One
        //     }
        // }

        // Method (_PS3, 0, Serialized)  // _PS3: Power State 3
        // {
        //     If (OSDW ())
        //     {
        //         MPPG = One
        //         HCPG = Zero
        //         ALPR (One)
        //     }
        // }

        Method (WAPS, 0, Serialized)
        {
            Debug = "ARPT:WAPS()"

            ^PXSX.BDEN = 0x40
            ^PXSX.BDMR = 0x18003000
            ^PXSX.BDIR = 0x0120
            ^PXSX.BDDR = 0x0438
            ^PXSX.BDIR = 0x0124
            ^PXSX.BDDR = 0x0170106B
            ^PXSX.BDEN = Zero
        }
    }

    Scope (_SB.PCI0.RP01.PXSX)
    {
        Name (_GPE, 0x31)  // _GPE: General Purpose Events
        OperationRegion (ARE2, PCI_Config, Zero, 0x80)
        Field (ARE2, ByteAcc, NoLock, Preserve)
        {
            AVND,   16, 
            ADID,   16, 
            Offset (0x4C), 
            PSTA,   2
        }

        OperationRegion (ARE3, PCI_Config, 0x80, 0x80)
        Field (ARE3, DWordAcc, NoLock, Preserve)
        {
            BDMR,   32, 
            Offset (0x08), 
            BDEN,   32, 
            Offset (0x20), 
            BDIR,   32, 
            BDDR,   32
        }

        // Method (_STA, 0, NotSerialized)  // _STA: Status
        // {
        //     Return (0x0F)
        // }

        // Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        // {
        //     If (OSDW ())
        //     {
        //         Return (Package (0x02)
        //         {
        //             0x69, 
        //             0x04
        //         })
        //     }
        //     Else
        //     {
        //         Return (Package (0x02)
        //         {
        //             0x69, 
        //             0x04
        //         })
        //     }
        // }

        Method (PRW0, 0, NotSerialized)
        {
            Debug = "ARPT:PRW0()"

            Return (Package (0x01)
            {
                0x31
            })
        }

        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        Method (WWEN, 1, NotSerialized)
        {
            Debug = "ARPT:WWEN()"

            ^^WOWE = Arg0
        }

        Method (PDEN, 1, NotSerialized)
        {
            Debug = "ARPT:PDEN()"

            ^^TAPD = Arg0
        }
    }
}