
//
// Add missing methods and stuff from macbookpro14,1's iGPU-device
//
// Mostly testing and evaluation for now
//
DefinitionBlock ("", "SSDT", 2, "THKP", "_IGPU", 0x00001000)
{
    // Common utils from SSDT-UTILS.dsl
    External (DTGP, MethodObj) // 5 Arguments
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0, DeviceObj)
    External (_SB.PCI0.GFX0, DeviceObj)

    External (PWRM, FieldUnitObj)

    Scope (\)
    {
        OperationRegion (PMSX, SystemMemory, PWRM, 0x0350)
        Field (PMSX, DWordAcc, NoLock, Preserve)
        {
            Offset (0x31C), 
                ,   13, 
            LVME,   1, 
                ,   8, 
            XTAL,   1
        }
    }

    Scope (_SB.PCI0.GFX0)
    {
        Method (_PS0, 0, Serialized)  // _PS0: Power State 0
        {
            Debug = "GFX0:_PS0"

            If (OSDW ())
            {
                LVME = Zero
                // ^^LPCB.EC.LVME = Zero
                XTAL = One
            }
        }

        Method (_PS3, 0, Serialized)  // _PS3: Power State 3
        {
            Debug = "GFX0:_PS3"

            If (OSDW ())
            {
                XTAL = Zero
                // ^^LPCB.EC.LVME = One
                LVME = One
            }
        }

        Method (PCPC, 0, NotSerialized)
        {
            Debug = "GFX0:PCPC"
        }

        Method (PAPR, 0, NotSerialized)
        {
            Debug = "GFX0:PAPR"
            
            Return (Zero)
        }
    }


    External (_SB.PCI0.GFX0.GSCI, MethodObj) // 0 Arguments
    External (_SB.PCI0.GFX0.GSSE, FieldUnitObj)
    External (_SB.PCI0.GFX0.GEFC, FieldUnitObj)
    External (_SB.PCI0.GFX0.SCIE, FieldUnitObj)
    External (GSMI, FieldUnitObj)
    External (SCIS, FieldUnitObj)

    External (_GPE.XL66, MethodObj) // 0 Arguments

    Scope (_GPE)
    {
        // iGPU-wake
        // IGD OpRegion SCI event (see IGD OpRegion/Software SCI BIOS SPEC).
        // @SEE https://github.com/tianocore/edk2-platforms/blob/master/Platform/Intel/KabylakeOpenBoardPkg/Acpi/BoardAcpiDxe/Dsdt/Gpe.asl
        Method (_L66, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            If (OSDW ())
            {
                Debug = "GFX0:_L66 - GPE0_TCO_SCI_HANDLER - GFX Software SCI Event"
                Debug = Concatenate ("GFX0:_L66 - GSSE value = ", \_SB.PCI0.GFX0.GSSE)
                Debug = Concatenate ("GFX0:_L66 - GSMI value = ", GSMI)
                Debug = Concatenate ("GFX0:_L66 - SCIS value = ", SCIS)
                Debug = Concatenate ("GFX0:_L66 - Entry function code = ", \_SB.PCI0.GFX0.GEFC)

                If (\_SB.PCI0.GFX0.GSSE && !GSMI)
                {
                    Debug = "GFX0:_L66 - GPE0_TCO_SCI_HANDLER - Calling IGPU.GSCI() Method"
                    \_SB.PCI0.GFX0.GSCI ()
                }
                Else
                {
                    Debug = "GFX0:_L66 - GPE0_TCO_SCI_HANDLER - Not a GFX SW SCI Event"
                    \_SB.PCI0.GFX0.GEFC = Zero
                    SCIS = One
                    \_SB.PCI0.GFX0.GSSE = Zero
                    \_SB.PCI0.GFX0.SCIE = Zero
                }
            }
            Else
            {
                \_GPE.XL66 ()
            }
        }
    }
}
// EOF
    