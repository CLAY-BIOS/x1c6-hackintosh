DefinitionBlock("", "SSDT", 2, "THKP", "_OFFTB", 0x00001000)
{
    // Force off TB
    External (_SB.PCI0.RP01.LDIS, FieldUnitObj)
    External (_SB.PCI0.RP05.LDIS, FieldUnitObj)
    External (_SB.PCI0.RP09.LDIS, FieldUnitObj)
    
    External (TBTS, FieldUnitObj)
    External (TBSE, FieldUnitObj)
    External (TWIN, FieldUnitObj)
    External (TRD3, IntObj)

    Scope (\)
    {
        // Disable TB in OSX if not in bios-assist-mode
        If (_OSI ("Darwin") && TWIN != 0x00 && TBTS == 0x01)
        {
            TRD3 = One

            If (TBSE == 0x01) 
            {
                Debug = "OFFTB - Disable Thunderbolt @ RP01"

                \_SB.PCI0.RP01.LDIS = One
            }

            If (TBSE == 0x05) 
            {
                Debug = "OFFTB - Disable Thunderbolt @ RP05"

                \_SB.PCI0.RP05.LDIS = One
            }


            If (TBSE == 0x09) 
            {
                Debug = "OFFTB - Disable Thunderbolt @ RP09"

                \_SB.PCI0.RP09.LDIS = One
            }

            \TBTS = Zero
            Sleep (100)

            TRD3 = Zero
        }
    }
}
// EOF
