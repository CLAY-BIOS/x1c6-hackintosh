DefinitionBlock ("", "SSDT", 2, "X1C6", "_PM", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments
    External (DTGP, MethodObj) // 5 Arguments

    //
    // The CPU device name. (PR00 here)
    //
    External (_PR.PR00, ProcessorObj)

    /*
    * XCPM power management compatibility table.
    */
    Scope (\_PR.PR00)
    {
        Method (_DSM, 4, NotSerialized)
        {
            //
            // Inject plugin-type = 0x01 to load X86*.kext
            //
            Debug = "Writing plugin-type to Registry!"
            Local0 = Package (0x02)
                {
                    "plugin-type", 
                    One
                }
            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
            Return (Local0)
        }
    }

    External (_SB.PCI0, DeviceObj) // 0 Arguments

    Scope (\_SB.PCI0)
    {
        Device (PMCR)
        {
            Name (_ADR, 0x001F0002)  // _ADR: Address

            Method (_STA, 0, NotSerialized)
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }

    External (_SB.PCI0.PPMC, DeviceObj) // 0 Arguments

    Scope (\_SB.PCI0.PPMC)
    {
        Name (_DDN, "Power Management Controller")

        OperationRegion (PMCB, PCI_Config, Zero, 0x0100)
        Field (PMCB, AnyAcc, NoLock, Preserve)
        {
            VDID,   32, 
            Offset (0x40), 
            Offset (0x41), 
            ACBA,   8, 
            Offset (0x48), 
                ,   12, 
            PWBA,   20      /* PWRMBASE */
        }

        OperationRegion (PMCM, SystemMemory, ShiftLeft (PWBA, 12), 0x3f)
        Field (PMCM, DWordAcc, NoLock, Preserve)
        {
            Offset (0x1c),	/* PCH_PM_STS */
            , 24,
            PMFS, 1,	    /* PMC_MSG_FULL_STS */
            Offset (0x20),
            MPMC, 32,	    /* MTPMC */
            Offset (0x24),	/* PCH_PM_STS2 */
            , 20,
            UWAB, 1,	    /* USB2 Workaround Available */
        }
    }

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

        Field (PMSX, DWordAcc, NoLock, Preserve)
        {
            Offset (0x34C), 
                ,   21, 
            HCPG,   1
        }
    }
}