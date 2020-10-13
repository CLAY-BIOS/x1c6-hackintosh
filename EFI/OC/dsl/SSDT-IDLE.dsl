// AOAC
// IORegistryExplorer
// IOService:/AppleACPIPlatformExpert/IOPMrootDomain:
// IOPMDeepIdleSupported = true
// IOPMSystemSleepType = 7
// PMStatusCode = ?
//
//
// In config ACPI, _LID to XLID
// Find:     5F4C4944 00
// Replace:  584C4944 00
//
// Name (_S3, ......
// In config ACPI, _S3 to XS3
// Find:     5F53335F
// Replace:  5853335F
//
DefinitionBlock("", "SSDT", 2, "X1C6", "_IDLE", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0.LPCB.EC.XWAC, MethodObj) // 0 Arguments
    External (_GPE.XL6D, MethodObj) // 0 Arguments
    External (RRBF, FieldUnitObj)
    External (XLTP, IntObj)
    External (_SB.LID, DeviceObj)
    External (_SB.SLPB, DeviceObj)
    External (_SB.PWRB, DeviceObj)
    External (_SB.PCI0.XHC, DeviceObj)
    External (_SB.PCI0.HDAS, DeviceObj)

    Scope (_SB)
    {
        Method (LPS0, 0, NotSerialized)
        {                    
            Debug = "LPS0()"

            Return (One)
        }
    }
    
    Scope (_GPE)
    {
        Method (LXEN, 0, NotSerialized)
        {
            Debug = "LXEN()"

            Return (One)
        }
        
        Method (_L6D, 0, Serialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            If (OSDW ())
            {
                Debug = "_L6D() start"

                Notify (\_SB.PWRB, 0x02) // Device Wake
                \_GPE.XL6D()

                Debug = "_L6D() end"
            }
            Else
            {
                \_GPE.XL6D()
            }
        }

        Method (_L17, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Debug = "_L17() start"
            
            Local0 = \_SB.PCI0.LPCB.EC.XWAC ()
            \RRBF = Local0
            Sleep (0x0A)

            Debug = Local0

            If ((Local0 & 0x02)){
                Debug = "_L17:0x02"
            }

            If ((Local0 & 0x04))
            {
                Debug = "_L17:0x04"
                Notify (\_SB.LID, 0x02) // Device Wake
            }

            If ((Local0 & 0x08))
            {
                Debug = "_L17:0x08"
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            If ((Local0 & 0x10))
            {
                Debug = "_L17:0x10"
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            If ((Local0 & 0x40)){
                Debug = "_L17:0x40"
            }

            If ((Local0 & 0x80))
            {
                Debug = "_L17:0x80"
                Notify (\_SB.SLPB, 0x02) // Device Wake
            }

            Debug = "_L17 end"
        }
    }

    // // AOAC wake
    External(_SB.PCI0.LPCB.EC._Q2A, MethodObj)
    External(_SB.PCI0.LPCB, DeviceObj)

    Scope (_SB.PCI0.LPCB)
    {
        If (OSDW ())
        {
            // Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            // {
            //     Debug = "LPCB:_S0W"

            //     Return (0x03)
            // }
            
            Method (_PS0, 0, Serialized)
            {
                Debug = "LPCB:_PS0"
                Debug = "XLTP: "
                Debug = XLTP

                If (XLTP != Zero)
                {
                    Debug = "XLTP is not ZERO"
                }

                \_GPE._L17()

                Notify (\_SB.LID, 0x02) // Device Wake
            }

            Method (_PS3, 0, Serialized)
            {
                Debug = "LPCB:_PS3"
            }
        }
    }
}
