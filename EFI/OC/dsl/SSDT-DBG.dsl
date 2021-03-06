//
// Debug-helper to redirect ACPI's native ADGB()-helper to syslog
//
DefinitionBlock ("", "SSDT", 0, "THKP", "_DBG", 0x00001000)
{
    //
    // Many OEM ACPI implementations have a ADBG method which is used for debug
    // logging. In almost all cases, this function calls MDBG, which is
    // supposed to be defined in a ACPI debug SSDT (but is usually missing).
    // This should make ADBG functional.
    //
    // To enable ACPI debug logging in AppleACPIPlatform:
    // Add boot args: acpi_layer=0x8 acpi_level=0x2 debug=0x100
    // (https://pikeralpha.wordpress.com/2013/12/23/enabling-acpi-debugging/)
    //
    // To retrieve the ACPI debug output in macOS:
    // log show --last boot --predicate 'process == "kernel" AND senderImagePath CONTAINS "AppleACPIPlatform"' --style compact | awk '/ACPI Debug/{getline; getline; print}'
    //
    Method (XDBG, 1, NotSerialized)
    {
        Debug = Arg0
    }
}
// EOF
