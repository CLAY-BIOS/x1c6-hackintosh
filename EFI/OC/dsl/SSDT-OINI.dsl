DefinitionBlock ("", "SSDT", 2, "X1C6", "_OINI", 0x00001000)
{
    External (\_SB.PCI0, DeviceObj)

    External (OSYS, FieldUnitObj) // OS Identifier
    External (STY0, FieldUnitObj) // S3 Enabled?
    External (S0ID, FieldUnitObj) // S0 enabled
    External (SADE, FieldUnitObj) // B0D4 

    External (VIGD, FieldUnitObj) // Smth with Video/Backlight
    External (SMD0, FieldUnitObj) // I2C0
    External (TBAS, FieldUnitObj) // TB
    External (TBTS, FieldUnitObj) // TB enabled?
    External (TWIN, FieldUnitObj) // Windows native TB
    External (UCSI, FieldUnitObj)
    External (USTC, FieldUnitObj) // USB-C 3.1?
    External (USME, FieldUnitObj)
    External (RTD3, FieldUnitObj) // Runtime D3 enabled?
    
    External (RTVM, FieldUnitObj) // Precondition for VMON()/VMOF - Whats this?


    // External (\_SB.TPM.PTS, MethodObj)

    External (OSDW, MethodObj)    // 0 Arguments
    External (DTGP, MethodObj)    // 5 Arguments
    External (ZINI, MethodObj)    // 0 Arguments

    Scope (\_SB.PCI0)
    {
        Method (OINI, 0, NotSerialized)  // _INI: Initialize
        {            
            If (OSDW ())
            {
                Debug = "PCI0:OINI"

                // Debug = "Patching OSYS to Darwin"
                
                // Set OSYS to Darwin, also enables windows-modernizations in ACPI
                OSYS = 0x2710

                Debug = "USTC: "
                Debug = USTC

                Debug = "STY0:"
                Debug = STY0

                Debug = "S0ID:"
                Debug = S0ID

                Debug = "OSYS:"
                Debug = OSYS

                Debug = "VIGD: "
                Debug = VIGD

                Debug = "RTVM: "
                Debug = RTVM

                Debug = "RTD3: "
                Debug = RTD3

                // UCSI = One

                // HPM USB-C PD
                Debug = "UCSI: "
                Debug = UCSI

                // TB USB Ports? If enabled usb-c-ports on XHC1
                Debug = "TBAS: "
                Debug = TBAS

                Debug = "TBTS: "
                Debug = TBTS

                // TBAS = One

                // TB Compagnion. If = Zero, Ports on original TB
                Debug = "USME: "
                Debug = USME

                // TB USB Ports? If enabled usb-c-ports on XHC2
                Debug = "USTC: "
                Debug = USTC

                // Custom I2C0
                Debug = "Old SMD0: "
                Debug = SMD0

                // SMD0 = 0x02

                If (((S0ID == One) || (OSYS >= 0x07DF)))
                {
                    Debug = "Modern Standby enabled"
                }

                // // Shutdown TPM
                // If (CondRefOf (\_SB.TPM.PTS))
                // {
                //     \_SB.TPM.PTS (0x03)
                // }
            }

            ZINI()
        }
    }
}