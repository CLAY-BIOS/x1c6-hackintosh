DefinitionBlock ("", "SSDT", 2, "X1C6", "_PMCR", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0, DeviceObj) // 0 Arguments

    Scope (\_SB.PCI0)
    {
        Device (PMCR)
        {
            Name (_ADR, 0x001F0002)  // _ADR: Address


            Method (_STA, 0, NotSerialized)
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }

    External (_SB.PCI0.PPMC, DeviceObj) // 0 Arguments

    Scope (\_SB.PCI0.PPMC)
    {
        OperationRegion (PMCB, PCI_Config, Zero, 0x0100)
        Field (PMCB, AnyAcc, NoLock, Preserve)
        {
            VDID,   32, 
            Offset (0x40), 
            Offset (0x41), 
            ACBA,   8, 
            Offset (0x48), 
                ,   12, 
            PWBA,   20
        }
    }

}