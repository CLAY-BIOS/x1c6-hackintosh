/**
 * Needed to load com.apple.driver.AppleSMBusController
 */
DefinitionBlock ("", "SSDT", 2, "X1C6", "_MCHC", 0x00001000)
{
    External (_SB.PCI0, DeviceObj)

    External (OSDW, MethodObj) // 0 Arguments

    Scope (_SB.PCI0)
    {
        // https://github.com/daliansky/OC-little/blob/master/06-%E6%B7%BB%E5%8A%A0%E7%BC%BA%E5%A4%B1%E7%9A%84%E9%83%A8%E4%BB%B6/SSDT-MCHC.dsl
        // https://github.com/khronokernel/DarwinDumped/blob/b6d91cf4a5bdf1d4860add87cf6464839b92d5bb/MacBookPro/MacBookPro14%2C1/ACPI%20Tables/DSL/DSDT.dsl#L2645
        Device (MCHC)
        {
            Name (_ADR, Zero)

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
}