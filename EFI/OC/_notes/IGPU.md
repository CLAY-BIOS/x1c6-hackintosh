# Debugging

On macOS 10.15 and newer, AppleGVA debugging is disabled by default, if you get a generic error while running VDADecoderChecker you can enable debugging with the following:

defaults write com.apple.AppleGVA enableSyslog -boolean true
And to undo this once done:

defaults delete com.apple.AppleGVA enableSyslog

Source: https://dortania.github.io/OpenCore-Post-Install/universal/drm.html#testing-hardware-acceleration-and-decoding

# DRM

DRM-Chart: https://github.com/acidanthera/WhateverGreen/blob/master/Manual/FAQ.Chart.md

# Backlight

http://github.com/RehabMan/OS-X-ACPI-Backlight
https://github.com/daliansky/OC-little/tree/master/05-注入设备/05-2-PNLF注入方法
applbkl=0


# Color Banding

Only known working Framebuffer without banding: Skylake/1912

* https://www.eizo.be/monitor-test/
* https://www.tonymacx86.com/threads/help-weird-ring-like-blur-and-images-in-mojave.262566/