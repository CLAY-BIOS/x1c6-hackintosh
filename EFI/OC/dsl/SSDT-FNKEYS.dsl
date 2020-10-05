DefinitionBlock("", "SSDT", 2, "X1C6", "_KEYS", 0x00000000)
{
    External (\_SB.PCI0.LPCB.EC, DeviceObj)
                                    
    Scope (_SB.PCI0.LPCB.EC)
    {
        External (\_SB.PCI0.LPCB.KBD, DeviceObj)

        External (\_SB.PCI0.LPCB.EC.XQ6A, MethodObj) // F4 - Mic Mute
        External (\_SB.PCI0.LPCB.EC.XQ15, MethodObj) // F5
        External (\_SB.PCI0.LPCB.EC.XQ14, MethodObj) // F6
        External (\_SB.PCI0.LPCB.EC.XQ16, MethodObj) // F7
        External (\_SB.PCI0.LPCB.EC.XQ64, MethodObj) // F8
        External (\_SB.PCI0.LPCB.EC.XQ66, MethodObj) // F9
        External (\_SB.PCI0.LPCB.EC.XQ60, MethodObj) // F10
        External (\_SB.PCI0.LPCB.EC.XQ61, MethodObj) // F11
        External (\_SB.PCI0.LPCB.EC.XQ62, MethodObj) // F12
        External (\_SB.PCI0.LPCB.EC.XQ74, MethodObj) // FnLock
        External (\_SB.PCI0.LPCB.EC.XQ1F, MethodObj) // Keyboard Backlight (Fn+Space)

        External (\_SB.PCI0.LPCB.EC.HKEY.MMTS, MethodObj) // FnLock LED
        External (\_SB.PCI0.LPCB.EC.HKEY.MLCS, MethodObj) // F4 - Mic Mute LED
        External (\_SB.PCI0.LPCB.EC.HKEY.MHKQ, MethodObj) // Keyboard Backlight LED

        External (OSDW, MethodObj) // 0 Arguments

        // micMute LED
        Name (MICL, Zero)

        // Keyboard backlight
        Name (KEYL, Zero)

        // FnLock
        Name (FUNL, Zero)


        Method (_Q74, 0, NotSerialized) // FnLock (Fn + Esc)
        {
            // On OSX we handle the state ourselves
            If (OSDW())
            {
                FUNL = (FUNL + 1) % 2

                Switch (FUNL)
                {
                    Case (One) 
                    {
                        // Right Shift + F18
                        Notify (KBD, 0x012A)
                        Notify (KBD, 0x0369)
                        Notify (KBD, 0x01aa)

                        // Enable LED
                        \_SB.PCI0.LPCB.EC.HKEY.MHKQ (0x02)
                    }
                    Case (Zero)
                    {
                        // Left Shift + F18
                        Notify (KBD, 0x0136)
                        Notify (KBD, 0x0369)
                        Notify (KBD, 0x01b6)

                        // Disable LED
                        \_SB.PCI0.LPCB.EC.HKEY.MHKQ (Zero)
                    }
                }
            }
            Else
            {
                // Call original method.
                XQ74()
            }
        }

        // _Q6A - Microphone Mute
        Method (_Q6A, 0, NotSerialized) // F4 - Microphone Mute = F20
        {
            // On OSX we handle the state ourselves
            If (OSDW())
            {
                MICL = (MICL + 1) % 2
                
                Switch (MICL)
                {
                    Case (One) 
                    {
                        // Right Shift + F20
                        Notify (KBD, 0x0136)
                        Notify (KBD, 0x036B)
                        Notify (KBD, 0x01b6)
                        
                        // Enable LED
                        \_SB.PCI0.LPCB.EC.HKEY.MMTS (0x02)
                    }
                    Case (Zero) 
                    {
                        // Left Shift + F20
                        Notify (KBD, 0x012A)
                        Notify (KBD, 0x036B)
                        Notify (KBD, 0x01aa)
                        
                        // Disable LED
                        \_SB.PCI0.LPCB.EC.HKEY.MMTS (Zero)
                    }
                }
            }
            Else
            {
                // Call original method.
                XQ6A()
            }
        }


        Method (_Q15, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (_OSI ("Darwin"))
            {
                Notify (\_SB.PCI0.LPCB.KBD, 0x0405)
                Notify (\_SB.PCI0.LPCB.KBD, 0x20) // Reserved
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.XQ15 ()
            }
        }

        Method (_Q14, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (_OSI ("Darwin"))
            {
                Notify (\_SB.PCI0.LPCB.KBD, 0x0406)
                Notify (\_SB.PCI0.LPCB.KBD, 0x10) // Reserved
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.XQ14 ()
            }
        }



        Method (_Q16, 0, NotSerialized) // F7 - Dual Display = F16
        {
            If (OSDW())
            {
                Notify(KBD, 0x0367)
            }

            // Call original method.
            XQ16()
        }
        
        Method (_Q64, 0, NotSerialized) // F8 - Network = F17
        {
            If (OSDW())
            {
                Notify(KBD, 0x0368)
            }

            // Call original method.
            XQ64()
        }
        
        Method (_Q66, 0, NotSerialized) // F9 - Settings = F18
        {
            If (OSDW())
            {
                Notify(KBD, 0x0369)
            }

            // Call original method.
            XQ66()
        }
        
        Method (_Q60, 0, NotSerialized) // F10 - Bluetooth
        {

            If (OSDW())
            {
                // Left Shift + F17
                Notify (KBD, 0x012A)
                Notify (KBD, 0x0368)
                Notify (KBD, 0x01AA)
            }

            // Call original method.
            XQ60()
        }
        
        Method (_Q61, 0, NotSerialized) // F11 - Keyboard
        {
            If (OSDW())
            {
                // Send a down event for the Control key (scancode 1d), then a one-shot event (down then up) for
                // the up arrow key (scancode 0e 48), and finally an up event for the Control key (break scancode 9d).
                // This is picked up by VoodooPS2 and sent to macOS as the Control+Up key combo.
                Notify (KBD, 0x011D)
                Notify (KBD, 0x0448)
                Notify (KBD, 0x019D)
            }

            // Call original method.
            XQ61()
        }
        
        Method (_Q62, 0, NotSerialized) // F12 - Star = F19
        {
            If (OSDW())
            {
                Notify(KBD, 0x036A)
            }

            // Call original method.
            XQ62()
        }
        
        // _Q1F - (Fn+Space) Toggle Keyboard Backlight.
        Method (_Q1F, 0, NotSerialized) // cycle keyboard backlight
        {
            // On OSX we handle the state ourselves
            If (OSDW())
          	{
                KEYL = (KEYL + 1) % 3
                
                Switch (KEYL)
                {
                    Case (Zero)
                    {
                        // Left Shift + F16.
                        Notify (KBD, 0x012a)
                        Notify (KBD, 0x0367)
                        Notify (KBD, 0x01aa)
                        
                        // bright to off
                        \_SB.PCI0.LPCB.EC.HKEY.MLCS (Zero)
                    }
                    Case (One)
                    {
                        // Right Shift + F16.
                        Notify (KBD, 0x0136)
                        Notify (KBD, 0x0367)
                        Notify (KBD, 0x01b6)
                        
                        //  Off to dim
                        \_SB.PCI0.LPCB.EC.HKEY.MLCS (One)
                    }
                    Case (0x02)
                    {
                        // Left Shift + F19.
                        Notify (KBD, 0x012a)
                        Notify (KBD, 0x036a)
                        Notify (KBD, 0x01aa)
                        
                        //  dim to bright
                        \_SB.PCI0.LPCB.EC.HKEY.MLCS (0x02)
                    }
                }
            }
            Else
            {
                // Call original _Q6A method.
                XQ1F ()
            }
        }
    }
}
//EOF
