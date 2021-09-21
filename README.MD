# Nucleus P8

![Nucleus Screenshot](https://raw.githubusercontent.com/ogoguel/nucleus-p8/master/screenshots/nucleus.png)

## Background


Nucleus was originally released in August 1989 using the ultra fast disk loading that were to be reused in Photonix.
Unfortunately, those routines were incompatible with the upcoming ROM03, and Apple contacted us to update the demo in ordre to present at AppleFest in 1989 in SanFrancisco : they sent us a prototype of a ROM03 board before its release, and to be safe, we've used regular SmartPort call to make it running in time.
This is the version commonly used as of today, named "SmartBoot v3"

30 years later, booting from a disk is not that convenient, hence the idea to convert it to a P8 application to allow it to run more easily on "modern 2GS" with disk drive

## Building the version
* Download cadius and Merlin32 from the Brutal Deluxe Web site
* Run the python script Generate2MG.py : if everything goes fine, it should compile the launcher and create the disk image
   
```
    /NUCLEUSP8/
    NUCLEUS.DATA  BIN $0000 206336 
    NUCLEUS.SYSTEM  SYS $2000  554  
       
    Block : 1600     Free : 1185     File : 2     Directory : 0
```

## Protection
While preparing this version, I've stumbled into 30-year old code that was designed to prevent this exact work to happen by checking that the code has not been tampered.
If it was the case, the demo seems to work fine at the beginning, but is either stuck with the music, or does proceed with nothing in the center of the screen.

The infamous codes were located in 2 places.

### 00/122d : Infinite loop

```
      LDA $03f4
      EOR #$a5
      CMP $03f3 // Check that RESET will Reboot
    Loop1:
      BEQ LooP1
      REP #$30
      LDA $e10048
      CMP #$6b18 // Check that control panel is not accessible
     Loop2:
       BNE Loop2
```

### 00/144E : Altering the demo

```
	  REP #$30  
      LDX $3425  // First Indirection
	  TXY  
	  LDA $00,X  	// Second
	  TAX  
	  LDA $21,X  	// Third => $987 (Boot sector!)
	  CMP #$0bd0  // Check instruction BNE +13  
	  BEQ OK1  
	; KO!
	  LDA $33c2   // Zero
	  STA $2a59,Y // Prevent stars to be displayed
	OK1:
	  LDX $2b1b  // First Indirection
	  TXY  
	  LDA $00,X  // Second
	  TAX  
	  LDA $21,X  // Third = $96CC (Launcher)
	  CMP #$07f0  // Check Instruction BEQ +7
	  BEQ OK2  
	  TYA  			
	  SEC  
	  SBC #$9000  
	  a8 TAY  
	  LDA $25b0  
	  STA $2c56,Y  // Not sure....
	OK2:
	  SEP #$30  	
```

It took me 3 days to figure it out, and I believe I was luckly that modern emulator allows breakpoint on Memory Write, something I would have not imagined at the time.

## Known issue
As the memory is not dynamically allocated, it is not meant to be launched from GS/OS

## Reference
http://www.freetoolsassociation.com/

## Credits
* Thanks to Alex Lee for the idea
* Thanks to Antoine Vignau/Brutal Deluxe for the nifty cadius & Merlin32 tools

## History
* 2021-09-21 Initial release