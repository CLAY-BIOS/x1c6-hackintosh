//
// SSDT-SSD0
// Revision 2
//
// Copyleft (c) 2020 by bb. No rights reserved.
//
//
// Abstract:
// Stub for now. 
//
// Changelog:
// Revision 2 - Removed experiments
// Revision 1 - Initial implementation
//
DefinitionBlock ("", "SSDT", 2, "THKP", "_SSD0", 0x00002000)
{
    // External method from SSDT-UTILS.dsl
    External (OSDW, MethodObj) // 0 Arguments
    External (DTGP, MethodObj) // 5 Arguments

    External (_SB.PCI0.RP05, DeviceObj)
    External (_SB.PCI0.RP05.PXSX, DeviceObj)


    // SSD
    Scope (_SB.PCI0.RP05)
    {
        Method (_PS3, 0, Serialized)  // _PS3: Power State 3
        {
            If (OSDW ())
            {
                Debug = "SSD0._PS3"
            }
        }

        Method (_PS0, 0, Serialized)  // _PS0: Power State 0
        {
            If (OSDW ())
            {

                Debug = "SSD0:_PS0"
            }
        }

        Scope (PXSX)
        {
            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
            {
                Return (Zero)
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Local0 = Package ()
                    {
                        "model", "NVME SSD",
                        "device_type", "Non-Volatile memory controller",
                        "deep-idle", One, 
                        "use-msi", One, 
                        "nvme-LPSR-during-S3-S4", One
                    }

                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }
}
// EOF
