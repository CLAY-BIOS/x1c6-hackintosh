/**
 * USB 3.0
 *
 * USBRtd3Supported?
 * 
 * https://github.com/coreboot/coreboot/blob/master/src/soc/intel/skylake/acpi/xhci.asl
 */
DefinitionBlock ("", "SSDT", 2, "X1C6 ", "_XHC", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments

    External (\_SB.PCI0.XHC, DeviceObj)

    External (\_SB.PCI0.XHC.RHUB, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS01, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS02, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS03, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS04, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS05, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS06, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS07, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS08, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS09, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS10, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS01, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS02, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS03, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS04, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS05, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS06, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.USR1, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.USR2, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU, MethodObj)

    External (\_SB.PCI0.XHC.PDBM, FieldUnitObj)
    External (\_SB.PCI0.XHC.MEMB, FieldUnitObj)
    External (\_SB.PCI0.XHC.D0D3, FieldUnitObj)
    External (\_SB.PCI0.XHC.DVID, FieldUnitObj)

    External (XLTP, IntObj) // XLTP on Apple, already used on TP

    External (PMFS, FieldUnitObj)
    External (MPMC, FieldUnitObj)
    External (UWAB, FieldUnitObj)
    External (TBAS, FieldUnitObj)

    Scope (\_SB.PCI0.XHC)
    {
        Name (U2OP, Zero) // use companion controller
        Name (SDPC, Zero)
        Name (SBAR, Zero)

        Method (RTPC, 1, Serialized)
        {
            Debug = "XHC:RTPC"

            Return (Zero)
        }

        Method (MODU, 0, Serialized)
        {
            Local0 = Zero

            // TB-Controler enabled?
            If (CondRefOf (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU))
            {
                // If enabled, check if any device is plugged in
                Local0 = \_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU ()
            }
            
            // Local0 = \_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU ()
            Local1 = Zero

            If ((Local0 == One) || (Local1 == One))
            {
                Local0 = One
            }
            ElseIf ((Local0 == 0xFF) || (Local1 == 0xFF))
            {
                Local0 = 0xFF
            }
            Else
            {
                Local0 = Zero
            }

            Debug = "XHC:MODU - Result:"
            Debug = Local0

            Return (Local0)
        }

        Scope (RHUB)
        {
            Scope (HS01) // right USB-A / USB 2.0 @ 480Mbit/s
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0x03, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS02) // left USB-A / USB 2.0 @ 480Mbit/s
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0x03, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            If (TBAS)
            {
                Scope (HS03) // usb 2 for usb-c ?
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x08, 
                        Zero, 
                        Zero
                    })

                    Name (SSP, Package (0x02)
                    {
                        "XHC2", 
                        One
                    })
                    Name (SS, Package (0x02)
                    {
                        "XHC2", 
                        One
                    })
                    
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x00) {}
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Scope (HS04) // usb 2 for usb-c ?
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x08, 
                        Zero, 
                        Zero
                    })

                    Name (SSP, Package (0x02)
                    {
                        "XHC2", 
                        0x02
                    })
                    Name (SS, Package (0x02)
                    {
                        "XHC2", 
                        0x02
                    })
                    
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x00) {}
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }
            }
            Else
            {
                Scope (HS03) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (HS04) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }
            }

            Scope (HS05) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS06) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS07) // bluetooth
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS08) // Webcam
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS09) // ?
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS10) // Touchscreen
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (USR1) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (USR2) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS01) // right USB-A / USB 3.0 @ 5Gbit/s
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0x03, 
                    Zero, 
                    Zero
                })

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (SS02) // left USB-A / USB 3.0 @ 5Gbit/s
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF,
                    0x03,
                    Zero, 
                    Zero
                })

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (SS03) // SD-Card
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (SS04) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS05) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS06) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }
        }

        Method (MBSD, 0, NotSerialized)
        {
            Return (One)
        }

        Name (SSP, Package (0x01)
        {
            "XHC2"
        })
        Name (SS, Package (0x01)
        {
            "XHC2"
        })
    }
}