/*
 * XCPM power management compatibility table.
 */
DefinitionBlock ("", "SSDT", 2, "X1C6", "_PLUG", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    //
    // The CPU device name. (PR00 here)
    //
    External (_PR.PR00, ProcessorObj)

    Scope (\_PR.PR00)
    {
        Method (_DSM, 4, NotSerialized)
        {
            If (LEqual (Arg2, Zero))
            {
                Return (Buffer (One)
                {
                    0x03                                           
                })
            }

            Return (Package (0x02)
            {
                //
                // Inject plugin-type = 0x01 to load X86*.kext
                //
                "plugin-type", 
                One
       })
    }
    }
}