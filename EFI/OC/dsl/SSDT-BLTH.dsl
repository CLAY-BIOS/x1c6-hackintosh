DefinitionBlock ("", "SSDT", 2, "X1C6 ", "_BLTH", 0x00001000)
{
    External (_SB_.PCI0, DeviceObj)
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments

    Scope (_SB.PCI0)
    {
        Device (URT0)
        {
            Name (_ADR, 0x001E0000)  // _ADR: Address
            Name (RBUF, ResourceTemplate ()
            {
                Interrupt (ResourceConsumer, Level, ActiveLow, Shared, ,, )
                {
                    0x00000014,
                }
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b"))
                {
                    Local0 = Package (0x02)
                        {
                            "uart-channel-number", 
                            Buffer (0x08)
                            {
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* ........ */
                            }
                        }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }

                Return (Zero)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Return (RBUF) /* \_SB_.PCI0.URT0.RBUF */
            }

            Device (BLTH)
            {
                // Name (_HID, EisaId ("BCM2E7C"))  // _HID: Hardware ID
                Name (_HID, EisaId ("BCM2E40"))  // _HID: Hardware ID
                Name (_CID, "apple-uart-blth")  // _CID: Compatible ID
                Name (_UID, One)  // _UID: Unique ID
                Name (_ADR, Zero)  // _ADR: Address
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

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
                    Else
                    {
                        Return (Package (0x02)
                        {
                            0x6F, 
                            0x03
                        })
                    }
                }

                Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                {
                    Name (UBUF, ResourceTemplate ()
                    {
                        UartSerialBusV2 (0x0001C200, DataBitsEight, StopBitsOne,
                            0xC0, LittleEndian, ParityTypeNone, FlowControlHardware,
                            0x0020, 0x0020, "\\_SB.PCI0.URT0",
                            0x00, ResourceProducer, , Exclusive,
                            )
                    })
                    Name (ABUF, ResourceTemplate ()
                    {
                    })
                    If (!OSDW ())
                    {
                        Return (UBUF) /* \_SB_.PCI0.URT0.BLTH._CRS.UBUF */
                    }

                    Return (ABUF) /* \_SB_.PCI0.URT0.BLTH._CRS.ABUF */
                }

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    If (Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b"))
                    {
                        Local0 = Package (0x08)
                            {
                                "baud", 
                                Buffer (0x08)
                                {
                                        0xC0, 0xC6, 0x2D, 0x00, 0x00, 0x00, 0x00, 0x00   /* ..-..... */
                                }, 

                                "parity", 
                                Buffer (0x08)
                                {
                                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* ........ */
                                }, 

                                "dataBits", 
                                Buffer (0x08)
                                {
                                        0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* ........ */
                                }, 

                                "stopBits", 
                                Buffer (0x08)
                                {
                                        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   /* ........ */
                                }
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }

                    Return (Zero)
                }

                // Bluetooth Power up
                Method (BTPU, 0, Serialized)
                {
                    Debug = "BTH0:BTPU"
                    // ^^^LPCB.EC.BTPC = One
                    Sleep (0x0A)
                }

                // Bluetooth Power down
                Method (BTPD, 0, Serialized)
                {
                    Debug = "BTH0:BTPD"
                    // ^^^LPCB.EC.BTPC = Zero
                    Sleep (0x0A)
                }

                // Bluetooth reset
                Method (BTRS, 0, Serialized)
                {
                    Debug = "BTH0:BTRS"
                    BTPD ()
                    BTPU ()
                }

                // Bluetooth low power
                Method (BTLP, 1, Serialized)
                {
                    Debug = "BTH0:BTLP - Arg0"
                    Debug = Arg0

                    If (Arg0 == Zero)
                    {
                        // SGDI (0x02010002)
                    }

                    If (Arg0 == One)
                    {
                        // SGOV (0x02010002, Zero)
                        // SGDO (0x02010002)
                    }
                }
            }
        }
    }
}