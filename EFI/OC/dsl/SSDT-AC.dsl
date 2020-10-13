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

    External (_SB.PCI0.LPCB.EC, DeviceObj)
    External (_SB.PCI0.LPCB.EC.AC, DeviceObj)
    External (_SB.PCI0.LPCB.EC.H8DR, FieldUnitObj)

    // Patching AC-Device so that AppleACPIACAdapter-driver loads.
    // https://github.com/khronokernel/DarwinDumped/blob/b6d91cf4a5bdf1d4860add87cf6464839b92d5bb/MacBookPro/MacBookPro14%2C1/ACPI%20Tables/DSL/DSDT.dsl#L7965
    // Named ADP1 on Mac
    Scope (\_SB.PCI0.LPCB.EC)
    {
        Name (EWAI, Zero)
        Name (EWAR, Zero)
        Name (WKRS, Zero)

        Method (WAKE, 0, NotSerialized)
        {
            Debug = "EC:WAKE()"

            If (H8DR)
            {
                Debug = "EC Wake reason ="
                Debug = WKRS /* \_SB_.PCI0.LPCB.EC__.WKRS */
                Debug = EWAI /* \_SB_.PCI0.LPCB.EC__.EWAI */
                Debug = EWAR /* \_SB_.PCI0.LPCB.EC__.EWAR */

                Return (WKRS) /* \_SB_.PCI0.LPCB.EC__.WKRS */
            }
            Else
            {
                Debug = "WAKE(), EC not ready"
                Return (Zero)
            }
        }
    }
    
    Scope (\_SB.PCI0.LPCB.EC.AC)
    {
        Name (WK00, One)

        Method (SWAK, 1, NotSerialized)
        {
            Debug = "AC:SWAK() - Arg0: "
            Debug = Arg0

            WK00 = (Arg0 & 0x03)

            If (!WK00)
            {
                Debug = "WK00 = One"
                WK00 = One
            }
        }

        Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
        {
            0x17, 
            0x04
        })

        Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
        {
            // Debug = "AC:_PSW()"

            If (OSDW () && H8DR)
            {
                If (Arg0)
                {
                    Debug = "AC:_PSW() - set EWAI/EWAR = One"

                    If (WK00 & One)
                    {
                        \_SB.PCI0.LPCB.EC.EWAI = One
                    }

                    If (WK00 & 0x02)
                    {
                        \_SB.PCI0.LPCB.EC.EWAR = One
                    }
                }
                Else
                {
                    // Debug = "AC:_PSW() - set EWAI/EWAR = Zero"

                    \_SB.PCI0.LPCB.EC.EWAI = Zero
                    \_SB.PCI0.LPCB.EC.EWAR = Zero
                }
            }
        }
    }
}