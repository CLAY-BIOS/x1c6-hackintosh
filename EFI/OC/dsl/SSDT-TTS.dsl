DefinitionBlock ("", "SSDT", 1, "X1C6", "_TTS", 0x00001000)
{
    Name (XLTP, Zero)  // SLTP on Apple, Name already used on TP

    Method (_TTS, 1, NotSerialized)  // _TTS: Transition To State
    {
        Debug = "_TTS() called with Arg0:"
        Debug = Arg0

        XLTP = Arg0
    }
}