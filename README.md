# macOS on Thinkpad X1 Carbon 6th Generation, Experimental branch

[![macOS](https://img.shields.io/badge/macOS-Big_Sur_RC_2-yellow.svg)](https://www.apple.com/de/macos/big-sur-preview/)
[![BIOS](https://img.shields.io/badge/BIOS-1.49-blue)](https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x1-carbon-6th-gen-type-20kh-20kg/downloads/driver-list/component?name=BIOS%2FUEFI)
[![OpenCore](https://img.shields.io/badge/OpenCore-0.6.3-green)](https://github.com/acidanthera/OpenCorePkg)
[![LICENSE](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)

<img align="right" src="https://i.imgur.com/I3yUS4Q.png" alt="Critter" width="300">

> ## Warning & Notice

### This is an experimental branch for the Thinkpad X1 Carbon Generation 6-Repo by @tylernguyen.
### Experimental branch - no docs, no guarantees. Untested - full of bugs - but maybe with new features? :)

Here be dragons! Docs are missing or incorrect at this point. May not boot at all.
I am not responsible for any damages you may cause.

> ## Differencies to the original repo

<img align="right" src="https://i.imgur.com/eQN9MWO.png" alt="Thunderbolt native" width="300">

* **Native TB-Hotplug-support with complete power-management. See [SSDT-TB](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-TB.dsl). Disables the ICM and loads native OSX drivers without patched TB-FW. Enables PM for TB. Broken hotplug for USB 3.1 Gen2 for now.**
* Native ACPI-implementation of USB 2.0/3.0. See [SSDT-XHC1](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-XHC1.dsl)/[SSDT-XHC2](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-XHC2.dsl)
* Complete, Battery reimplementation without ACPI-patching or any dependencies besides the one SSDT. Integrates [Battery Information Supplement](https://github.com/acidanthera/VirtualSMC/blob/master/Docs/Battery%20Information%20Supplement.md), supports multi-battery-setups and should be compatible with almost all x-/t-series Thinkpads. See [SSDT-BATX](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-BATX.dsl)
* Enables the possibility to run "Sleep State: [Windows]" in Bios to have "modern standby" on Windows and proper S3-sleep on OSX. See [SSDT-SLEEP](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-SLEEP.dsl)
* Updated for Big Sur
* Cleans up much old and unneeded stuff
* Enabled DYTC (Lenovo thermal management)
* Disables DPTF (Intel thermal management)
* Integration of [YogaSMC](https://github.com/zhen-zen/YogaSMC)
* Patches for the X1C6 Touchscreen (via [@voodooI2C](https://gitter.im/alexandred/VoodooI2C))
* Hibernation (hibernatemode 25)
* Relative comprehensive debug-setup for ACPI-development. See [Config-Debug](https://github.com/benbender/x1c6-hackintosh/blob/experimental/optional/Config-Debug.plist)
* ~(Beta) "native" ACPI-API for broadcom-wifi-cards to handle complete power-down of the PCIe-interface if the OS requests it. As on genuine machines. See [SSDT-ARPT](https://github.com/benbender/x1c6-hackintosh/blob/experimental/EFI/OC/dsl/SSDT-ARPT.dsl)~
* ~(WIP) Enables DeepSleep on S3 for OSX~
* ~(WIP) Support for S0-DeepIdle (or ACPI-Sleep/Modern Standby/Always on always connected, however you wanna call it)~ doesnt seem to be helpful in terms of suspend power draw
* ...

#### Expects patched bios, ~patched TB-firmware~ and latest versions of everything. Big Sur only atm.

> ## CREDITS

Standing on the shoulders of giants! Based on the works of many great people.

* [@tylernguyen](https://github.com/tylernguyen/x1c6-hackintosh) for his great prior art which is ripped apart here ;)
* [@zhen-zen](https://github.com/zhen-zen) for YogaSMC and all the big and small improvements everywhere
* [@fewtarius](https://github.com/fewtarius) for his help & work to get perfectly working audio on this machine (even if the speakers stay crap)
* [@Colton-Ko](https://github.com/Colton-Ko/macOS-ThinkPad-X1C6) for the great features template.  
* [@stevezhengshiqi](https://github.com/stevezhengshiqi) for the one-key-cpufriend script.  
* [@corpnewt](https://github.com/corpnewt) for GibMacOS, EFIMount, and USBMap.  
* [@Sniki](https://github.com/Sniki) and [@goodwin](https://github.com/goodwin) for ALCPlugFix.  
* [@xzhih](https://github.com/xzhih) for one-key-hidpi.  
* [@daliansky](https://github.com/daliansky) for various hotpatches.  
* [@velaar](https://github.com/velaar) for your continual support and contributions.  
* [@Porco-Rosso](https://github.com/Porco-Rosso) putting up with my requests to test repo changes.  
* [@MSzturc](https://github.com/MSzturc) for adding my requested features to ThinkpadAssistant.  
* paranoidbashthot and \x for the BIOS mod to unlocked Intel Advance Menu.


The greatest thank you and appreciation to [@Acidanthera](https://github.com/acidanthera), without whom's work, none of this would be possible.

And to everyone else who supports and uses my project.

Please let me know if I missed you.

