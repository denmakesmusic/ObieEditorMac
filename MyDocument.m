//
//  MyDocument.m
//  ObieEditor
//
//  Created by groumpf on Mon Apr 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"

#import "Controller.h"
#import "Description.h"
#import "ParamTextField.h"
#import "ParamPopUpButton.h"
#import "ParamSlider.h"
#import "ParamCheckbox.h"
#import "Parameter.h"
#import "Tools.h"

enum
{
	TAB_PATCH,                                  // 2 tabs (sander)
	TAB_GLOBAL
};


// table des numeros de parametres en fonction de l'index MATRIX_INDEX_
const int mParameterNumbers[] = {
	-1, -1, -1, -1, -1, -1, -1, -1,
	48,  0,  5,  3,  7,  6, 10, 15,
	13, 17, 16, 12, 20,  8,  9, 18,
	19,  2, 21, 24, 25, 26, 30, 27,
	44, 46, 47, 80, 86, 87, 82, 83, 
	88, 84, 90, 96, 97, 92, 93, 98, 
	94, 57, 50, 51, 52, 53, 54, 55, 
	59, 58, 67, 60, 61, 62, 63, 64, 
	65, 69, 68, 77, 70, 71, 72, 73, 
	74, 75, 79, 78, 33, 34, 35, 36, 
	37, 38, 40, 41, 42, 43,  1,  4,
	11, 14, 22, 23, 28, 29, 56, 66, 
	76, 85, 95, 45, 31, 32, 81, 91};


enum 
{
	GLOBAL_TAG_VIB_SPEED = 201, // Sander was 200 > now Paramater+200
	GLOBAL_TAG_VIB_MOD_SOURCE,
	GLOBAL_TAG_VIB_MOD_AMOUNT,
	GLOBAL_TAG_VIB_WAVE,
	GLOBAL_TAG_VIB_AMP,
	GLOBAL_TAG_VIB_AMP_MOD_SOURCE,
	GLOBAL_TAG_VIB_AMP_MOD_AMOUNT,
	GLOBAL_TAG_MASTER_TUNE, // =208 
	GLOBAL_TAG_MIDI_CHANNEL = 211,
	GLOBAL_TAG_MIDI_OMNI,
    GLOBAL_TAG_MIDI_CONTROLLER_ENABLE,
    GLOBAL_TAG_PATCH_CHANGE_ENABLE,
    GLOBAL_TAG_LEVER_2 = 217,
	GLOBAL_TAG_LEVER_3,
	GLOBAL_TAG_PEDAL_1,
	GLOBAL_TAG_PEDAL_2,
    GLOBAL_TAG_MIDI_ECHO_ENABLE = 232,  // Enabling midi thru. Better not use this, communication will be messed up!
    GLOBAL_TAG_MASTER_TRANSPOSE = 234,
    GLOBAL_TAG_MIDI_MONO_MODE_ENABLE = 235,
    GLOBAL_TAG_BEND_RANGE = 364,
    GLOBAL_TAG_BANK_LOCK_ENABLE,
    GLOBAL_TAG_UNISON_ENABLE = 369,
    GLOBAL_TAG_VOLUME_INVERT_ENABLE,
    GLOBAL_TAG_MEMORY_PROTECT_ENABLE,
    GLOBAL_TAG_BEND_RANGE_DISPLAY = 1364
};



@implementation MyDocument

NSString *MyDocumentType = @"Matrix 1000 patch";

// nombre d'octets des donnees d'un patch (format non nibble)
const int FILE_PATCH_SIZE = PATCH_TAB_SIZE;

+ (NSString *)documentType
{
	return MyDocumentType;
}

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		mValidGlobalParameters = FALSE;
        
    }
    return self;
}

/**
	Appellee quand on fait new et un get patch ou get edit buffer (et pas open).
 */
-(MyDocument*)initWithType:(NSString*)typeName error:(NSError * _Nullable * _Nullable)outError
{
	MyDocument * oDoc = [super initWithType:typeName error:outError];
	if (oDoc != nil)
	{
		// Charger un patch standard pour etre sur de partir de qq chose qui fonctionne.
		// C'est inutile quand on vient de get edit buffer mais je ne vois pas trop ou le faire juste pour new
		NSData* oData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"init" ofType:@".m1000p"]];
		[oDoc readFromData:oData ofType:MyDocumentType error:outError];
	}
	return oDoc;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"M1000";
}


- (void)showWindows
{
	[super showWindows];
	
	// prevenir le controller
	[[NSApp delegate] notifyNewDocument:self];
}



- (BOOL)readFromData:(NSData *)data
			  ofType:(NSString *)typeName
			   error:(NSError * _Nullable *)outError
{
	// Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
	NSAssert([typeName isEqualToString:MyDocumentType], @"Unknown type");
	
	NSRange oRange2 = {0, FILE_PATCH_SIZE};
	[data getBytes:mParameters range:oRange2];
	
	return YES;
}

- (NSData *)dataOfType:(NSString *)typeName
				 error:(NSError * _Nullable *)outError
{
	// Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	NSAssert([typeName isEqualToString:MyDocumentType], @"Unknown type");
	
	return [NSData dataWithBytes:mParameters length:FILE_PATCH_SIZE];
}



- (void)setPatchName:(NSString *)aName
{
	// Sander: Puts PatchName in mParameters
    uint8_t aTempName[9];
//    NSLog(@"setPatchName:>%@<",aName);
    [aName getCString:(char*)aTempName maxLength:9 encoding:NSASCIIStringEncoding];
    // Sander: GetCString adds char at the end. For 8 chars you need 9. This overwrites param. 8. The for loop only copy's char(0-7)
    for (int i = 0; i <=7; i++) {
        mParameters[i] = aTempName[i];
    }
    
//    NSLog(@"setPatchName oTempName: >%s<", aTempName);
	[self updateChangeCount:NSChangeDone];
}

- (NSString *)patchName
{
    return [[NSString alloc] initWithBytes:mParameters length:8 encoding:NSASCIIStringEncoding];
}



/**
	Action du bouton pour editer le nom du patch.
	C'est un toggle entre l'edition et la desactivation pour eviter des problemes de focus.
 */
-(IBAction)editPatchName:(id)sender
{
	if ([mPatchName isEnabled])
	{
		// valider la modification
		[self patchNameAction:sender];
	}
	else
	{
		// passer en edition
		NSString* oStr = [mPatchName stringValue];
		// trimmer les blancs, de toute facon ils sont ajoutes dans le patch a la validation
		oStr = [oStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[mPatchName setStringValue:oStr];
		[mPatchName setEnabled:TRUE];
		[mPatchName becomeFirstResponder];
		[editPatchNameButton setImage:[NSImage imageNamed:@"checkmark.icns"]];
	}
}


- (IBAction)patchNameAction:(id)sender
{
	// pas de parametre pour le nom
	// commencer par trimmer (ne pas garder les blancs au debut)
	NSString *trimmedPatchName = [[mPatchName stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	// Added Sander. For patchnames shorter then 8 characters fill with " ".
	NSString *str = [trimmedPatchName stringByPaddingToLength:8 withString:@" " startingAtIndex:0];
	// So, very nice that this routine works, but the M1000 doesn't store patchnames anyway ;). Patchnames are "BNKx: xx" with banknr.&Patchnr.
	[self setPatchName:str];
	//NSLog(@"patchNameAction | str = >%@<", str);
	[mPatchName setStringValue:trimmedPatchName];
	[mPatchName setEnabled:FALSE];
	[editPatchNameButton setImage:[NSImage imageNamed:@"editname.icns"]];
}




- (uint8_t*)patch                                       //used with sendPatch
{
    return mParameters;
}


// intercepte un changement sur le nom du patch
// par le delegate du NSTextField
-(void)controlTextDidChange:(NSNotification *)notification
{
	[self updateChangeCount:NSChangeDone];
}

// prend la valeur venant du controle, la stocke dans le modele et l'envoie au synthe
- (void)setParameter:(int)aValue At:(int)aIndex
{
	[self updateChangeCount:NSChangeDone];
	// TODO verifier la valeur avant de l'envoyer au synthe
	// changer le parametre sur le synthe
	int oValue = aValue;
	// cas particulier du detune (on recoit 0..62) Sander changed that in sounddesc.plist now revieving -31 ..31 which made things simpler.
    if (aIndex == MATRIX_INDEX_DCO2_DETUNE)  // The value ranges from -31 to +31 and has to be written in 6bit signed format. (Sander)
    {
//        NSLog(@"SetP inValue = %i", oValue);
        mParameters[aIndex] = oValue;
    }

	else
	{   // cas standard
		if (oValue < 0)
		{
			oValue += 128;
			// bon, j'y comprend rien mais si je n'ajoute pas 128 dans le modele
			// la prochaine fois que j'envoie le patch je n'ai plus le meme son
			// (les valeurs de la matrice semblent mises a 0 dans le synthe)
			// c'est peut-etre du au passage int -> uint8 ?
			mParameters[aIndex] = oValue + 128;
		}
		else
		{
			// mettre a jour le modele
			mParameters[aIndex] = oValue;
		}
	}

	Controller *cont = [NSApp delegate];
	
	// l'envoi du sustain ne fonctionne pas
	// ni le env2->vca
	if ((aIndex == MATRIX_INDEX_ENV1_SUSTAIN && [cont sendPatchForENV1SUSTAIN])
        || (aIndex == MATRIX_INDEX_ENV2_TO_VCA2 && [cont sendPatchForENV2TOVCA2])
        || ((aIndex == MATRIX_INDEX_LFO1_SAMPLED_SOURCE  || aIndex == MATRIX_INDEX_LFO2_SAMPLED_SOURCE ) && [cont sendPatchForLFOSAMPLESOURCE]))
	{
		// donc on envoie tout le patch
		[[MIDIDriver sharedInstance] sendPatch:[self patch]];
	}
	else
	if (aIndex < MATRIX_INDEX_MATRIX_SOURCE_0)
	{
		[[MIDIDriver sharedInstance] sendParameter:mParameterNumbers[aIndex] value:oValue];
	}
	else
	if (aIndex < 200)	
	{
		// on n'emet pas les pseudo parametres globaux  >= 200
		
		int oPath = (aIndex - MATRIX_INDEX_MATRIX_SOURCE_0) / 3;
		//printf("PATH = %d\n", oPath);
		int oSource = [self getParameter:(MATRIX_INDEX_MATRIX_SOURCE_0+3*oPath)];
		//printf("SOURCE = %d\n", oSource);
		int oDest = [self getParameter:(MATRIX_INDEX_MATRIX_SOURCE_0+3*oPath+2)];
		//printf("DEST = %d\n", oDest);
		int oVal = [self getParameter:(MATRIX_INDEX_MATRIX_SOURCE_0+3*oPath+1)];
		//printf("VAL = %d\n", oVal);
		[[MIDIDriver sharedInstance] sendMatrixPath:oPath Source:oSource Value:oVal Dest:oDest];
	}
}


- (int)getParameter:(int)aIndex // Reading parameters from SYNTH, with exceptions for DCO2_DETUNE and VCF_FREQ (Sander Version) ----------------<<<<
{
    int oValue = mParameters[aIndex];
//    NSLog(@"GetParameter %i inValue  %i", aIndex, oValue);
    if (aIndex == MATRIX_INDEX_DCO2_DETUNE) // DETUNE_DCO1 is 6bitsigned. InputValue 97..127 = (-31..-1) 0..31 (0..31) (sander) (old method gave -31 for detune=0)
    {
        if (oValue >= 225)
        //if (oValue >= 97)
        {
            oValue -= 256;
           // oValue -= 128;
        }
    }
    else
        if (aIndex != MATRIX_INDEX_FILTER_FREQ && oValue > 63)
        {
          //  oValue -= 128;
            oValue -= 256;
        }
//    NSLog(@"GetParameeter_outValue  %i", oValue);
    return oValue;
}


// positionne les parametres globaux
- (void)setGlobalParameters:(uint8_t*)aData
{
	[self updateChangeCount:NSChangeDone];
	memcpy(mGlobalParameters, aData, MASTER_DATA_SIZE);
	// TODO avertir la fenetre
	// valider les parametres globaux
	mValidGlobalParameters = TRUE;
}

- (int)getGlobalParameter:(int)aIndex
{
	return mGlobalParameters[aIndex];
}

- (void)setGlobalParameter:(int)aValue At:(int)aIndex
{
	[self updateChangeCount:NSChangeDone];
	mGlobalParameters[aIndex] = aValue;
}

- (uint8_t *)globalParameters
{
	return mGlobalParameters;
}

- (bool)validGlobalparameters
{
	return mValidGlobalParameters;
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
//	NSLog(@"windowDidLoad %@ %d\n", keyMode, [self isWindowLoaded]);
    [super windowControllerDidLoadNib:aController];
    
    NSWindow *oWin = [aController window];
	NSView *oView = [oWin contentView];
//    NSLog(@"view = %@", oView);
	NSArray *subviews = [oView subviews];
//	NSLog(@"subviews = %@", subviews);
    
    int oTag = 8;
	NSTabView *oTabView = [subviews objectAtIndex:0];
	NSArray *oTabs = [oTabView tabViewItems];
		
	while (oTag < PATCH_TAB_SIZE)
	{
		int sv = 0;
		NSView *oTagview = nil;
		int oCount = 0;
		// oblige de parcourir les Tab view car sinon je ne recupere que
		// les controles presents sur le premier tab
		for (sv = 0; sv < [oTabs count]; sv++)
		{
			NSView *oControl = [[oTabs objectAtIndex:sv] view];
			int oAlternateTag = oTag;
			// boucler sur les champs de bits
			while (oAlternateTag < 33000)
			{
				oTagview = [oControl viewWithTag:oAlternateTag];
				if (oTagview != nil)
				{
					id oObject = [[Description soundInstance] getObject:oAlternateTag];
					if (oObject != nil)
					{
						[self setObjectUI:oTagview dico:oObject tag:oTag];
						oCount++;
					}
				}
				if (oAlternateTag < 30000)
					oAlternateTag += 30000;
				else
					oAlternateTag += 1000;
			}
			if (oCount > 0)
			{
				break;
			}
		}
		if (oCount == 0)
		{
			NSLog(@"null view for tag %d", oTag);
		}
		oTag++;
	}
		
	// le nom du patch
	[mPatchName setStringValue:[self patchName]];                                   // Display PatchName.

	
	// global parameters
	NSView *oTabGlobal = [[oTabs objectAtIndex:TAB_GLOBAL] view];
	
	NSPopUpButton *globalVibratoSpeedModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_SOURCE];
	[globalVibratoSpeedModSource removeAllItems];
    NSArray *gSou = [NSArray arrayWithObjects:@"OFF", @"LEVER-2", @"PEDAL-1", nil];
	[globalVibratoSpeedModSource addItemsWithTitles:gSou];
	
    NSPopUpButton *globalVibratoWaveform = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_WAVE];
	[globalVibratoWaveform removeAllItems];
	NSArray *vibratoWaves = [NSArray arrayWithObjects:@"TRIANGLE", @"SAW UP", @"SAW DWN", @"SQUARE", @"RANDOM", @"NOISE", nil];
	[globalVibratoWaveform addItemsWithTitles:vibratoWaves];
	
    NSPopUpButton *globalVibratoAmpModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP_MOD_SOURCE];
	[globalVibratoAmpModSource removeAllItems];
    [globalVibratoAmpModSource addItemsWithTitles:gSou];

	ParamTextField *globalLever2 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_2];
	id oObject = [[Description soundInstance] getObject:GLOBAL_TAG_LEVER_2];
	[self setObjectUI:globalLever2 dico:oObject tag:GLOBAL_TAG_LEVER_2];

	ParamTextField *globalLever3 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_3];
	oObject = [[Description soundInstance] getObject:GLOBAL_TAG_LEVER_3];
	[self setObjectUI:globalLever3 dico:oObject tag:GLOBAL_TAG_LEVER_3];

	ParamTextField *globalPedal1 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_1];
	oObject = [[Description soundInstance] getObject:GLOBAL_TAG_PEDAL_1];
	[self setObjectUI:globalPedal1 dico:oObject tag:GLOBAL_TAG_PEDAL_1];

	ParamTextField *globalPedal2 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_2];
	oObject = [[Description soundInstance] getObject:GLOBAL_TAG_PEDAL_2];
	[self setObjectUI:globalPedal2 dico:oObject tag:GLOBAL_TAG_PEDAL_2];
    
    ParamTextField *globalMidiChannel = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CHANNEL];                   // added Sander: (11) MIDI CHANNEL
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MIDI_CHANNEL];
    [self setObjectUI:globalMidiChannel dico:oObject tag:GLOBAL_TAG_MIDI_CHANNEL];
    
    ParamCheckbox *globalMidiOmniEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_OMNI];                    // added Sander: (12) MIDI Omni Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MIDI_OMNI];
    [self setObjectUI:globalMidiOmniEnable dico:oObject tag:GLOBAL_TAG_MIDI_OMNI];
    
    ParamCheckbox *globalMidiControllersEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CONTROLLER_ENABLE];// added Sander: (13) MIDI Controllers Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MIDI_CONTROLLER_ENABLE];
    [self setObjectUI:globalMidiControllersEnable dico:oObject tag:GLOBAL_TAG_MIDI_CONTROLLER_ENABLE];
    
    ParamCheckbox *globalPatchChangeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_PATCH_CHANGE_ENABLE];       // added Sander: (14) MIDI Patch Change Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_PATCH_CHANGE_ENABLE];
    [self setObjectUI:globalPatchChangeEnable dico:oObject tag:GLOBAL_TAG_PATCH_CHANGE_ENABLE];

/*  Enabling MIDI thru disables MIDI out, so no sysex from M1000. Better not use it.
    ParamCheckbox *globalMidiEchoEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_ECHO_ENABLE];             // added Sander: (32) MIDI THRU Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MIDI_ECHO_ENABLE];
    [self setObjectUI:globalMidiEchoEnable dico:oObject tag:GLOBAL_TAG_MIDI_ECHO_ENABLE];
*/
    ParamTextField *globalMasterTranspose = [oTabGlobal viewWithTag:GLOBAL_TAG_MASTER_TRANSPOSE];           // added Sander: (34) TRANSPOSE
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MASTER_TRANSPOSE];
    [self setObjectUI:globalMasterTranspose dico:oObject tag:GLOBAL_TAG_MASTER_TRANSPOSE];
    
    ParamCheckbox *globalMidiMonoModeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_MONO_MODE_ENABLE];    // added Sander: (35) MIDI MONO Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MIDI_MONO_MODE_ENABLE];
    [self setObjectUI:globalMidiMonoModeEnable dico:oObject tag:GLOBAL_TAG_MIDI_MONO_MODE_ENABLE];

    ParamCheckbox *globalBankLockEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_BANK_LOCK_ENABLE];             // added Sander: (165) Bank Lock Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_BANK_LOCK_ENABLE];
    [self setObjectUI:globalBankLockEnable dico:oObject tag:GLOBAL_TAG_BANK_LOCK_ENABLE];
    
    ParamCheckbox *globalUnisonEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_UNISON_ENABLE];                  // added Sander: (169) UNISON Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_UNISON_ENABLE];
    [self setObjectUI:globalUnisonEnable dico:oObject tag:GLOBAL_TAG_UNISON_ENABLE];

    ParamCheckbox *globalVolumeInvertEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_VOLUME_INVERT_ENABLE];     // added Sander: (170) Volume Invert Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_VOLUME_INVERT_ENABLE];
    [self setObjectUI:globalVolumeInvertEnable dico:oObject tag:GLOBAL_TAG_VOLUME_INVERT_ENABLE];
    
    ParamCheckbox *globalMemoryProtectEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MEMORY_PROTECT_ENABLE];     // added Sander: (171) Memory Protect Enable
    oObject = [[Description soundInstance] getObject:GLOBAL_TAG_MEMORY_PROTECT_ENABLE];
    [self setObjectUI:globalMemoryProtectEnable dico:oObject tag:GLOBAL_TAG_MEMORY_PROTECT_ENABLE];
    
    [self updateGlobalParameters];

	// premier tab
	[oTabView selectFirstTabViewItem:self];
}



- (void)setObjectUI:(NSView*)aView dico:(id)aDico tag:(int)aTag
{
	MyDocument *doc = self;
//    NSLog(@"tag = %d value = %d", aTag, [doc getParameter:aTag]);
    if ([aView conformsToProtocol:@protocol(Parameter)])
	{
		[(id<Parameter>)aView setUI:aDico description:[Description soundInstance]];
		[(id<Parameter>)aView setIntValueFromDoc:[doc getParameter:aTag]];
	}
}



// Get Global parameters from Matrix1000.
- (IBAction)getGlobalParameters:(id)sender
{
    
//	NSLog(@"getGlobalParameters");
    [[MIDIDriver sharedInstance] sendRequestDataType:3 Number:0];
	uint8_t oBuffer[MASTER_DATA_SIZE];
	MPSemaphoreID delay;	
	MPCreateSemaphore(1, 0, &delay); // a binary semaphore
	int oReceiveCount = 0;
	if (oReceiveCount == 0)  // No response generates Error message, if there is a m1000 and it is responding, it will respond within 500ms.
	{
//        NSLog(@"getReceiveCount while == 0");
        MPWaitOnSemaphore(delay, 500 * kDurationMillisecond);
		oReceiveCount = [[MIDIDriver sharedInstance] getReceivedBytes:oBuffer maxSize:MASTER_DATA_SIZE];
	}
    if (oReceiveCount == MASTER_DATA_SIZE)
	{
		[self setGlobalParameters:oBuffer];
		[self updateGlobalParameters];
	}
    else
    {
        NSWindow *oWin = [[[self windowControllers] objectAtIndex:0] window];// added Sander: for error message, if no response from m1000.
		[Tools showAlertWithMessage:@"An error occurred: M-1000 did not respond.\n\nParameter values could not be loaded." andWindow:oWin];
    }
}



// update global parameter display with document values
- (void)updateGlobalParameters
{
    int tempValue;
    MyDocument *oDoc = self;
	NSWindow *oWin = [[[self windowControllers] objectAtIndex:0] window];
	NSView *oView = [oWin contentView];
	NSArray *subviews = [oView subviews];	
	NSTabView *oTabView = [subviews objectAtIndex:0];
	NSArray *oTabs = [oTabView tabViewItems];
	NSView *oTabGlobal = [[oTabs objectAtIndex:TAB_GLOBAL] view];
	
	NSSlider *globalVibratoSpeed = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_SPEED];
	NSPopUpButton *globalVibratoSpeedModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_SOURCE];
	NSSlider *globalVibratoSpeedModAmount = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_AMOUNT];
	NSSlider *globalVibratoAmplitude = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP];
	NSPopUpButton *globalVibratoWaveform = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_WAVE];
	NSSlider *globalVibratoAmpModAmount = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP_MOD_AMOUNT];
	NSPopUpButton *globalVibratoAmpModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP_MOD_SOURCE];
	NSTextField *globalLever2 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_2];
	NSTextField *globalLever3 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_3];
	NSTextField *globalPedal1 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_1];
	NSTextField *globalPedal2 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_2];
	NSSlider *globalBendRange = [oTabGlobal viewWithTag:GLOBAL_TAG_BEND_RANGE];
	NSTextField *globalBendRangeDisplay = [oTabGlobal viewWithTag:GLOBAL_TAG_BEND_RANGE_DISPLAY];
    // added sander
    NSSlider *globalMasterTune = [oTabGlobal viewWithTag:GLOBAL_TAG_MASTER_TUNE];                       // added Sander: (8) Master Tune
    NSTextField *globalMidiChannel = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CHANNEL];                  // added Sander: (11) MIDI CHANNEL
    NSButton *globalMidiOmniEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_OMNI];                     // added Sander: (12) MIDI Omni Enable
    NSButton *globalMidiControllerEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CONTROLLER_ENABLE];  // added Sander: (13) MIDI Controller Enable
    NSButton *globalMidiPatchChangeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_PATCH_CHANGE_ENABLE];    // added Sander: (14) MIDI Patch Change Enable
//    NSButton *globalMidiEchoEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_ECHO_ENABLE];            // added Sander: (32) MIDI THRU Enable
    NSTextField *globalMasterTranspose = [oTabGlobal viewWithTag:GLOBAL_TAG_MASTER_TRANSPOSE];          // added Sander: (34) TRANSPOSE
    NSButton *globalMidiMonoModeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_MONO_MODE_ENABLE];     // added Sander: (35) MIDI MONO Enable
    NSButton *globalBankLockEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_BANK_LOCK_ENABLE];              // added Sander: (165) Bank Lock Enable
    NSButton *globalUnisonEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_UNISON_ENABLE];                   // added Sander: (169) UNISON Enable
    NSButton *globalVolumeInvertEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_VOLUME_INVERT_ENABLE];      // added Sander: (170) Volume Invert Enable
    NSButton *globalMemoryProtectEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MEMORY_PROTECT_ENABLE];    // added Sander: (171) Memory Protect Enable

    
	[globalVibratoSpeed setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED]];	
	[globalVibratoSpeedModSource selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_SOURCE]];
	[globalVibratoSpeedModAmount setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_AMOUNT]];
	[globalVibratoAmplitude setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP]];
	[globalVibratoWaveform selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_WAVEFORM]];
	[globalVibratoAmpModAmount setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_AMOUNT]];
	[globalVibratoAmpModSource selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_SOURCE]];
	[globalLever2 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_2]];
	[globalLever3 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_3]];
	[globalPedal1 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_1]];
	[globalPedal2 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_2]];
	[globalBendRange setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_BEND_RANGE]];
	[globalBendRangeDisplay setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_BEND_RANGE]];
    tempValue = [oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MASTER_TUNE];                                              // added Sander: (8) Master Tune | 6 bit signed conversion.
    if (tempValue >= 225) {
        tempValue -= 256;
    }
    [globalMasterTune setIntValue:tempValue];
    // ---------
    [globalMidiChannel setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_CHANNEL]];                         // added Sander: (11) MIDI CHANNEL
    [globalMidiOmniEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_OMNI]];                         // added Sander: (12) MIDI Omni Enable
    [globalMidiControllerEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_CONTROLLER_ENABLE]];      // added Sander: (13) MIDI Controller Enable
    [globalMidiPatchChangeEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PATCH_CHANGE_ENABLE]];   // added Sander: (14) MIDI Patch Change Enable
//    [globalMidiEchoEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_ECHO_ENABLE]]; don't use!     // added Sander: (32) MIDI THRU Enable
    tempValue = [oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MASTER_TRANSPOSE];                                         // added Sander: (34) TRANSPOSE | 6 bit signed conversion.
    if (tempValue >= 225) {
        tempValue -= 256;
    }
    [globalMasterTranspose setIntValue:tempValue];
    [globalMidiMonoModeEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_MONO_MODE_ENABLE]];         // added Sander: (35) MIDI MONO Enable
    [globalBankLockEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_BANK_LOCK_ENABLE]];                  // added Sander: (165) Bank Lock Enable
    [globalUnisonEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_UNISON_ENABLE]];                       // added Sander: (169) UNISON Enable
    [globalVolumeInvertEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VOLUME_INVERT_ENABLE]];          // added Sander: (170) Volume Invert Enable
    [globalMemoryProtectEnable setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MEMORY_PROTECT_ENABLE]];        // added Sander: (171) Memory Protect Enable
}



// met a jour le document et envoie les parametres au synthe
- (IBAction)sendGlobalParameters:(id)sender
{
    int tempValue;
    MyDocument *oDoc = self;
	NSWindow *oWin = [[[self windowControllers] objectAtIndex:0] window];
	if ([oDoc validGlobalparameters])
	{
		NSView *oView = [oWin contentView];
		NSArray *subviews = [oView subviews];	
		NSTabView *oTabView = [subviews objectAtIndex:0];
		NSArray *oTabs = [oTabView tabViewItems];
		NSView *oTabGlobal = [[oTabs objectAtIndex:TAB_GLOBAL] view];

		NSSlider *globalVibratoSpeed = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_SPEED];
		NSPopUpButton *globalVibratoSpeedModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_SOURCE];
		NSSlider *globalVibratoSpeedModAmount = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_AMOUNT];
		NSSlider *globalVibratoAmplitude = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP];
		NSPopUpButton *globalVibratoWaveform = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_WAVE];
		NSSlider *globalVibratoAmpModAmount = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP_MOD_AMOUNT];
		NSPopUpButton *globalVibratoAmpModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_AMP_MOD_SOURCE];
		NSTextField *globalLever2 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_2];
		NSTextField *globalLever3 = [oTabGlobal viewWithTag:GLOBAL_TAG_LEVER_3];
		NSTextField *globalPedal1 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_1];
		NSTextField *globalPedal2 = [oTabGlobal viewWithTag:GLOBAL_TAG_PEDAL_2];
		NSSlider *globalBendRange = [oTabGlobal viewWithTag:GLOBAL_TAG_BEND_RANGE];
        // added sander
        NSSlider *globalMasterTune = [oTabGlobal viewWithTag:GLOBAL_TAG_MASTER_TUNE];                                   // added Sander: (8) Master Tune
        NSTextField *globalMidiChannel = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CHANNEL];                              // added Sander: (11) MIDI CHANNEL
        NSButton *globalMidiOmniEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_OMNI];                                 // added Sander: (12) MIDI Omni Enable
        NSButton *globalMidiControllerEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_CONTROLLER_ENABLE];              // added Sander: (13) MIDI Controller Enable
        NSButton *globalMidiPatchChangeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_PATCH_CHANGE_ENABLE];                // added Sander: (14) MIDI Patch Change Enable
//       NSButton *globalMidiEchoEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_ECHO_ENABLE];                         // added Sander: (32) MIDI THRU Enable
        NSTextField *globalMasterTranspose = [oTabGlobal viewWithTag:GLOBAL_TAG_MASTER_TRANSPOSE];                      // added Sander: (34) TRANSPOSE
        NSButton *globalMidiMonoModeEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MIDI_MONO_MODE_ENABLE];                 // added Sander: (35) MIDI MONO Enable
        NSButton *globalBankLockEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_BANK_LOCK_ENABLE];                          // added Sander: (165) Bank Lock Enable
        NSButton *globalUnisonEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_UNISON_ENABLE];                               // added Sander: (169) UNISON Enable
        NSButton *globalVolumeInvertEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_VOLUME_INVERT_ENABLE];                  // added Sander: (170) Volume Invert Enable
        NSButton *globalMemoryProtectEnable = [oTabGlobal viewWithTag:GLOBAL_TAG_MEMORY_PROTECT_ENABLE];                // added Sander: (171) Memory Protect Enable
        
        
        [oDoc setGlobalParameter:[globalVibratoSpeed intValue] At:MATRIX_INDEX_GLOBAL_VIB_SPEED];
		[oDoc setGlobalParameter:[globalVibratoSpeedModSource indexOfSelectedItem] At:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_SOURCE];
		[oDoc setGlobalParameter:[globalVibratoSpeedModAmount intValue] At:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_AMOUNT];
		[oDoc setGlobalParameter:[globalVibratoAmplitude intValue] At:MATRIX_INDEX_GLOBAL_VIB_AMP];
		[oDoc setGlobalParameter:[globalVibratoWaveform indexOfSelectedItem] At:MATRIX_INDEX_GLOBAL_VIB_WAVEFORM];
		[oDoc setGlobalParameter:[globalVibratoAmpModSource indexOfSelectedItem] At:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_SOURCE];		
		[oDoc setGlobalParameter:[globalVibratoAmpModAmount intValue] At:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_AMOUNT];
		[oDoc setGlobalParameter:[globalLever2 intValue] At:MATRIX_INDEX_GLOBAL_MIDI_LEVER_2];
		[oDoc setGlobalParameter:[globalLever3 intValue] At:MATRIX_INDEX_GLOBAL_MIDI_LEVER_3];
		[oDoc setGlobalParameter:[globalPedal1 intValue] At:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_1];
		[oDoc setGlobalParameter:[globalPedal2 intValue] At:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_2];
		[oDoc setGlobalParameter:[globalBendRange intValue] At:MATRIX_INDEX_GLOBAL_BEND_RANGE];
        // added sander
        [oDoc setGlobalParameter:[globalMasterTune intValue] At:MATRIX_INDEX_GLOBAL_MASTER_TUNE];                           // added Sander: (8) Master Tune
        [oDoc setGlobalParameter:[globalMidiChannel intValue] At:MATRIX_INDEX_GLOBAL_MIDI_CHANNEL];                         // added Sander: (11) MIDI CHANNEL
        [oDoc setGlobalParameter:[globalMidiOmniEnable intValue] At:MATRIX_INDEX_GLOBAL_MIDI_OMNI];                         // added Sander: (12) MIDI Omni Enable
        [oDoc setGlobalParameter:[globalMidiControllerEnable intValue] At:MATRIX_INDEX_GLOBAL_MIDI_CONTROLLER_ENABLE];      // added Sander: (13) MIDI Controller Enable
        [oDoc setGlobalParameter:[globalMidiPatchChangeEnable intValue] At:MATRIX_INDEX_GLOBAL_MIDI_PATCH_CHANGE_ENABLE];   // added Sander: (14) MIDI Patch Change Enable
//        [oDoc setGlobalParameter:[globalMidiEchoEnable intValue] At:MATRIX_INDEX_GLOBAL_MIDI_ECHO_ENABLE];                // added Sander: (32) MIDI THRU Enable
        [oDoc setGlobalParameter:[globalMasterTranspose intValue] At:MATRIX_INDEX_GLOBAL_MASTER_TRANSPOSE];                 // added Sander: (34) TRANSPOSE
        [oDoc setGlobalParameter:[globalMidiMonoModeEnable intValue] At:MATRIX_INDEX_GLOBAL_MIDI_MONO_MODE_ENABLE];         // added Sander: (35) MIDI MONO Enable
        tempValue = [globalBankLockEnable intValue] << 7;                                                                   // added Sander: (165) Bank Lock Enable
  //      NSLog(@"globalBankLockEnable= %d", tempValue);
        [oDoc setGlobalParameter:tempValue At:MATRIX_INDEX_GLOBAL_BANK_LOCK_ENABLE];
        [oDoc setGlobalParameter:[globalUnisonEnable intValue] At:MATRIX_INDEX_GLOBAL_UNISON_ENABLE];                       // added Sander: (169) UNISON Enable
        [oDoc setGlobalParameter:[globalVolumeInvertEnable intValue] At:MATRIX_INDEX_GLOBAL_VOLUME_INVERT_ENABLE];          // added Sander: (170) Volume Invert Enable
        [oDoc setGlobalParameter:[globalMemoryProtectEnable intValue] At:MATRIX_INDEX_GLOBAL_MEMORY_PROTECT_ENABLE];        // added Sander: (171) Memory Protect Enable
        
		[[MIDIDriver sharedInstance] sendMasterData:[oDoc globalParameters]];
	}
	else
	{
		[Tools showAlertWithMessage:@"Global parameters not initialized, do a GET first." andWindow:oWin];
	}
}



@end
