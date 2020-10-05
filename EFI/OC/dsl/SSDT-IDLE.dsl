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
DefinitionBlock("", "SSDT", 2, "X1C6", "_IDLE", 0)
{
    External (XS3, IntObj)

    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            // Name (_S0, Package (0x03)  // _S0_: S0 System State
            // {
            //     Zero, 
            //     Zero, 
            //     Zero
            // })
    
            Scope (_SB)
            {
                Method (LPS0, 0, NotSerialized)
                {
                    Debug = "LPS0"
                    Return (One)
                }
            }
            
            Scope (_GPE)
            {
                Method (LXEN, 0, NotSerialized)
                {
                        Debug = "LXEN"
                        Return (One)
                }
            }
        }
        Else
        {
            Method (_S3, 0, NotSerialized)
            {
                Return(XS3)
            }
        }        
    }

    // AOAC wake
    External(_SB.PCI0.LPCB, DeviceObj)
    External(_SB.PCI0.LPCB.EC.AC, DeviceObj)
    External(_SB.LID.XLID, MethodObj)

    Scope (_SB.PCI0.LPCB)
    {
        If (_OSI ("Darwin"))
        {
            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                Debug = "LPCB:_S0W"

                Return (0x03)
            }
            
            Method (_PS0, 0, Serialized)
            {
                Debug = "LPCB:_PS0"

                \_SB.LID.AOAC = 1
                Notify (\_SB.LID, 0x80) 
                Sleep (200)
                \_SB.LID.AOAC = 0
                Notify (\_SB.PCI0.LPCB.EC.AC, 0x80) // Status Change
            }

            Method (_PS3, 0, Serialized)
            {
            }
        }
    }

    //path:_SB.PCI0.LPCB.H_EC.LID0._LID
    External(_SB.LID, DeviceObj)
    External(_SB.LID.XLID, MethodObj)
    
    Scope (_SB.LID)
    {
        Name (AOAC, Zero)

        Method (_LID, 0, NotSerialized)
        {
            If ((_OSI ("Darwin") && (AOAC == One)))
            {
                Debug = "AOAC LID One"
                Return (One)
            }
            Else
            {
                Debug = "Normal LID"
                Return (\_SB.LID.XLID())
            }
        }
    }
}
