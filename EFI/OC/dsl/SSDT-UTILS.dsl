DefinitionBlock ("", "SSDT", 2, "X1C6", "_UTILS", 0x00001000)
{
    Scope (\)
    {
        Method (DTGP, 5, NotSerialized)
        {
            If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
            {
                If ((Arg1 == One))
                {
                    If ((Arg2 == Zero))
                    {
                        Arg4 = Buffer (One)
                        {
                            0x03
                        }

                        Return (One)
                    }

                    If ((Arg2 == One))
                    {
                        Return (One)
                    }
                }
            }

            Arg4 = Buffer (One)
            {
                0x00
            }

            Return (Zero)
        }

        /**
        * Detect OSX to enable other patches
        */
        Method (OSDW, 0, NotSerialized)
        {
            If (CondRefOf (\_OSI, Local0))
            {
                If (_OSI ("Darwin"))
                {
                    Return (One) // Is OSX
                }
            }

            Return (Zero)
        }

        /*
         * Status from two EC fields
         */
        Method (B1B2, 2, NotSerialized)
        {
            Local0 = (Arg1 << 0x08)
            Local0 |= Arg0
            Return (Local0)
        }

        /*
         * Status from four EC fields
         */
        Method (B1B4, 4, NotSerialized)
        {
            Local0 = Arg3
            Local0 = (Arg2 | (Local0 << 0x08))
            Local0 = (Arg1 | (Local0 << 0x08))
            Local0 = (Arg0 | (Local0 << 0x08))
            Return (Local0)
        }
    }

    External (_SB_.PCI0.LPCB.EC__.HKEY, DeviceObj)
    External (_SI_._SST, MethodObj)    // 1 Arguments

    Scope (\_SB.PCI0.LPCB.EC.HKEY)
    {
        // Used as a proxy-method to interface with \_SI._SST in YogaSMC
        Method (CSSI, 1, NotSerialized)
        {
            \_SI._SST (Arg0)
        }
    }

    /*
     * Sample DSDT for EC read / write access in case you don't have battery patch
     * Taken from Rehabmman's guide: https://www.tonymacx86.com/threads/guide-how-to-patch-dsdt-for-working-battery-status.116102/
     */
    External (_SB_.PCI0.LPCB.EC, DeviceObj)    // EC path

    Scope (_SB.PCI0.LPCB.EC)
    {
        /* 
         * Called from RECB, grabs a single byte from EC
         * Arg0 - offset in bytes from zero-based EC
         */
        Method (RE1B, 1, NotSerialized)
        {
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            Return (BYTE)
        }

        /* 
         * Grabs specified number of bytes from EC
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

            Return (TEMP)
        }

        Method (WE1B, 2, NotSerialized)
        {
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            BYTE = Arg1
        }

        Method (WECB, 3, Serialized)
        {
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            Name (TEMP, Buffer (Arg1) {})
            TEMP = Arg2
            Arg1 += Arg0
            Local0 = Zero
            While ((Arg0 < Arg1))
            {
                WE1B (Arg0, DerefOf (TEMP [Local0]))
                Arg0++
                Local0++
            }
        }
    }

    /*
    * Sample SSDT for ThinkSMC sensor access
    * Double check name of FieldUnit for collision
    * Registers return 0x00 for non-implemented, 
    * and return 0x80 when not available.
    */
    Scope (_SB.PCI0.LPCB.EC)
    {
        OperationRegion (ESEN, EmbeddedControl, Zero, 0x0100)
        Field (ESEN, ByteAcc, Lock, Preserve)
        {
            // TP_EC_THERMAL_TMP0
            Offset (0x78), 
            EST0,   8, // CPU
            EST1,   8, 
            EST2,   8, 
            EST3,   8, // GPU ?
            EST4,   8, // Battery ?
            EST5,   8, // Battery ?
            EST6,   8, // Battery ?
            EST7,   8, // Battery ?

            // TP_EC_THERMAL_TMP8
            Offset (0xC0), 
            EST8,   8, 
            EST9,   8, 
            ESTA,   8, 
            ESTB,   8, 
            ESTC,   8, 
            ESTD,   8, 
            ESTE,   8, 
            ESTF,   8
        }
    }
}
