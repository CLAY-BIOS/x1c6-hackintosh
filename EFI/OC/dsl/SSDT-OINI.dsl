// Reference: https://github.com/tianocore/edk2-platforms/blob/master/Platform/Intel/KabylakeOpenBoardPkg/Include/Acpi/GlobalNvs.asl
DefinitionBlock ("", "SSDT", 2, "X1C6", "_OINI", 0x00001000)
{
    External (\_SB.PCI0, DeviceObj)

    External (OSYS, FieldUnitObj) // OS Identifier
    External (STY0, FieldUnitObj) // S3 Enabled?
    External (S0ID, FieldUnitObj) // S0 enabled
    External (SADE, FieldUnitObj) // B0D4 

    External (VIGD, FieldUnitObj) // Smth with Video/Backlight
    External (TBAS, FieldUnitObj) // TB
    External (TBTS, FieldUnitObj) // Thunderbolt(TM) support
    External (TNAT, FieldUnitObj) // TbtNativeOsHotPlus
    External (TWIN, FieldUnitObj) // TB Windows native
    External (TBSE, FieldUnitObj) // Thunderbolt(TM) Root port selector
    External (RTD3, FieldUnitObj) // Runtime D3 enabled?
    External (UCSI, FieldUnitObj)
    External (USTC, FieldUnitObj) // USB-C 3.1?
    External (USME, FieldUnitObj)
    
    External (_SB.PCI0.LPCB.EC.DCBD, FieldUnitObj) // Bluetooth Enabled?
    
    External (APIC, FieldUnitObj) // APIC Enabled by SBIOS (APIC Enabled = 1)
    External (TCNT, FieldUnitObj) // Number of Enabled Threads
    External (NEXP, FieldUnitObj) // Native PCIE Setup Value

    External (SDS8, FieldUnitObj) // Blth-Uart
    External (SMD8, FieldUnitObj)
    
    External (RTVM, FieldUnitObj) // Precondition for VMON()/VMOF - Whats this?

    External (SS1, IntObj)
    External (SS2, IntObj)
    External (SS3, IntObj)
    External (SS4, IntObj)

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
                // OSYS = 0x2710

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

                // HPM USB-C PD
                Debug = "UCSI: "
                Debug = UCSI

                // TB USB Ports? If enabled usb-c-ports on XHC1
                Debug = "TBAS: "
                Debug = TBAS

                Debug = "TBTS: "
                Debug = TBTS

                Debug = "DCBD: "
                Debug = \_SB.PCI0.LPCB.EC.DCBD

                Debug = "SDS8: "
                Debug = SDS8

                Debug = "SMD8: "
                Debug = SMD8

                // TB Compagnion. If = Zero, Ports on original TB
                Debug = "USME: "
                Debug = USME

                // TB USB Ports? If enabled usb-c-ports on XHC2
                Debug = "USTC: "
                Debug = USTC

                If (\_SB.PCI0.LPCB.EC.DCBD == One)
                {
                    Debug = "Bluetooth enabled"
                }

                If (RTD3 == One)
                {
                    Debug = "Runtime D3 support enabled"
                }

                If (S0ID == One)
                {
                    Debug = "Low Power S0 Idle Enabled"
                }

                If (STY0 == Zero)
                {
                    Debug = "S3 enabled"
                }
                Else
                {
                    Debug = "S3 disabled"

                    If (((S0ID == One) || (OSYS >= 0x07DF)))
                    {
                        Debug = "Modern Standby enabled"
                    }
                }

                // // Shutdown TPM
                // If (CondRefOf (\_SB.TPM.PTS))
                // {
                //     \_SB.TPM.PTS (0x03)
                // }

                Debug = "GPRW: "

                Local0 = (SS1 << 0x01)
                Local0 |= (SS2 << 0x02)
                Local0 |= (SS3 << 0x03)
                Local0 |= (SS4 << 0x04)

                Debug = Local0
            }

            ZINI()
        }
    }
}