DefinitionBlock ("", "SSDT", 2, "X1C6", "_PTS", 0x00001000)
{
    External (ZPTS, MethodObj) // 1 Arguments
    External (_SB.PCI0.RP05.UPSB.LSTX, MethodObj) // 2 Arguments

    Scope (\)
    {
        Method (_PTS, 1, NotSerialized)
        {
           Debug = "_PTS start: Arg0"
           Debug = Arg0

           \ZPTS(Arg0)

            If (Arg0 >= 0x05)
            {
                // If TB-ACPI implemented and loaded, hook sleep of it
                If (CondRefOf (\_SB.PCI0.RP05.UPSB.LSTX))
                {
                    Debug = "_PTS: LSTX"
                    \_SB.PCI0.RP05.UPSB.LSTX (Zero, One)
                    \_SB.PCI0.RP05.UPSB.LSTX (One, One)
                }
            }

           Debug = "_PTS end"
        }
    }
}