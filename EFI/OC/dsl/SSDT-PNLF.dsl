DefinitionBlock ("", "SSDT", 2, "X1C6", "_PNLF", 0x00001000)
{
    External (_SB_.PCI0.GFX0, DeviceObj)

    External (OSDW, MethodObj) // 0 Arguments

    Scope (_SB_.PCI0.GFX0)
    {
        Device (PNLF)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name (_CID, "backlight")  // _CID: Compatible ID
            Name (_UID, 0x10)  // _UID: Unique ID

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0B)
                }

                Return (Zero)
            }
        }
    }
}