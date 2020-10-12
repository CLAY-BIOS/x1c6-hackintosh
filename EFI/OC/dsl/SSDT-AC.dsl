/*
 * Loads up ... on AC-Adapter correctly
 *
 * \_SB_.PCI0.LPCB.EC__.HPAC is AC-state in EC
 * \PWRS is AC-state in ACPI
 * 
 */
DefinitionBlock ("", "SSDT", 2, "X1C6", "_AC", 0x00001000)
{
    External (OSDW, MethodObj) // 0 Arguments

    External (_SB.PCI0.LPCB.EC.AC, DeviceObj)

    // Patching AC-Device so that AppleACPIACAdapter-driver loads.
    // https://github.com/khronokernel/DarwinDumped/blob/b6d91cf4a5bdf1d4860add87cf6464839b92d5bb/MacBookPro/MacBookPro14%2C1/ACPI%20Tables/DSL/DSDT.dsl#L7965
    // Named ADP1 on Mac
    Scope (\_SB.PCI0.LPCB.EC.AC)
    {
        Name (WK00, One)

        Method (SWAK, 1, NotSerialized)
        {
            Debug = "AC:SWAK"

            WK00 = (Arg0 & 0x03)

            If (!WK00)
            {
                WK00 = One
            }
        }

        // Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        // {
        //     If (OSDW ())
        //     {
        //         Return (Package (0x02)
        //         {
        //             0x6D, 
        //             0x04
        //         })
        //     }
        // }

        // Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
        // {
        //     Debug = "AC:_PSW"
        //     // Not needed?
        //     If (OSDW ())
        //     {
        //         If (^^PCI0.LPCB.EC.ECOK)
        //         {
        //             If (Arg0)
        //             {
        //                 If (WK00 & One)
        //                 {
        //                     ^^PCI0.LPCB.EC.EWAI = One
        //                 }

        //                 If (WK00 & 0x02)
        //                 {
        //                     ^^PCI0.LPCB.EC.EWAR = One
        //                 }
        //             }
        //             Else
        //             {
        //                 ^^PCI0.LPCB.EC.EWAI = Zero
        //                 ^^PCI0.LPCB.EC.EWAR = Zero
        //             }
        //         }
        //     }
        // }
    }
}