/*
 * XCPM power management compatibility table.
 */
DefinitionBlock ("", "SSDT", 2, "X1C6", "_PLUG", 0x00003000)
{
    External (_PR.PR00, ProcessorObj)
    External (DTGP, MethodObj)

    Scope (_PR.PR00)
    {
        Method (_DSM, 4, NotSerialized)
        {
            Local0 = Package (0x02)
                {
                    "plugin-type", 
                    One
                }
            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
            Return (Local0)
        }
    }
}
