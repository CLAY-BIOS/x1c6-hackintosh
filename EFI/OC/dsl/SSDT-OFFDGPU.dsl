DefinitionBlock("", "SSDT", 2, "THKP", "_OFFDGPU", 0x00001000)
{
    External (_SB.PCI0.HGOF, MethodObj)    // 0 Arguments
    External (_SB.PCI0.RP01.LDIS, FieldUnitObj)
    External (_SB.PCI0.LPCB.DGRT, IntObj)
    External (_SB.PCI0.LPCB.DGON, IntObj)

     // Disable dGPU on PCIe-Level
    Scope (\)
    {
        If (_OSI ("Darwin") && CondRefOf (\_SB.PCI0.HGOF))
        {
            Debug = "OFFDGPU - Disable dGPU @ RP01"

            // Disable dGPU in OSX
            \_SB.PCI0.RP01.LDIS = One
            \_SB.PCI0.LPCB.DGRT = Zero
            \_SB.PCI0.LPCB.DGON = Zero

            Sleep (100)
        }
    }
}
// EOF
