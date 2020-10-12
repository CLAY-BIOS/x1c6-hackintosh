DefinitionBlock ("", "SSDT", 2, "X1C6", "_PMCR", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    Scope (\_SB)
    {
        Device (PMCR)
        {
            // Name (_ADR, 0x001F0002)  // _ADR: Address
            Name (_HID, EisaId ("APP9876"))

            Name (_CRS, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite,
                    0xFE000000,
                    0x00010000 
                    )
            })

            Method (_STA, 0, NotSerialized)
            {
                If (OSDW ())
                {
                    Return (0x0B)
                }

                Return (Zero)
            }
        }
    }
}