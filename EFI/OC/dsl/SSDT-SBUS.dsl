/*
 * SMBus compatibility table.
 *
 * Needed to load com.apple.driver.AppleSMBusController
 */
DefinitionBlock ("", "SSDT", 2, "X1C6", "_SBUS", 0x00001000)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.SBUS, DeviceObj)

    External(OSDW, MethodObj) // 0 Arguments

    Scope (_SB.PCI0.SBUS)
    {
        Device (BUS0)
        {
            Name (_CID, "smbus")  // _CID: Compatible ID
            Name (_ADR, Zero)  // _ADR: Address

            // Device (DVL0)
            // {
            //     Name (_ADR, 0x57)  // _ADR: Address
            //     Name (_CID, "diagsvault")  // _CID: Compatible ID

            //     Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            //     {
            //         If (!Arg2)
            //         {
            //             Return (Buffer (One)
            //             {
            //                 0x57                                             // W
            //             })
            //         }

            //         Return (Package (0x02)
            //         {
            //             "address", 
            //             0x57
            //         })
            //     }
            // }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Device (BUS1)
        {
            Name (_CID, "smbus")  // _CID: Compatible ID
            Name (_ADR, One)  // _ADR: Address

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }
}