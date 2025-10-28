********************************************************

Broadcom 95xx Adapter Generation PSoC Catalog Release 

********************************************************


*****************************************************************************************************************************
*************************PLEASE READ THESE GUIDELINES FOR MEGARAID ADAPTERS (9560-16i, 9560-8i, 9580-8i8e)*******************
*****************************************************************************************************************************

StorCLI version 7.2007.0000.0000 or later can be used to upgrade the PSoC component.

Controller FW package 52.20.0-4341 or later must be first installed on the adapter.

Due to hardware changes on the below adapters, after upgrading to any MR 7.20 (52.20.x-xxxx) or later 
package, downgrading to MR 7.19 or older (52.19.x-xxx) is not allowed.

*****************************************************************************************************************************
*************************PLEASE READ THESE GUIDELINES FOR iMR ADAPTERS (9540-16i and 9540-8i)********************************
*****************************************************************************************************************************

StorCLI version 7.2307.0000.0000 or later can be used to upgrade the PSoC component.

Controller FW package 52.20.0-4341 or later must be first installed on the adapter.

Due to hardware changes on the below adapters, after upgrading to after upgrading iMR/HBA to any MR 7.22 (52.22.x-xxxx) or
later package, downgrading to MR 7.21 or older (52.21.x-xxxx, 52.20.x-xxxx, etc.) is not allowed.


****************************************************************************************************************************
*************************PLEASE READ THESE GUIDELINES FOR HBA CONTROLLERS (9500-xx)*****************************************
****************************************************************************************************************************

StorCLI version 7.2307.0000.0000 or later can be used to upgrade the PSoC component.

Controller FW package P24 24.00.00.00 or later must be first installed on the adapter.

***************************************************************************************************************************
***************************************************************************************************************************


====================== 
Supported Controllers:
======================

MegaRAID 9560-8i
MegaRAID 9560-16i
MegaRAID 9580-8i8e
MegaRAID 9562-16i
MegaRAID 9540-8i
MegaRAID 9540-16i
HBA 9500-8i
HBA 9500-16i
HBA 9500-8e
HBA 9500-16e
HBA 9502-16i
 


Component:
=========
PSoC Catalog Firmware v1.31 DCSG01854381
Release date: 03/07/2025


Version Numbers:	
===============

PBLP_HBA_P4_Version_HW:1.00_FW:11.00_PN:14790*
PBLP_HBA_P4S423_Version_HW:1.00_FW:11.00_PN:14798*
PBLP_HBA_P4S443_Version_HW:1.00_FW:11.00_PN:06021*
PBLP_HBA_P4ITOCP_Version_HW:1.00_FW:4.00_PN:15463
PBLP_RAID_P5_Version_HW:3.00_FW:31.00_PN:15987
PBLP_RAID_P5Init_Version_HW:3.00_FW:28.00_PN:12345
PBLP_RAID_P5OCP_Version_HW:8.00_FW:5.00_PN:25731
PBLP_RAID_P6_Version_HW:10.00_FW:27.00_PN:29211
PBLP_RAID_P6Travis_Version_HW:11.00_FW:27.00_PN:29651

* - indicates files updated in this release


StorCLI Version Decoder:	
========+++++++++=======
The following chart indicates how the binary version is translated by MegaRAID StorCLI FW and HBA StorCLI FW:

                                                                       MR StorCLI          HBA StorCLI FW
.............Image Name In Catalog......................Adapter........FW Version.............Version.......
PBLP_HBA_P4_Version_HW:1.00_FW:11.00_PN:14790.............HBA.............NA...................0x006E.......
PBLP_HBA_P4S423_Version_HW:1.00_FW:11.00_PN:14798.........HBA.............NA...................0x006E.......
PBLP_HBA_P4S443_Version_HW:1.00_FW:11.00_PN:06021.........HBA.............NA...................0x006E.......
PBLP_HBA_P4ITOCP_Version_HW:1.00_FW:4.00_PN:15463...... OCP HBA...........NA...................0x0028.......
PBLP_HBA_P4_Version_HW:1.00_FW:10.00_PN:14790.............iMR...........0x000A...................NA.........
PBLP_HBA_P4S423_Version_HW:1.00_FW:10.00_PN:14798.........iMR...........0x000A...................NA.........
PBLP_HBA_P4S443_Version_HW:1.00_FW:10.00_PN:06021.........iMR...........0x000A...................NA.........
PBLP_RAID_P5_Version_HW:3.00_FW:31.00_PN:15987.............MR...........0x001F...................NA.........
PBLP_RAID_P5Init_Version_HW:3.00_FW:28.00_PN:12345.........MR...........0x001C...................NA.........
PBLP_RAID_P5OCP_Version_HW:8.00_FW:5.00_PN:25731.........OCP MR.........0x0005...................NA.........
PBLP_RAID_P6_Version_HW:10.00_FW:27.00_PN:29211............MR...........0x001B...................NA.........
PBLP_RAID_P6Travis_Version_HW:11.00_FW:27.00_PN:29651......MR...........0x001B...................NA.........


Bug Fixes and Enhancements:
===========================
v1.31		Added firmware v11 for part number 14790.
		Added firmware v11 for part number 14798.
		Added firmware v11 for part number 06021.

		Fixed issue where if a PSoC FW update has been
		downloaded and is pending, if there is transient 
		glitch on the 3.3V rail when powering down, the
		update may not take effect on the next power up.

		This issue only impacts the 9500-16i and 9500-8i
		(model 50134).


v1.30		Added firmware v31 for part number 15987.
		Added firmware v5 for part number 25731.
		
		Fixed issue where after a learn cycle, the 
		CVMP05 (FBU345) SuperCap energy pack may be 
		incorrectly marked as bad when using PSoC 5 
		FW version 28.00 (first released in PSoC
		Catalog v1.27) through v30.00:
		PBLP_RAID_P5_Version_HW:3.00_FW:31.00_PN:15987
		PBLP_RAID_P5OCP_Version_HW:8.00_FW:5.00_PN:25731

v1.29

		Added firmware v27 for part numbers 29211 and 29651.
 		Added firmware v30 for part number 15987

		Fixed difference in behavior between PSoC6 and PSoC5 when
		SuperCap VPD is invalid.
		PBLP_RAID_P5_Version_HW:3.00_FW:30.00_PN:15987

		Fixed issue when a deeply depleted SuperCap may take multiple 
		minutes to complete charging on the first learn cycle. This
		would sometimes be seen during factory integration or first time
		system is powered on
		PBLP_RAID_P5_Version_HW:3.00_FW:30.00_PN:15987
		PBLP_RAID_P6_Version_HW:10.00_FW:27.00_PN:29211
		PBLP_RAID_P6Travis_Version_HW:11.00_FW:27.00_PN:29651

v1.28
               Add firmware version 29 for part number 15987 and 
               v26 for part numbers 29211 and 29651.
               
               Fixes issue where adapter may unexpectedly change
               to write through mode and back to write back mode.
               PBLP_RAID_P5_Version_HW:3.00_FW:29.00_PN:15987
               PBLP_RAID_P6_Version_HW:10.00_FW:26.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:26.00_PN:29651

	       Fixes issue where charger may not turn on properly
	       if system delays 3.3V ramp an excessive amount of time
               after the 12V rail ramps.
               PBLP_RAID_P6_Version_HW:10.00_FW:26.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:26.00_PN:29651

               Fixes issue where incorrect vpd and SuperCap temperature 
               data may be reported in logs.
               PBLP_RAID_P6_Version_HW:10.00_FW:26.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:26.00_PN:29651

v1.27
DCSG01488430 -	Add Firmware Version 28 for part numbers 15987 and 12345 
	 	Fixes issue where board power up may take longer than 100 
		ms when using a deeply depleted SuperCap.
		PBLP_RAID_P5_Version_HW:3.00_FW:28.00_PN:15987
		PBLP_RAID_P5Init_Version_HW:3.00_FW:28.00_PN:12345

v1.26
DCSG01378374 - 	Add Firmware Version 4 for PartNumber 15463 to PSoC Catalog Image
		PBLP_HBA_P4ITOCP_Version_HW:1.00_FW:4.00_PN:15463

 
v1.25
DCSG01375926 - Included support for 9562-16i and 9502-16i OCP cards:
               PBLP_RAID_P5OCP_Version_HW:8.00_FW:3.00_PN:25731
               Added PSoC5 file to fix part number naming issue on 
               initial 9560-16i/8i GA parts:
               PBLP_RAID_P5Init_Version_HW:3.00_FW:27.00_PN:12345

v1.23
DCSG01346015 - Included chip ID for additional voltage monitor for 9560 adapters
               PBLP_RAID_P6_Version_HW:10.00_FW:18.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:18.00_PN:29651

v1.22
DCSG01314140 – Included chip ID for additional voltage monitor for 9560 adapters
               PBLP_RAID_P6_Version_HW:10.00_FW:16.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:16.00_PN:2965

DCSG01300243 - Added HBA/iMR 9500/9540 adapter PSoC4 packages. 
               PBLP_HBA_P4_Version_HW:1.00_FW:10.00_PN:14790
               PBLP_HBA_P4S423_Version_HW:1.00_FW:10.00_PN:14798
               PBLP_HBA_P4S443_Version_HW:1.00_FW:10.00_PN:06021

DCSG01300243 - HBA/iMR 9500/9540 fix for adapter boot hang on some platforms

DCSG01300243 - MR 9560/9580 adapter version incremented to include fix for OEM custom card to maintain common file. 
               Change has no impact on standard adapters. Update is not required for MegaRAID adapters already using
               PBLP_RAID_P5_Version_HW:3.00_FW:27.00_PN:15987
               PBLP_RAID_P6_Version_HW:10.00_FW:12.00_PN:29211
               PBLP_RAID_P6Travis_Version_HW:11.00_FW:12.00_PN:29651



Installation:
=============
Use StorCLI to flash the updated image.  These tools can be downloaded from the support and download
section of www.broadcom.com.

*****************************************************************************************************************************
*************************MegaRAID Adapter Instructions***********************************************************************
*****************************************************************************************************************************

    Note 
    Only StorCLI version 7.2007.0000.0000 or later can be used to upgrade the PSoC firmware.
    Controller FW package 52.20.0-4341 or later must first be installed and running on the adapter.

    To check current version of PSoC:
    storcli /c0 show all

    PSoC part number and version info will be listed in text format, e.g.:
    (PSOC FW Version = 0x001A)
    (PSOC Part Number = 15987-260-4GB)

    The above indicates that PBLP_RAID_P5_Version_HW:3.00_FW:26.00_PN:15987 is currently used on the controller. Note that 0x001A = 26d (FW:26.00).

    To update version of PSoC:
    storcli /c0 download file=pblp_catalog.signed.rom

    ****Once the PSoC image is updated, the server must be power cycled for the update to take effect****
            Specifically, MR cards require a DC power cycle where the host 12V and 3.3V rail goes below 2.5V
            Ensure a clean monotonic shutdown of the power rails during the DC power cycle.
            A Cache Offload cannot be in process during the DC power cycle for the update to take effect


    After restart, check for updated version of PSoC:
    storcli /c0 show all

    (PSoC part number and version info will be listed in text format, e.g.:)
    (PSOC FW Version = 0x001B)
    (PSOC Part Number = 15987-260-4GB)


*****************************************************************************************************************************
*************************HBA Adapter Instructions****************************************************************************
*****************************************************************************************************************************


    Note:
    Only StorCLI version 7.2307.0000.0000 or later can be used to upgrade the PSoC firmware.
    Controller FW package 24.00.00.00 or later must first be installed and running on the adapter.     

    Note
    95xx HBAs can use one of three PSoC4 devices or a discreet logic solution to control the power up and reset sequencing
    The update catalog contains all three PSoC 4 images 
    If no PSoC is present, the update is ignored.

    Use "storcli /c0 show all" command and look for the following to determine if the PSoC is present:

    If the controller has a PSoC, the "show all" command will result in the following under the “Supported Adapter Operations” section:

    (Support PSOC Update = Yes)
    (Support PSOC Part Information = Yes)
    (Support PSOC Version Information = Yes)

    If the controller uses the discrete logic option, the following result is reported:

    (Support PSOC Update = No)
    (Support PSOC Part Information = No)
    (Support PSOC Version Information = No)


    To check current version of PSoC:

    storcli /c0 -show all

    PSoC part number and version info will be listed in text format, e.g.:
    (PSOC Version = 147980100)
    (PSOC FW Version = 0x0064)
    (PSOC Part Number = 14798)

    The above indicates that PBLP_HBA_P4S423_Version_HW:1.00_FW:10.00_PN:14798 is currently used on the controller. Note that 0x0064 = 100d (FW:10.00).

    To update version of PSoC:
    storcli /c0 download psoc file=pblp_catalog.signed.rom

    If the PSoC is present on the adapter, the following output is expected

    (Downloading image.Please wait...)

    (CLI Version = 007.2307.0000.0000 July 22, 2022)
    (Operating system = EFI Shell)
    (Controller = 0)
    (Status = Success)
    (Description = CRITICAL! PSoC programming successful. Please power cycle the system for changes to take effect.)

    If the controller uses the discrete logic option, the following result is reported:

    (Downloading image.Please wait...)

    (CLI Version = 007.2307.0000.0000 July 22, 2022)
    (Operating system = EFI Shell)
    (Controller = 1)
    (Status = Failure)
    (Description = Controller does not support PSOC Update.)

  
    ****After applying the update, power cycle the system for the update to take effect****
           For HBAs/iMR adapters an AC power cycle is required
           Specifically the 3.3V AUX power must drop below 1.5V for the update to take effect
           Ensure a clean monotonic shutdown of the power rails during the AC power cycle.


    After restart, check for updated version of PSoC usingthe show all command:
    storcli /c0 show all










