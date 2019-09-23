# iMac G3 Gaming PC Conversion

Parts and instructions to convert an iMac G3 into a powerful, modern gaming PC.



## About

This is a project to convert a year ~2000 Apple iMac G3 DV (slot load, Graphite) computer into a fully fledged gaming PC, which will mainly serve as a portable LAN box and VR machine.

This concept certainly isn't new, but I'm hoping to set this project apart by reducing the amount of destructive case modifications to almost zero, and by packing in significantly more power without melting everything. This will be accomplished by using 3D printed and laser cut acrylic brackets, in order to make everything more "bolt-on" and reduce the need to cut/drill the actual case. 

Currently the project is a messy WIP project dump of OpenSCAD files and STLs that will gradually be cleaned up as the project progresses. Unfortunately the initial commit is occurring somewhat late so a lot of early project history is gone. I'm committing this mainly as a backup of what I've done, and a way to version my changes, but hopefully it will eventually be an instructional kit that can be downloaded and followed (with included 3D printed models).



## Overview of replacement components

### Display

HYDIS HV150UX2-100. It is a 15" LCD LVDS laptop display, that is UXGA (1600x1200), 4:3, and LED backlit. It's a slightly more expensive upgrade to the HV150UX1, which is CCFL backlit. It is powered by a M.NT68676.2A.11486 controller board, which accepts HDMI and 12V power. 

The M.NT68676.2A.11486 is readily available on eBay as a drop-in controller for the HV150UX1, however it has to be slightly modified to work with the HV150UX2. Mainly, the LVDS connector has to be rewired, and the high voltage backlight driver removed. The power and control wires that previously went to the backlight driver need to be attached to the LCD backlight driver on the HV150UX2 display.

The screen is almost a perfect fit for the iMac G3 stock display bezel, except the corners are slightly cut off by the curved edges. However, it's pretty close, and at this size and resolution I have not found a better display for the project, especially since this one has a display controller cheaply available on eBay.

It is held in via 4 3D printed nylon mounting brackets, which fit over the original CRT mounting holes:

![Display mounted rear](https://github.com/crozone/iMac-G3-PC-Conversion/raw/master/Mounting%20Brackets/Build%20Photos/Display/Screen%20rear.jpg)

### Speakers + Microphone

The original speakers can be powered by a built-in amplifier included on the M.NT68676.2A.11486 display controller, i.e they become the "HDMI Audio" device. The microphone can be wired into the rear panel mic. 

The two front headphone jackes will be repurposed into the front panel audio jack and front panel mic jack.

### Drive bay

The original slot-loading DVD drive is being replaced by a Panasonic UJ-265, which is a slot loading BDXL burner. It is a laptop drive that takes a slimline SATA+power cable, which can be easily converted to standard SATA+power with an adapter. It will be mounted with 3D printed nylon brackets to correctly align it with the case slot.

### Motherboard

The motherboard form factor is microATX, which is the largest motherboard size that comfortably fits within the case without modification. It will be mounted vertically behind the display using 3D printed nylon mounting brackets. The vertical positioning, although more difficult to mount, allows for a 30cm long PCIe card. This should allow for even a 2080 Ti to be mounted comfortably within the case.

### Side ports

Side ports will need to be extended from the motherboard IO panel and GPU, and onto an acrylic side panel mounted in the original iMac G3 IO panel location. 

### PSU

A 750W SFX form factor PSU can comfortably be mounted to the rear of the case, using more 3D printed nylon brackets. The original power socket that fits within the moulded plastic case has been desoldered from the original display controller board and will be rewired into a new power plug, which will be used with the PSU. All metal items within the case will be grounded with grounding wire.

### Cooling

The iMac G3 was primarily designed for passive cooling, which makes active cooling a challenge. There are three main locations where air can be forced into and out of the case: The holes around the carry handle, the meshed access port on the underside, and the RAM access panel which can be removed.

Liquid cooling will help a lot, especially for the GPU. A 2080 Ti with water block will probably be a good idea.

The plan is to mount the largest fan + radiator combination behind the carry handle, a 140mm fan will fit but finding a radiator to match will be a challenge. Air can be channelled directly to the vents with laser cut acrylic, which will both mount the fan and radiator, and seal the edges to direct airflow.

The underside of the iMac can have smaller 60/70/80mm fans mounted to force air into the case. A square cutout may have to be made into the metal cage to allow airflow through the meshed access panel.

 ### RGB

Yes. Everything will be visible through the case shell, and everything will be addressed RGB, running of an 8 way RGB splitter connected to the 3 pin motherboard header.

