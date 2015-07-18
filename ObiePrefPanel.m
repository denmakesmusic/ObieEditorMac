#import "ObiePrefPanel.h"
#import "MIDIDriver.h"
#import "Controller.h"

@implementation ObiePrefPanel


- (NSString *)mainNibName
{
	return @"PrefPanel";
}

- (void)windowDidLoad
{
	NSArray *oInputs = [[MIDIDriver sharedInstance] midiInputs];
	[midiInputPort removeAllItems];	
	if ([oInputs count] > 0 && [[MIDIDriver sharedInstance] inputPortNumber] < [oInputs count])
	{
		[midiInputPort addItemsWithTitles:oInputs];
		[midiInputPort selectItemAtIndex:[[MIDIDriver sharedInstance] inputPortNumber]];
	}
	else
	{
		[midiInputPort addItemWithTitle:@"no input"];
		[midiInputPort setEnabled:NO];
	}
	NSArray *oOutputs = [[MIDIDriver sharedInstance] midiOutputs];
	[midiOutputPort removeAllItems];	
	if ([oOutputs count] > 0 && [[MIDIDriver sharedInstance] outputPortNumber] < [oOutputs count])
	{
		[midiOutputPort addItemsWithTitles:oOutputs];
		[midiOutputPort selectItemAtIndex:[[MIDIDriver sharedInstance] outputPortNumber]];
	}
	else
	{
		[midiOutputPort addItemWithTitle:@"no output"];
		[midiOutputPort setEnabled:NO];
	}
	Controller* oCont = [NSApp delegate];
	bool oSendOnOpen = [oCont sendPatchOnOpen];
	[sendPatchOnOpen setState:(oSendOnOpen ? NSOnState : NSOffState)];
	BOOL oSendPatchForENV1 = [oCont sendPatchForENV1SUSTAIN];
	[sendPatchForENV1_SUSTAIN setState:(oSendPatchForENV1 ? NSOnState : NSOffState)];
	BOOL oSendPatchForENV2 = [oCont sendPatchForENV2TOVCA2];
	[sendPatchForENV2TOVCA2 setState:(oSendPatchForENV2 ? NSOnState : NSOffState)];
}

-(int)midiInputPort
{
	return [midiInputPort indexOfSelectedItem];
}

-(int)midiOutputPort
{
	return [midiOutputPort indexOfSelectedItem];
}

-(bool)sendPatchOnOpen
{
	return [sendPatchOnOpen state] == NSOnState;
}

-(bool)sendPatchForENV1_SUSTAIN
{
	return [sendPatchForENV1_SUSTAIN state] == NSOnState;
}

-(bool)sendPatchForENV2TOVCA2
{
	return [sendPatchForENV2TOVCA2 state] == NSOnState;
}




- (IBAction)okAction:(id)sender
{
	[NSApp stopModalWithCode:1];
}

- (IBAction)cancelAction:(id)sender;
{
	[NSApp stopModalWithCode:0];
}


@end
