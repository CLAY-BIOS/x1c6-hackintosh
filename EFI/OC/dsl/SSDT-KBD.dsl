//
// (Optional) Fix keyboard-layout to be as windows-native as possible
//
// based on a german keyboard-layout.
//
//
DefinitionBlock ("", "SSDT", 2, "THKP", "_KBD", 0x00001000)
{
    // Change _SB.PCI0.LPCB.KBD if your PS2 keyboard is at a different ACPI path
    External(_SB.PCI0.LPCB.KBD, DeviceObj)

    Scope(_SB.PCI0.LPCB.KBD)
    {
        Name(RMCF, Package()
        {
            "Keyboard", Package()
            {
                "Swap command and option", ">n", // Disable key-swap

                // Disable that stupid $&!§
                "Custom PS2 Map", Package()
                {
                    Package() {},
                    "e037=64",  // PrtSc=F13
                },
            },
        })
    }
}
//EOF
