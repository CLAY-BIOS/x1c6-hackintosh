// https://dortania.github.io/OpenCore-Post-Install/usb/misc/power.html
DefinitionBlock ("", "SSDT", 2, "X1C6", "_USBX", 0x00001000)
{
    External (_SB_.PCI0.LPCB, DeviceObj)

    External (DTGP, MethodObj) // 4 Arguments
    External (OSDW, MethodObj) // 0 Arguments

    Scope (\_SB)
    {
        Device (USBX)
        {
            Name (_ADR, Zero)  // _ADR: Address

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b"))
                {
                    Local0 = Package (0x08)
                    {
                        "kUSBSleepPowerSupply",
                        0x13EC,
                        "kUSBSleepPortCurrentLimit",
                        0x0834,
                        "kUSBWakePowerSupply",
                        0x13EC,
                        "kUSBWakePortCurrentLimit",
                        0x0834
                    }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }

                Return (Zero)
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
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