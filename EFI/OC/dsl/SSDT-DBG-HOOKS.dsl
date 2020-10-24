DefinitionBlock ("", "SSDT", 2, "X1C6", "_HOOKS", 0x00001000)
{
    External (_SB.PCI0.LPCB.EC, DeviceObj)

    // EC Events
    External (_SB.PCI0.LPCB.EC.XQ1C, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ1D, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ1F, MethodObj) // Keyboard Backlight Event
    External (_SB.PCI0.LPCB.EC.XQ2A, MethodObj) // LID Open Event
    External (_SB.PCI0.LPCB.EC.XQ2B, MethodObj) // LID Close Event
    External (_SB.PCI0.LPCB.EC.XQ2C, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ2D, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ2F, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ3B, MethodObj) // Wifi ???
    External (_SB.PCI0.LPCB.EC.XQ3D, MethodObj) // Empty
    External (_SB.PCI0.LPCB.EC.XQ3F, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ4A, MethodObj) // Battery Attach/Detach Event
    External (_SB.PCI0.LPCB.EC.XQ4B, MethodObj) // Battery State Change Event
    External (_SB.PCI0.LPCB.EC.XQ4E, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ4F, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ6A, MethodObj) // KBD MicMute Event (F4)
    External (_SB.PCI0.LPCB.EC.XQ7F, MethodObj) // "Fatal()" ?
    External (_SB.PCI0.LPCB.EC.XQ13, MethodObj) // KBD Sleepbutton Event (FN+4)
    External (_SB.PCI0.LPCB.EC.XQ14, MethodObj) // KBD Brightness up Event (F6)
    External (_SB.PCI0.LPCB.EC.XQ15, MethodObj) // KBD Brightness down Event (F5)
    External (_SB.PCI0.LPCB.EC.XQ16, MethodObj) // Next display Event (F7)
    External (_SB.PCI0.LPCB.EC.XQ19, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ22, MethodObj) // Battery at critical low state Event
    External (_SB.PCI0.LPCB.EC.XQ24, MethodObj) // Battery
    External (_SB.PCI0.LPCB.EC.XQ26, MethodObj) // AC Power Connected
    External (_SB.PCI0.LPCB.EC.XQ27, MethodObj) // AC Power Removed
    External (_SB.PCI0.LPCB.EC.XQ38, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ40, MethodObj) // Thermal/DYTC ???
    External (_SB.PCI0.LPCB.EC.XQ41, MethodObj) // Global Wireless Disable/Enable Event ?
    External (_SB.PCI0.LPCB.EC.XQ43, MethodObj) // KBD Audio Mute Event (F1)
    External (_SB.PCI0.LPCB.EC.XQ45, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ46, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ48, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ49, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ60, MethodObj) // KBD Bluetooth Event (F10)
    External (_SB.PCI0.LPCB.EC.XQ61, MethodObj) // KBD Keyboard Event (F11)
    External (_SB.PCI0.LPCB.EC.XQ62, MethodObj) // KBD Star Event (F12)
    External (_SB.PCI0.LPCB.EC.XQ63, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ64, MethodObj) // KBD Wifi Event (F8)
    External (_SB.PCI0.LPCB.EC.XQ65, MethodObj) // ???
    External (_SB.PCI0.LPCB.EC.XQ66, MethodObj) // KBD Settings Event (F9)
    External (_SB.PCI0.LPCB.EC.XQ70, MethodObj) // Fan ???
    External (_SB.PCI0.LPCB.EC.XQ72, MethodObj) // Fan ???
    External (_SB.PCI0.LPCB.EC.XQ73, MethodObj) // Fan ???
    External (_SB.PCI0.LPCB.EC.XQ74, MethodObj) // KBD FNLock Event

    // GPE Events (General Purpose)
    External (_GPE.XL17, MethodObj) // ???
    External (_GPE.XL27, MethodObj) // ???
    External (_GPE.XL61, MethodObj) // ???
    External (_GPE.XL62, MethodObj) // ???
    External (_GPE.XL66, MethodObj) // ???
    External (_GPE.XL69, MethodObj) // ???
    // External (_GPE.XL6D, MethodObj) // ???
    External (_GPE.XL6F, MethodObj) // Thunderbolt HotPlug


    Scope (\_SB.PCI0.LPCB.EC)
    {
        // MHKK
        Method (_Q1C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q1C (???)"

            XQ1C()
        }

        // ???
        Method (_Q1D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q1D (???)"

            XQ1D()
        }

        // Keyboard Backlight Event
        Method (_Q1F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q1F (Keyboard Backlight Event)"

            XQ1F()
        }

        // LID Open Event
        Method (_Q2A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q2A (LID Open Event)"

            XQ2A()
        }

        // LID Close Event
        Method (_Q2B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q2B (LID Close Event)"

            XQ2B()
        }

        // ???
        Method (_Q2C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q2C (???)"

            XQ2C()
        }

        // ???
        Method (_Q2D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q2D (???)"

            XQ2D()
        }

        // ???
        Method (_Q2F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q2F (???)"

            XQ2F()
        }

        // Wifi ???
        Method (_Q3B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q3B (Wifi ???)"

            XQ3B()
        }

        // Empty???
        Method (_Q3D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q3D (Empty???)"

            XQ3D()
        }

        // ???
        Method (_Q3F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q3F (???)"

            XQ3F()
        }

        // Battery Attach/Detach Event
        Method (_Q4A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q4A (Battery Attach/Detach Event)"

            XQ4A()
        }

        // Battery State Change Event
        Method (_Q4B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q4B (Battery State Change Event)"

            XQ4B()
        }

        // ???
        Method (_Q4E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q4E (???)"

            XQ4E()
        }

        // ???
        Method (_Q4F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q4F (???)"

            XQ4F()
        }

        // KBD MicMute Event (F4)
        Method (_Q6A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q6A (KBD MicMute Event - F4)"

            XQ6A()
        }

        // "Fatal()" ?
        Method (_Q7F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q7F (FATAL())"

            XQ7F()
        }

        // KBD Sleepbutton Event (FN+4)
        Method (_Q13, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q13 (KBD Sleepbutton Event - FN+4)"

            XQ13()
        }

        // KBD Brightness up Event (F4)
        Method (_Q14, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q14 (KBD Brightness up Event - F4)"

            XQ14()
        }

        // KBD Brightness down Event (F5)
        Method (_Q15, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q15 (KBD Brightness down Event - F5)"

            XQ15()
        }

        // KBD Next display Event
        Method (_Q16, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q16 (Next display Event)"

            XQ16()
        }

        // ???
        Method (_Q19, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q19 (???)"

            XQ19()
        }

        // Battery at critical low state Event
        Method (_Q22, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q22 (Battery at critical low state Event)"

            XQ22()
        }

        // Battery
        Method (_Q24, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q24 (Battery)"

            XQ24()
        }

        // AC Power Connected Event
        Method (_Q26, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q26 (AC Power Connected Event)"

            XQ26()
        }

        // AC Power Removed Event
        Method (_Q27, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q27 (AC Power Removed Event)"

            XQ27()
        }

        // ???
        Method (_Q38, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q38 (???)"

            XQ38()
        }

        // Thermal/DYTC ???
        Method (_Q40, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q40 (Thermal/DYTC???)"

            XQ40()
        }

        // ???
        Method (_Q41, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q41 (???)"

            XQ41()
        }

        // KBD Audio Mute Event (F1)
        Method (_Q43, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q43 (KBD Audio Mute Event - F1)"

            XQ43()
        }

        // ???
        Method (_Q45, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q45 (???)"

            XQ45()
        }

        // ???
        Method (_Q46, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q46 (???)"

            XQ46()
        }

        // ???
        Method (_Q48, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q48 (???)"

            XQ48()
        }

        // ???
        Method (_Q49, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q49 (???)"

            XQ49()
        }

        // ???
        Method (_Q60, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q60 (???)"

            XQ60()
        }

        // ???
        Method (_Q61, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q61 (???)"

            XQ61()
        }

        // ???
        Method (_Q62, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q62 (???)"

            XQ62()
        }

        // ???
        Method (_Q63, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q63 (???)"

            XQ63()
        }

        // ???
        Method (_Q64, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q64 (???)"

            XQ64()
        }

        // ???
        Method (_Q65, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q65 (???)"

            XQ65()
        }

        // ???
        Method (_Q66, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q66 (???)"

            XQ66()
        }

        // Fan???
        Method (_Q70, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q70 (Fan???)"

            XQ70()
        }

        // Fan ???
        Method (_Q72, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q72 (Fan???)"

            XQ72()
        }

        // Fan ???
        Method (_Q73, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q73 (Fan???)"

            XQ73()
        }

        // Keyboard FNLock Event
        Method (_Q74, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            Debug = "HOOKS: EC:_Q74 (Keyboard FNLock Event)"

            XQ73()
        }
    }


    Scope (_GPE)
    {
        Method (_L17, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Debug = "HOOKS: _L17() start"
            
            XL17()
        }

        Method (_L27, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
        {
            Debug = "HOOKS: _L27() start"
            
            XL27()
        }

        Method (_L61, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Debug = "HOOKS: _L61()"
            
            XL61()
        }


        Method (_L62, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Debug = "HOOKS: _L62()"
            
            XL62()
        }

        Method (_L66, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Debug = "HOOKS: _L66() start (iGPU)"
            
            XL66()
        }

        // PCI Wake
        Method (_L69, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Debug = "HOOKS: _L69() start (PCI)"

            XL69()
        }

        // Device Wake - already hooked
        // Method (_L6D, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        // {
        //     Debug = "HOOKS: _L6D() (Device wake"

        //     XL6D()
        // }

        // TB HotPlug
        Method (_L6F, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            Debug = "HOOKS: _L6F() (TB HotPlug)"

            XL6F()
        }
    }
}
/*
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q1C to XQ1C</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExQw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExQw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q1D to XQ1D</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExRA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExRA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q1F to XQ1F</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExRg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExRg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>

    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q2A to XQ2A</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyQQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WF    EyQQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q2B to XQ2B</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyQg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyQg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q2C to XQ2C</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyQw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyQw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q2D to XQ2D</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyRA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyRA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q2F to XQ2F</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyRg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyRg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q3B to XQ3B</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EzQg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEzQg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q3D to XQ3D</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EzRA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEzRA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q3F to XQ3F</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EzRg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEzRg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q4A to XQ4A</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0QQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0QQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q4B to XQ4B</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0Qg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0Qg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q4E to XQ4E</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0RQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0RQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q4F to XQ4F</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0Rg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0Rg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q6A to XQ6A</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2QQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2QQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q7F to XQ7F</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E3Rg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE3Rg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q13 to XQ13</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExMw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExMw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q14 to XQ14</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExNA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExNA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q15 to XQ15</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExNQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExNQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q16 to XQ16</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExNg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExNg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q19 to XQ19</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1ExOQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFExOQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q22 to XQ22</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyMg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyMg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q24 to XQ24</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyNA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyNA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q26 to XQ26</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyNg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyNg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q27 to XQ27</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EyNw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEyNw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q38 to XQ38</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1EzOA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFEzOA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q40 to XQ40</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0MA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0MA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q41 to XQ41</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0MQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0MQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q43 to XQ43</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0Mw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0Mw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q45 to XQ45</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0NQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0NQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q46 to XQ46</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0Ng==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0Ng==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q48 to XQ48</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0OA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0OA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q49 to XQ49</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E0OQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE0OQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q60 to XQ60</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2MA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2MA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q61 to XQ61</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2MQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2MQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q62 to XQ62</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2Mg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2Mg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q63 to XQ63</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2Mw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2Mw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
    		<dict>
				<key>Comment</key>
				<string>HOOKS: _Q64 to XQ64</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2NA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2NA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q65 to XQ65</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2NQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2NQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q66 to XQ66</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E2Ng==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE2Ng==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q70 to XQ70</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E3MA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE3MA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q72 to XQ72</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E3Mg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE3Mg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q73 to XQ73</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E3Mw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE3Mw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _Q74 to XQ74</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X1E3NA==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WFE3NA==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L17 to XL17</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0wxNw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEwxNw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L27 to XL27</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0wyNw==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEwyNw==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L61 to XL61</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0w2MQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEw2MQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L62 to XL62</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0w2Mg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEw2Mg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L66 to XL66</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0w2Ng==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEw2Ng==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L69 to XL69</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0w2OQ==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEw2OQ==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
			<dict>
				<key>Comment</key>
				<string>HOOKS: _L6F to XL6F (Thunderbolt 3 Hotplug GPE)</string>
				<key>Count</key>
				<integer>0</integer>
				<key>Enabled</key>
				<true/>
				<key>Find</key>
				<data>X0w2Rg==</data>
				<key>Limit</key>
				<integer>0</integer>
				<key>Mask</key>
				<data></data>
				<key>OemTableId</key>
				<data></data>
				<key>Replace</key>
				<data>WEw2Rg==</data>
				<key>ReplaceMask</key>
				<data></data>
				<key>Skip</key>
				<integer>0</integer>
				<key>TableLength</key>
				<integer>0</integer>
				<key>TableSignature</key>
				<data>RFNEVA==</data>
			</dict>
*/