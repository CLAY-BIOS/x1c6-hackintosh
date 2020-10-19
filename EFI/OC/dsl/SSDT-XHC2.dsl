/**
 * USB 3.1
 */
DefinitionBlock ("", "SSDT", 2, "X1C6 ", "_XHC2", 0x00001000)
{
    /* Support methods */
    External (DTGP, MethodObj)
    External (OSDW, MethodObj)                        // OS Is Darwin?

    External (U2OP, IntObj)

    External (_SB.PCI0.RP09.RUSB, IntObj)
    External (_SB.PCI0.RP09.GXCI, FieldUnitObj)
    External (_SB.PCI0.RP09.UGIO, MethodObj)
    External (_SB.PCI0.RP09.UPSB.DSB2, DeviceObj)
    External (_SB.PCI0.RP09.UPSB.PCED, MethodObj)
    External (_SB.PCI0.RP09.UPSB.MDUV, IntObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.PCIA, FieldUnitObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.IIP3, FieldUnitObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.PRSR, FieldUnitObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.LACR, FieldUnitObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.LACT, FieldUnitObj)
    External (_SB.PCI0.RP09.UPSB.DSB2.LTRN, FieldUnitObj)

    Scope (_SB.PCI0.RP09.UPSB.DSB2)
    {
        Device (XHC2)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (SDPC, Zero)
            OperationRegion (A1E0, PCI_Config, Zero, 0x40)
            Field (A1E0, ByteAcc, NoLock, Preserve)
            {
                AVND,   32, 
                BMIE,   3, 
                Offset (0x18), 
                PRIB,   8, 
                SECB,   8, 
                SUBB,   8, 
                Offset (0x1E), 
                    ,   13, 
                MABT,   1
            }

            /**
             * PCI Enable downstream
             */
            Method (PCED, 0, Serialized)
            {
                Debug = "XHC2:PCED"
                Debug = "XHC2:PCED - enable GPIO"

                \_SB.PCI0.RP09.GXCI = One

                // this powers up both TBT and USB when needed
                If (\_SB.PCI0.RP09.UGIO () != Zero)
                {
                    Debug = "XHC2:PCED - GPIOs changed, restored = true"
                    \_SB.PCI0.RP09.UPSB.DSB2.PRSR = One
                }

                // Do some link training
                Local0 = Zero
                Local1 = Zero
                Local5 = (Timer + 10000000)

                Debug = "XHC2:PCED - restored flag, THUNDERBOLT_PCI_LINK_MGMT_DEVICE.PRSR"
                Debug = \_SB.PCI0.RP09.UPSB.DSB2.PRSR

                If (\_SB.PCI0.RP09.UPSB.DSB2.PRSR != Zero)
                {
                    Debug = "XHC2:PCED - Wait for power up"
                    Debug = "XHC2:PCED - Wait for downstream bridge to appear"

                    Local5 = (Timer + 10000000)

                    While (Timer <= Local5)
                    {
                        Debug = "XHC2:PCED - Wait for link training..."
                        If (\_SB.PCI0.RP09.UPSB.DSB2.LACR == Zero)
                        {
                            If (\_SB.PCI0.RP09.UPSB.DSB2.LTRN != One)
                            {
                                Debug = "XHC2:PCED - Link training cleared"
                                Break
                            }
                        }
                        ElseIf ((\_SB.PCI0.RP09.UPSB.DSB2.LTRN != One) && (\_SB.PCI0.RP09.UPSB.DSB2.LACT == One))
                        {
                            Debug = "XHC2:PCED - Link training cleared and link is active"
                            Break
                        }

                        Sleep (10)
                    }

                    Sleep (150)
                }

                \_SB.PCI0.RP09.UPSB.DSB2.PRSR = Zero

                While (Timer <= Local5)
                {
                    Debug = "XHC2:PCED - Wait for config space..."
                    If (\_SB.PCI0.RP09.UPSB.DSB2.XHC2.AVND != 0xFFFFFFFF)
                    {
                        Debug = "XHC2:PCED - Read VID/DID"
                        \_SB.PCI0.RP09.UPSB.DSB2.PCIA = One
                        Break
                    }

                    Sleep (10)
                }

                \_SB.PCI0.RP09.UPSB.DSB2.IIP3 = Zero
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (U2OP == One)
                {
                    Local0 = Package (0x06)
                        {
                            "USBBusNumber", 
                            Zero, 
                            "AAPL,xhci-clock-id", 
                            One, 
                            "UsbCompanionControllerPresent", 
                            One
                        }
                }
                Else
                {
                    Local0 = Package (0x04)
                        {
                            "USBBusNumber", 
                            Zero, 
                            "AAPL,xhci-clock-id", 
                            One
                        }
                }

                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }

            Name (HS, Package (0x01)
            {
                "XHC"
            })
            Name (FS, Package (0x01)
            {
                "XHC"
            })
            Name (LS, Package (0x01)
            {
                "XHC"
            })

            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                Return (Package (0x02)
                {
                    0x6D, 
                    0x04
                })
            }

            Method (_PS0, 0, Serialized)  // _PS0: Power State 0
            {
                If (OSDW ())
                {
                    PCED ()
                }
            }

            Method (_PS3, 0, Serialized)  // _PS3: Power State 3
            {
            }

            /**
                * Run Time Power Check
                * Called by XHC driver when idle
                */
            Method (RTPC, 1, Serialized)
            {
                Debug = "XHC2:RTPC called with args:"
                Debug = Arg0

                If (OSDW ())
                {
                    If (Arg0 <= One)
                    {
                        \_SB.PCI0.RP09.RUSB = Arg0
                    }
                }

                Return (Zero)
            }

            /**
                * USB cable check
                * Called by XHC driver to check cable status
                * Used as idle hint.
                */
            Method (MODU, 0, Serialized)
            {
                Debug = "XHC2:MODU - return = "
                Debug = \_SB.PCI0.RP09.UPSB.MDUV

                Return (\_SB.PCI0.RP09.UPSB.MDUV)
            }

            Device (RHUB)
            {
                Name (_ADR, Zero)  // _ADR: Address

                Device (SSP1)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                    Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                    {
                        ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "UNKNOWN",
                            PLD_VerticalPosition   = "UPPER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "UNKNOWN",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x0,
                            PLD_EjectRequired      = 0x0,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0,
                            PLD_VerticalOffset     = 0x0,
                            PLD_HorizontalOffset   = 0x0)
                    })
                    Name (HS, Package (0x02)
                    {
                        "XHC2", 
                        0x03
                    })
                    Name (FS, Package (0x02)
                    {
                        "XHC2", 
                        0x03
                    })
                    Name (LS, Package (0x02)
                    {
                        "XHC2", 
                        0x03
                    })
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        If (U2OP == One)
                        {
                            Local0 = Package (0x04)
                                {
                                    "UsbCPortNumber", 
                                    One, 
                                    "UsbCompanionPortPresent", 
                                    One
                                }
                        }
                        Else
                        {
                            Local0 = Package (0x02)
                                {
                                    "UsbCPortNumber", 
                                    One
                                }
                        }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Device (SSP2)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                    Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                    {
                        ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "UNKNOWN",
                            PLD_VerticalPosition   = "UPPER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "UNKNOWN",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x0,
                            PLD_EjectRequired      = 0x0,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0,
                            PLD_VerticalOffset     = 0x0,
                            PLD_HorizontalOffset   = 0x0)
                    })

                    Name (HS, Package (0x02)
                    {
                        "XHC2", 
                        0x04
                    })
                    Name (FS, Package (0x02)
                    {
                        "XHC2", 
                        0x04
                    })
                    Name (LS, Package (0x02)
                    {
                        "XHC2", 
                        0x04
                    })
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        If (U2OP == One)
                        {
                            Local0 = Package (0x04)
                                {
                                    "UsbCPortNumber", 
                                    0x02, 
                                    "UsbCompanionPortPresent", 
                                    One
                                }
                        }
                        Else
                        {
                            Local0 = Package (0x02)
                                {
                                    "UsbCPortNumber", 
                                    0x02
                                }
                        }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Device (HS01)
                {
                    Name (_ADR, 0x01)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x08, 
                        Zero, 
                        Zero
                    })
                    Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                    {
                        ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "UNKNOWN",
                            PLD_VerticalPosition   = "UPPER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "UNKNOWN",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x0,
                            PLD_EjectRequired      = 0x0,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0,
                            PLD_VerticalOffset     = 0x0,
                            PLD_HorizontalOffset   = 0x0)
                    })
                }

                Device (HS02)
                {
                    Name (_ADR, 0x02)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x08, 
                        Zero, 
                        Zero
                    })
                    Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                    {
                        ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "UNKNOWN",
                            PLD_VerticalPosition   = "UPPER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "UNKNOWN",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x0,
                            PLD_EjectRequired      = 0x0,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0,
                            PLD_VerticalOffset     = 0x0,
                            PLD_HorizontalOffset   = 0x0)

                    })
                }
            }
        }
    }
}