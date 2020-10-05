// GPI0 enable
DefinitionBlock("", "SSDT", 2, "X1C6", "_GPIO", 0)
{
    External(GPEN, FieldUnitObj)
    
    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            GPEN = 1
        }
    }
}
//EOF