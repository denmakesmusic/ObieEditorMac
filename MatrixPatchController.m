//
//  MatrixPatchController.m
//  ObieEditor
//
//  Created by groumpf on Tue Apr 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "MatrixPatchController.h"
#import "MyDocument.h"
#import "Description.h"
#import "ParamTextField.h"
#import "ParamPopUpButton.h"
#import "ParamSlider.h"
#import "ParamCheckbox.h"

@implementation MatrixPatchController

- (void)windowDidLoad
{
//	NSLog(@"windowDidLoad %@ %d\n", keyMode, [self isWindowLoaded]);
    
    MyDocument *doc = [self document];
	NSWindow *oWin = [self window];
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
	[mPatchName setStringValue:[doc patchName]];
	
	// premier tab
	[oTabView selectFirstTabViewItem:self];
	
	[self updateGlobalParameters];
}

- (void)setObjectUI:(NSView*)aView dico:(id)aDico tag:(int)aTag
{
	MyDocument *doc = [self document];
	//NSLog(@"tag = %d value = %d", oTag, [doc getParameter:oTag]);
	if ([aView conformsToProtocol:@protocol(Parameter)])
	{
		[(id<Parameter>)aView setUI:aDico description:[Description soundInstance]];
		[(id<Parameter>)aView setIntValueFromDoc:[doc getParameter:aTag]];
	}
}


- (IBAction)patchNameAction:(id)sender
{
	// pas de parametre pour le nom
    NSLog(@"PAtchNameAction from MatrixPatchController.");
	[[self document] setPatchName:[mPatchName stringValue]]; 
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
		MyDocument *oDoc = [self document];
		[oDoc setGlobalParameters:oBuffer];
		[self updateGlobalParameters];
	}
}

// update global parameter display with document values
- (void)updateGlobalParameters
{
/*
	MyDocument *oDoc = [self document];
	[globalVibratoSpeed setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED]];
	[globalVibratoSpeedModSource selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_SOURCE]];
	[globalVibratoSpeedModAmount setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_AMOUNT]];
	[globalVibratoAmplitude setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP]];
	[globalVibratoWaveform selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_WAVEFORM]];
	[globalVibratoAmpModAmount setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_AMOUNT]];
	[globalVibratoAmpModSource selectItemAtIndex:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_SOURCE]];
	[globalLever2 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_2]];
	[globalLever2Control setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_2]];
	[globalLever3 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_3]];
	[globalLever3Control setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_LEVER_3]];
	[globalPedal1 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_1]];
	[globalPedal1Control setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_1]];
	[globalPedal2 setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_2]];
	[globalPedal2Control setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_MIDI_PEDAL_2]];
	[globalBendRange setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_BEND_RANGE]];
	[globalBendRangeDisplay setIntValue:[oDoc getGlobalParameter:MATRIX_INDEX_GLOBAL_BEND_RANGE]];
	*/
}

// met a jour le document et envoie les parametres au synthe
- (IBAction)sendGlobalParameters:(id)sender
{
/*
	MyDocument *oDoc = [self document];
	if ([oDoc validGlobalparameters])
	{
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
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:NULL contextInfo:nil];
	}
	*/
}


@end
