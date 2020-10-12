DefinitionBlock ("", "SSDT", 2, "X1C6", "_PWRB", 0x00001000)
{
    External (DTGP, MethodObj) // 4 Arguments
    External (OSDW, MethodObj) // 0 Arguments

    Scope (_SB)
    {
        // https://github.com/daliansky/OC-little/blob/master/06-%E6%B7%BB%E5%8A%A0%E7%BC%BA%E5%A4%B1%E7%9A%84%E9%83%A8%E4%BB%B6/SSDT-PWRB.dsl
        Device (PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Return (Zero)
            }

            // Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            // {
            //     If (Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b"))
            //     {
            //         Local0 = Package (0x04)
            //             {
            //                 "power-button-usage", 
            //                 Buffer (0x08)
            //                 {
            //                      0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* @....... */
            //                 }, 

            //                 "power-button-usagepage", 
            //                 Buffer (0x08)
            //                 {
            //                      0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* ........ */
            //                 }
            //             }
            //         DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
            //         Return (Local0)
            //     }

            //     Return (Zero)
            // }

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

