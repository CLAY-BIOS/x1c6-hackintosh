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

    // // AOAC wake
    // External(_SB.PCI0.LPCB.EC._Q2A, MethodObj)
    // External(_SB.PCI0.LPCB.EC.AC, DeviceObj)
    // External(_SB.LID, DeviceObj)
    // External(_SB.PCI0.LPCB.EC.AC._PSR, MethodObj)
    // External(PWRS, FieldUnitObj)
    // External(_GPE._L17, MethodObj)

    External (OSDW, MethodObj) // 0 Arguments

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

                // \_SB.LID.AOAC = One
                // Notify (\_SB.LID, 0x80) 
                // Sleep (200)
                // \_SB.LID.AOAC = Zero
                //  \PWRS = \_SB.PCI0.LPCB.EC.AC._PSR ()

                // \_SB.PCI0.LPCB.EC._Q2A()
                // \_GPE._L17()
                // Notify (\_SB.LID, 0x80) // Status Change

                // Sleep (200)

                // Notify (\_SB.PCI0.LPCB.EC.AC, 0x80) // Status Change
            }

            Method (_PS3, 0, Serialized)
            {
                Debug = "LPCB:_PS3"
            }
        }
    }
}
