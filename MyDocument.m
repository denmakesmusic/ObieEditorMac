//
//  MyDocument.m
//  ObieEditor
//
//  Created by groumpf on Mon Apr 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"

#import "Controller.h"
//#import "MatrixPatchController.h"
#import "Description.h"
#import "ParamTextField.h"
#import "ParamPopUpButton.h"
#import "ParamSlider.h"
#import "ParamCheckbox.h"
#import "Parameter.h"

enum
{
	TAB_WAVE, 
	TAB_MOD,
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
	GLOBAL_TAG_VIB_SPEED = 200,
	GLOBAL_TAG_VIB_MOD_SOURCE,
	GLOBAL_TAG_VIB_MOD_AMOUNT,
	GLOBAL_TAG_VIB_WAVE,
	GLOBAL_TAG_VIB_AMP,
	GLOBAL_TAG_VIB_AMP_MOD_SOURCE,
	GLOBAL_TAG_VIB_AMP_MOD_AMOUNT,
	GLOBAL_TAG_BEND_RANGE,
	GLOBAL_TAG_BEND_RANGE_DISPLAY,
	GLOBAL_TAG_LEVER_2 = 210,
	GLOBAL_TAG_LEVER_3,
	GLOBAL_TAG_PEDAL_1,
	GLOBAL_TAG_PEDAL_2
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

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"M1000";
}

/*
- (void)makeWindowControllers
{
	//NSLog(@"makeWindowControllers\n");

	Controller *cont = [NSApp delegate];
	mMIDIDriver = [cont getMIDIDriver];		

	[self addWindowController:[[MatrixPatchController alloc] initWithWindowNibName:@"M1000"]];
}
*/


/* Return the document in the specified window.
*/
+ (MyDocument *)documentForWindow:(NSWindow *)window 
{
    id delegate = [window delegate];
    return (delegate && [delegate isKindOfClass:[MyDocument class]]) ? delegate : nil;
}


- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	//NSLog(@"dataRepresentationOfType: %@", aType);
    NSAssert([aType isEqualToString:MyDocumentType], @"Unknown type");

	return [NSData dataWithBytes:mParameters length:FILE_PATCH_SIZE];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    NSAssert([aType isEqualToString:MyDocumentType], @"Unknown type");
	
	NSRange oRange2 = {0, FILE_PATCH_SIZE-1};
	[data getBytes:mParameters range:oRange2];

	// prevenir le controller
	[[NSApp delegate] notifyNewDocument:self];
	
	return YES;
}

// appele quand on fait file->revert
- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL oReverted = [super revertToContentsOfURL:absoluteURL ofType:typeName error:outError];
	if (oReverted)
	{
		// on rafraichit l'interface
		NSArray* oWinContrs = [self windowControllers];
		int i;
		for (i = 0; i < [oWinContrs count]; i++)
		{
			[self windowControllerDidLoadNib:[oWinContrs objectAtIndex:i]];
		}	
	}
	return oReverted;
}

// accesseur pour les donnees, appeles par NSWindowController

- (void)setPatchName:(NSString *)aName
{
	[aName getCString:(char*)mParameters maxLength:8 encoding:NSASCIIStringEncoding];
	[self updateChangeCount:NSChangeDone];
}

- (NSString *)patchName
{
	return [[NSString alloc] initWithBytes:mParameters length:8 encoding:NSASCIIStringEncoding];
}

- (uint8_t*)patch
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
	// cas particulier du detune (on recoit 0..62)
	if (aIndex == MATRIX_INDEX_DCO2_DETUNE)
	{
		// 0..62
		if (oValue < 31)
		{
			oValue += 97; // 97..127 (bon je ne comprend pas tout mais ca marche...)
			// mettre a jour le modele
			// en fait j'ai constate que si je met dans le modele la meme valeur que 
			// j'envoie, ca ne marche pas, il faut mettre dans le modele (et lorsqu'on
			// envoie le patch complet) le bit de poids fort a 1 pour les negatifs
			mParameters[aIndex] = oValue | 0x80;
		}
		else
		{
			oValue -= 31;
			mParameters[aIndex] = oValue;
		}
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
	 || (aIndex == MATRIX_INDEX_ENV2_TO_VCA2 && [cont sendPatchForENV2TOVCA2]))
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

- (void)setParameters:(uint8_t*)aPatch
{
	[self updateChangeCount:NSChangeDone];
	memcpy(mParameters, aPatch, PATCH_TAB_SIZE);
	NSString *oPatchName = [[NSString alloc] initWithBytes:aPatch length:8 encoding:NSASCIIStringEncoding];
	[mPatchName setStringValue:oPatchName];
}


- (int)getParameter:(int)aIndex;
{
	int oValue =  mParameters[aIndex];
	// cas particulier du detune doit retourner 0..62
	if (aIndex == MATRIX_INDEX_DCO2_DETUNE)
	{   
		oValue = mParameters[aIndex] & 0x7F; // 97..127  0..31
		if (oValue >= 97)
		{
			oValue -= 97;
		}
	}
	else
	if (aIndex != MATRIX_INDEX_FILTER_FREQ && oValue > 63)
	{
		oValue -= 128;
	}
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
	//NSLog(@"view = %@", oView);
	NSArray *subviews = [oView subviews];
	//NSLog(@"subviews = %@", subviews);
	
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
	[mPatchName setStringValue:[self patchName]];
	[mPatchName setDelegate:self];
	
	// global parameters
	NSView *oTabGlobal = [[oTabs objectAtIndex:TAB_GLOBAL] view];
	NSArray *gSou = [NSArray arrayWithObjects:@"Off", @"Lever2", @"Pedal1", nil];
	NSPopUpButton *globalVibratoSpeedModSource = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_MOD_SOURCE];
	[globalVibratoSpeedModSource removeAllItems];
	[globalVibratoSpeedModSource addItemsWithTitles:gSou];
	NSPopUpButton *globalVibratoWaveform = [oTabGlobal viewWithTag:GLOBAL_TAG_VIB_WAVE];
	[globalVibratoWaveform removeAllItems];
	NSArray *vibratoWaves = [NSArray arrayWithObjects:@"Triangle", @"Up sawtooth", @"Down sawtooth", @"Square", @"Random", @"Noise", nil];
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
	
	[self updateGlobalParameters];

	// premier tab
	[oTabView selectFirstTabViewItem:self];

}

- (void)setObjectUI:(NSView*)aView dico:(id)aDico tag:(int)aTag
{
	MyDocument *doc = self;
	//NSLog(@"tag = %d value = %d", oTag, [doc getParameter:oTag]);
	if ([aView conformsToProtocol:@protocol(Parameter)])
	{
		[(id<Parameter>)aView setUI:aDico description:[Description soundInstance]];
		[(id<Parameter>)aView setIntValueFromDoc:[doc getParameter:aTag]];
	}
}

// Global parameters

- (IBAction)getGlobalParameters:(id)sender
{
	[[MIDIDriver sharedInstance] sendRequestDataType:3 Number:0];
	uint8_t oBuffer[MASTER_DATA_SIZE];
	MPSemaphoreID delay;	
	MPCreateSemaphore(1, 0, &delay); // a binary semaphore
	int oReceiveCount = 0;
	while(oReceiveCount == 0)
	{
		MPWaitOnSemaphore(delay, 500 * kDurationMillisecond);
		oReceiveCount = [[MIDIDriver sharedInstance] getReceivedBytes:oBuffer maxSize:MASTER_DATA_SIZE];
	}
	if (oReceiveCount == MASTER_DATA_SIZE)
	{
		[self setGlobalParameters:oBuffer];
		[self updateGlobalParameters];
	}
}

// update global parameter display with document values
-(void)updateGlobalParameters
{
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
}

// met a jour le document et envoie les parametres au synthe
- (IBAction)sendGlobalParameters:(id)sender
{
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
		
		[[MIDIDriver sharedInstance] sendMasterData:[oDoc globalParameters]];	
	}
	else
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Global parameters not initialized, do a GET first."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:oWin modalDelegate:self didEndSelector:NULL contextInfo:nil];
	}
}

- (IBAction)patchNameAction:(id)sender
{
	// pas de parametre pour le nom
	NSString *str = [[mPatchName stringValue] substringToIndex:8];
	[self setPatchName:str];
	[mPatchName setStringValue:str]; 
}



@end
