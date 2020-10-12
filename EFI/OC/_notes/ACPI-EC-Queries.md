## Battery

### _Q22

### _Q4A

/* Battery 0 attach/detach */
Method(_Q4A, 0, NotSerialized)
{
	Notify(BAT0, 0x81)
}

### _Q4B

/* Battery 0 state change */
Method(_Q4B, 0, NotSerialized)
{
	Notify(BAT0, 0x80)
}

###  _Q4C

/* Battery 1 attach/detach */
Method(_Q4C, 0, NotSerialized)
{
	Notify(BAT1, 0x81)
}

### _Q4D

/* Battery 1 state change */
Method(_Q4D, 0, NotSerialized)
{
	Notify(BAT1, 0x80)
}

### _Q24

Battery 0 critical 
Notify(BAT0, 0x80)

### _Q25

Battery 1 critical 
Notify(BAT1, 0x80)








## Keyboard

### _Q6A

Key F4 - Mic Mute

### _Q14

Display Backlight up

### _Q15

Display Backlight down

### _Q16

Key F7 - Dual Display

### _Q64

Key F8 - Network

### _Q66

Key F9 - Settings

### _Q60

Key F10 - Bluetooth

### _Q61

Key F11 - Keyboard

### _Q62

Key F12 - Star

### _Q74

Key FNLock

### _Q1F

Toggle Keyboard Backlight



## Power

### _Q2A

Lid open

### _Q2B

Lid close

### _Q13

Sleep Button

### _Q26

AC status change: present 

### _Q27

AC status change: not present

## Misc

### _Q1C

### _Q1D


Sleep?

### _Q62

### _Q65


### _Q3D

### _Q48

### _Q49

### _Q7F

### _Q46

### _Q3B

### _Q4F

### _Q2F