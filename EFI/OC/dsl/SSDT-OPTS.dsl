DefinitionBlock ("", "SSDT", 2, "X1C6", "_OPTS", 0x00000000)
{
    External (OSDW, MethodObj)    // 0 Arguments
    External (DTGP, MethodObj)    // 5 Arguments
    External (ZINI, MethodObj)    // 0 Arguments

    External (HPTE, FieldUnitObj)
    External (WNTF, IntObj)
    // External (GPEN, FieldUnitObj)
    External (DPTF, FieldUnitObj)
    External (TATC, FieldUnitObj)
    External (OSYS, FieldUnitObj)

    // USB-C 3.1?
    External (USTC, FieldUnitObj)

    External (SADE, FieldUnitObj)
    External (_SB.PCI0.GFX0.GSSE, FieldUnitObj)

    Scope (\)
    {
        If (OSDW())
        {
            // disable HPET. It shouldn't be needed on modern systems anyway and is also disabled in genuine OSX
            HPTE = Zero

            // Enables DYTC, Lenovos thermal solution. Can be controlled by YogaSMC
            WNTF = One

            // Enable GPIO for the Touchscreen
            // GPEN = One

            // Disable DPTF, we use DYTC!
            DPTF = Zero

            // Disable B0D4
            SADE = Zero

            // CPU Interrupt storm?
            \_SB.PCI0.GFX0.GSSE = Zero
        }

        Method (_TTS, 1, NotSerialized)
        {
            Debug = "_TTS() called with Arg0:"
            Debug = Arg0
        }
    }

    External (\_SB.PCI0, DeviceObj)

    Scope (\_SB.PCI0)
    {
        Method (OINI, 0, NotSerialized)  // _INI: Initialize
        {
            If (OSDW())
            {
                // Debug = "Patching OSYS to Darwin"
                
                // Enables, among other things, the I2C-Device for the touchscreen
                OSYS = 0x2710

                Debug = USTC
            }

            ZINI()
        }
    }

    // https://github.com/daliansky/OC-little/blob/master/06-%E6%B7%BB%E5%8A%A0%E7%BC%BA%E5%A4%B1%E7%9A%84%E9%83%A8%E4%BB%B6/SSDT-MCHC.dsl
    External (_SB.PCI0, DeviceObj)

    Scope (_SB.PCI0)
    {
        Device (MCHC)
        {
            Name (_ADR, Zero)

            Method (_STA, 0, NotSerialized)
            {
                If (OSDW())
                {
                    Return (0x0F)
                }
                
                Return (Zero)
            }
        }
    }

    Scope (_SB)
    {
        // https://github.com/daliansky/OC-little/blob/master/06-%E6%B7%BB%E5%8A%A0%E7%BC%BA%E5%A4%B1%E7%9A%84%E9%83%A8%E4%BB%B6/SSDT-PWRB.dsl
        Device (_SB.PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Return (Zero)
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }

    External (_SB.PCI0.LPCB.EC.AC, DeviceObj)

    // Patching AC-Device so that AppleACPIACAdapter-driver loads.
    Scope (\_SB.PCI0.LPCB.EC.AC)
    {
        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
        {
            If (OSDW ())
            {
                Return (Package (0x02)
                {
                    0x6F, 
                    0x04
                })
            }
   
            Return (Package (0x02)
            {
                0x6F, 
                0x03
            })
        }
    }

    // https://github.com/daliansky/OC-little/blob/master/06-%E6%B7%BB%E5%8A%A0%E7%BC%BA%E5%A4%B1%E7%9A%84%E9%83%A8%E4%BB%B6/SSDT-DMAC.dsl
    External(_SB.PCI0.LPCB, DeviceObj)

    Scope (_SB.PCI0.LPCB)
    {
        Device (DMAC)
        {
            Name (_HID, EisaId ("PNP0200"))

            Name (_CRS, ResourceTemplate ()
            {
                IO (Decode16,
                    0x0000,             // Range Minimum
                    0x0000,             // Range Maximum
                    0x01,               // Alignment
                    0x20,               // Length
                    )
                IO (Decode16,
                    0x0081,             // Range Minimum
                    0x0081,             // Range Maximum
                    0x01,               // Alignment
                    0x11,               // Length
                    )
                IO (Decode16,
                    0x0093,             // Range Minimum
                    0x0093,             // Range Maximum
                    0x01,               // Alignment
                    0x0D,               // Length
                    )
                IO (Decode16,
                    0x00C0,             // Range Minimum
                    0x00C0,             // Range Maximum
                    0x01,               // Alignment
                    0x20,               // Length
                    )
                DMA (Compatibility, NotBusMaster, Transfer8_16, )
                    {4}
            })

            Method (_STA, 0, NotSerialized)
            {
                If (OSDW())
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }

    External(_SB.PCI0.LPCB, DeviceObj)
    Scope (_SB.PCI0.LPCB)
    {
        Device (PMCR)
        {
            Name (_HID, EisaId ("APP9876"))
            Name (_CRS, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite,
                    0xFE000000,
                    0x00010000 
                    )

            })
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }
}
