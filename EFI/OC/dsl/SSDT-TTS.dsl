DefinitionBlock ("", "SSDT", 2, "X1C6", "_TTS", 0x00001000)
{
    Scope (\)
    {
        Name (XLTP, Zero)  // SLTP on Apple, Name already used on TP

        Method (_TTS, 1, NotSerialized)  // _TTS: Transition To State
        {
            Debug = "_TTS() called with Arg0:"
            Debug = Arg0

            XLTP = Arg0
        }
    }
}