DefinitionBlock ("", "SSDT", 2, "X1C6", "_IGPU", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0.GFX0, DeviceObj)

    External (BRTL, FieldUnitObj)
    External (GSMI, FieldUnitObj)
    External (_SB.PCI0.GFX0.OVER, FieldUnitObj)
    External (_SB.PCI0.GFX0.AINT, MethodObj) // 2 Argumens
    External (_SB.PCI0.GFX0.GSCI.GBDA, MethodObj) // 0 Argumens
    External (_SB.PCI0.GFX0.GSCI.SBCB, MethodObj) // 0 Argumens

    Scope (_SB.PCI0.GFX0)
    {
        Method (PCPC, 0, NotSerialized)
        {
            Debug = "GFX0:PCPC()"
        }

        Method (PAPR, 0, NotSerialized)
        {
            Debug = "GFX0:PAPR()"

            Return (Zero)
        }

        Method (ABCL, 0, NotSerialized)
        {
            Debug = "GFX0:ABCL()"

            Return (Package (0x5D)
            {
                0x50, 
                0x32, 
                Zero, 
                One, 
                0x02, 
                0x03, 
                0x04, 
                0x05, 
                0x06, 
                0x07, 
                0x08, 
                0x09, 
                0x0A, 
                0x0B, 
                0x0C, 
                0x0D, 
                0x0E, 
                0x0F, 
                0x10, 
                0x11, 
                0x12, 
                0x13, 
                0x14, 
                0x15, 
                0x16, 
                0x17, 
                0x18, 
                0x19, 
                0x1A, 
                0x1B, 
                0x1C, 
                0x1D, 
                0x1E, 
                0x1F, 
                0x20, 
                0x21, 
                0x22, 
                0x23, 
                0x24, 
                0x25, 
                0x26, 
                0x27, 
                0x28, 
                0x29, 
                0x2A, 
                0x2B, 
                0x2C, 
                0x2D, 
                0x2E, 
                0x2F, 
                0x30, 
                0x31, 
                0x32, 
                0x33, 
                0x34, 
                0x35, 
                0x36, 
                0x37, 
                0x38, 
                0x39, 
                0x3A, 
                0x3B, 
                0x3C, 
                0x3D, 
                0x3E, 
                0x3F, 
                0x40, 
                0x41, 
                0x42, 
                0x43, 
                0x44, 
                0x45, 
                0x46, 
                0x47, 
                0x48, 
                0x49, 
                0x4A, 
                0x4B, 
                0x4C, 
                0x4D, 
                0x4E, 
                0x4F, 
                0x50, 
                0x51, 
                0x52, 
                0x53, 
                0x54, 
                0x55, 
                0x56, 
                0x57, 
                0x58, 
                0x59, 
                0x5A
            })
        }

        Method (ABCM, 1, NotSerialized)
        {
            Debug = "GFX0:ABCM()"

            If ((Arg0 >= Zero) && (Arg0 <= 0x64))
            {
                BRTL = Arg0
                AINT (One, Arg0)
            }

            Return (Zero)
        }

        Method (ABQC, 0, NotSerialized)
        {
            Debug = "GFX0:ABQC()"

            Return (BRTL) /* \BRTL */
        }

        Method (GBDA, 0, Serialized)
        {
            Debug = "GFX0:GBDA()"

            Local0 = \_SB.PCI0.GFX0.GSCI.GBDA()

            Return (Local0)
        }

        Method (SBCB, 0, Serialized)
        {
            Debug = "GFX0:SBCB()"

            Local0 = \_SB.PCI0.GFX0.GSCI.SBCB()

            Return (Local0)
        }

        Method (SCIP, 0, NotSerialized)
        {
            Debug = "GFX0:SCIP()"

            If (OVER != Zero)
            {
                Return (!GSMI)
            }

            Return (Zero)
        }

        Device (^^MEM2)
        {
            Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (CRS, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite,
                    0x20000000,         // Address Base
                    0x00200000,         // Address Length
                    )
                Memory32Fixed (ReadWrite,
                    0x40000000,         // Address Base
                    0x00200000,         // Address Length
                    )
            })

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
               Debug = "GFX0:MEM2:_CRS"

                Return (CRS) /* \_SB_.MEM2.CRS_ */
            }
        }
    }

    // image processing unit - from macbookpro15,1
    // External (_SB.PCI0, DeviceObj)

    // Scope (_SB.PCI0)
    // {
    //     Device (IPU0)
    //     {
    //         Name (_ADR, 0x00050000)

    //         Method (_STA, 0, NotSerialized)
    //         {
    //             If (OSDW())
    //             {
    //                 Return (0x0F)
    //             }
                
    //             Return (Zero)
    //         }
    //     }
    // }   
}