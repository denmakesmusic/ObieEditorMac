
#import <Cocoa/Cocoa.h>

#import "Controller.h"
#import "MyDocument.h"
#import "MatrixPatchController.h"
#import "GetPatchPanel.h"
#import "StorePatchPanel.h"
#import "ObiePrefPanel.h"


#define USERDEFAULT_KEY_MIDIINPUT @"inputPort"
#define USERDEFAULT_KEY_MIDIOUTPUT @"outputPort"
#define USERDEFAULT_KEY_SENDPATCHONOPEN @"sendPatchOnOpen"
#define USERDEFAULT_KEY_SENDPATCHFORENV1SUSTAIN @"sendPatchForENV1SUSTAIN"
#define USERDEFAULT_KEY_SENDPATCHFORENV2TOVCA2 @"sendPatchForENV2TOVCA2"
#define USERDEFAULT_KEY_SENDPATCHFORLFOSAMPLESOURCE @"sendPatchForLFOSAMPLESOURCE"                  // added Sander.

@implementation Controller


- (id)init
{
    self = [super init];
    if (self) 
	{	
		// register Controller as application delegate
		[NSApp setDelegate:self];

        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		mUserDefaults = [NSUserDefaults standardUserDefaults];
		int oInport = [[mUserDefaults objectForKey:USERDEFAULT_KEY_MIDIINPUT] intValue];
		int oOutport = [[mUserDefaults objectForKey:USERDEFAULT_KEY_MIDIOUTPUT] intValue];
		sendPatchOnOpen = [mUserDefaults boolForKey:USERDEFAULT_KEY_SENDPATCHONOPEN];
		
		if ([mUserDefaults objectForKey:USERDEFAULT_KEY_SENDPATCHFORENV2TOVCA2] == nil)
		{
			[mUserDefaults setBool:TRUE forKey:USERDEFAULT_KEY_SENDPATCHFORENV2TOVCA2];
		}	
		sendPatchForENV2TOVCA2 = [mUserDefaults boolForKey:USERDEFAULT_KEY_SENDPATCHFORENV2TOVCA2];
		if ([mUserDefaults objectForKey:USERDEFAULT_KEY_SENDPATCHFORENV1SUSTAIN] == nil)
		{
			[mUserDefaults setBool:TRUE forKey:USERDEFAULT_KEY_SENDPATCHFORENV1SUSTAIN];
		}
		sendPatchForENV1SUSTAIN = [mUserDefaults boolForKey:USERDEFAULT_KEY_SENDPATCHFORENV1SUSTAIN];
        if ([mUserDefaults objectForKey:USERDEFAULT_KEY_SENDPATCHFORLFOSAMPLESOURCE] == nil)        // added Sander.
        {
            [mUserDefaults setBool:TRUE forKey:USERDEFAULT_KEY_SENDPATCHFORLFOSAMPLESOURCE];
        }
        sendPatchForLFOSAMPLESOURCE = [mUserDefaults boolForKey:USERDEFAULT_KEY_SENDPATCHFORLFOSAMPLESOURCE];
        
		mMIDIDriver = [MIDIDriver sharedInstance];
		[mMIDIDriver setMIDIInput:oInport Output:oOutport];
		
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
//	NSLog(@"applicationDidFinishLaunching\n");
    // To get service requests to go to the controller...
    [NSApp setServicesProvider:self];

}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    return NO;
}

- (MIDIDriver *)getMIDIDriver
{
	return mMIDIDriver;
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app 
{
    unsigned needsSaving = 0;
 
	NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
	NSArray *oDocs = [docCont documents];
	int count = [oDocs count];
    // Determine if there are any unsaved documents...
    while (count--) 
	{
        MyDocument *document = [oDocs objectAtIndex:count];
        if (document && [document isDocumentEdited]) 
		{
			needsSaving++;
		}
    }
    if (needsSaving > 0) 
	{
        int choice = NSAlertDefaultReturn;	// Meaning, review changes
		if (needsSaving > 1) 
		{	// If we only have 1 unsaved document, we skip the "review changes?" panel
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"You have %d documents with unsaved changes. Do you want to review these changes before quitting?", @"Title of alert panel which comes up when user chooses Quit and there are multiple unsaved documents."), needsSaving];
			choice = NSRunAlertPanel(title, 
				NSLocalizedString(@"If you don\\U2019t review your documents, all your changes will be lost.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents."), 
				NSLocalizedString(@"Review Changes\\U2026", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."), 	// ellipses
				NSLocalizedString(@"Discard Changes", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."), 
				NSLocalizedString(@"Cancel", @"Button choice allowing user to cancel."));
			if (choice == NSAlertOtherReturn) 
			{
				return NSTerminateCancel;       	// Cancel 
			}
        }
		if (choice == NSAlertDefaultReturn) 
		{	// Review unsaved; Quit Anyway falls through             
//            [MyDocument reviewChangesAndQuitEnumeration:YES];
            return NSTerminateLater;
        }
    }    
    return NSTerminateNow;
}



- (void)applicationWillTerminate:(NSNotification *)notification 
{
//	NSLog(@"applicationWillTerminate\n");
    //[Preferences saveDefaults];
}

/*
-(BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	return FALSE;
}
*/

- (void)openPreferences:(id)sender
{
//	NSLog(@"OpenPreferences");
	ObiePrefPanel *oPanel = [[ObiePrefPanel alloc] initWithWindowNibName:@"PrefPanel"];
	int oRes = [NSApp runModalForWindow:[oPanel window]];
	if (oRes > 0)
	{
		int inp = [oPanel midiInputPort];
		int outp = [oPanel midiOutputPort];
		sendPatchOnOpen = [oPanel sendPatchOnOpen];
		sendPatchForENV2TOVCA2 = [oPanel sendPatchForENV2TOVCA2];
		sendPatchForENV1SUSTAIN = [oPanel sendPatchForENV1_SUSTAIN];
        sendPatchForLFOSAMPLESOURCE = [oPanel sendPatchForLFOSAMPLESOURCE];
		
		[mMIDIDriver setMIDIInput:inp Output:outp];
		[mUserDefaults setObject:[NSString stringWithFormat:@"%d",inp] forKey:USERDEFAULT_KEY_MIDIINPUT];
		[mUserDefaults setObject:[NSString stringWithFormat:@"%d",outp] forKey:USERDEFAULT_KEY_MIDIOUTPUT];
		[mUserDefaults setBool:sendPatchOnOpen forKey:USERDEFAULT_KEY_SENDPATCHONOPEN];
		[mUserDefaults setBool:sendPatchForENV2TOVCA2 forKey:USERDEFAULT_KEY_SENDPATCHFORENV2TOVCA2];
		[mUserDefaults setBool:sendPatchForENV1SUSTAIN forKey:USERDEFAULT_KEY_SENDPATCHFORENV1SUSTAIN];
        [mUserDefaults setBool:sendPatchForLFOSAMPLESOURCE forKey:USERDEFAULT_KEY_SENDPATCHFORLFOSAMPLESOURCE];
		[mUserDefaults synchronize];
	}
	[oPanel release];
}

- (bool)sendPatchOnOpen
{
	return sendPatchOnOpen;
}

- (bool)sendPatchForENV1SUSTAIN
{
	return sendPatchForENV1SUSTAIN;
}

- (bool)sendPatchForENV2TOVCA2
{
	return sendPatchForENV2TOVCA2;
}

- (bool)sendPatchForLFOSAMPLESOURCE                     // added Sander.
{
    return sendPatchForLFOSAMPLESOURCE;
}


// envoie le patch courant au synthe
- (void)sendPatch:(id)sender
{
//	NSLog(@"sendPatch\n");
	NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
	MyDocument *oDoc = [docCont currentDocument];
	[self sendPatchFromDoc:oDoc];
}

- (void)sendPatchFromDoc:(MyDocument *)aDoc
{	
    [mMIDIDriver sendPatch:[aDoc patch]];
}

// appelee par le document lorsqu'il a initialisé ses donnees
- (void)notifyNewDocument:(MyDocument *)aDoc
{
    if (sendPatchOnOpen)
	{
		[self sendPatchFromDoc:aDoc];
	}
}


// recupere un patch sur le synthe
- (void)getPatch:(id)sender
{
//	NSLog(@"getPatch\n");
	GetPatchPanel *oPanel = [[GetPatchPanel alloc] initWithWindowNibName:@"GetPatchPanel"];
	int oRes = [NSApp runModalForWindow:[oPanel window]];
	if (oRes > 0)
	{
		[mMIDIDriver setBank:[oPanel bankNumber]];
		[mMIDIDriver sendRequestDataType:1 Number:[oPanel patchNumber]];
		//	[mMIDIDriver sendRequestDataType:1 Number:0];
		uint8_t oBuffer[PATCH_TAB_SIZE];
		MPSemaphoreID delay;	
		MPCreateSemaphore(1, 0, &delay); // a binary semaphore
		int oReceiveCount = 0;
		if (oReceiveCount == 0)
		{
            MPWaitOnSemaphore(delay, 500 * kDurationMillisecond);
			oReceiveCount = [mMIDIDriver getReceivedBytes:oBuffer maxSize:PATCH_TAB_SIZE];
		}
		if (oReceiveCount == PATCH_TAB_SIZE)
		{
            // on instancie un nouveau document avec le patch recu
			NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
//			MyDocument *oDoc = [docCont makeUntitledDocumentOfType:@"Matrix 1000 patch"];       // deprecated.
            NSError *makeUntitledDocumentOfTypeError;                                           // added Sander.
            MyDocument *oDoc = [docCont makeUntitledDocumentOfType:@"Matrix 1000 patch" error:&makeUntitledDocumentOfTypeError];
			[oDoc setParameters:oBuffer];
			[docCont addDocument:oDoc];
			[oDoc makeWindowControllers];
			NSWindowController *oWinCont = [[oDoc windowControllers] objectAtIndex:0];
			[oWinCont window];
			[oDoc showWindows];
			// envoyer le patch au synthe
			[self sendPatchFromDoc:oDoc];
		}
        else
        {
            NSLog(@"getPatch: No response from M1000.");
        }
	}
	[oPanel release];
}

// recupere le patch en cours d'edition
- (void)getEditBuffer:(id)sender
{
//    NSLog(@"GetEditBuffer");

    [mMIDIDriver sendRequestDataType:4 Number:0];
	uint8_t oBuffer[PATCH_TAB_SIZE];
	MPSemaphoreID delay;	
	MPCreateSemaphore(1, 0, &delay); // a binary semaphore
    int oReceiveCount = 0;
    if (oReceiveCount == 0)             // changed while into if state ment, if there is response, it will come within 500ms.
	{
        MPWaitOnSemaphore(delay, 500 * kDurationMillisecond);
		oReceiveCount = [mMIDIDriver getReceivedBytes:oBuffer maxSize:PATCH_TAB_SIZE];
	}
	if (oReceiveCount == PATCH_TAB_SIZE)
	{
		// on instancie un nouveau document avec le patch recu
        NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
//        MyDocument *oDoc = [docCont makeUntitledDocumentOfType:[MyDocument documentType]];  // deprecated.
        NSError *makeUntitledDocumentOfTypeError;
        MyDocument *oDoc = [docCont makeUntitledDocumentOfType:[MyDocument documentType] error:&makeUntitledDocumentOfTypeError];
		[oDoc setParameters:oBuffer];
		[docCont addDocument:oDoc];
		[oDoc makeWindowControllers];
		NSWindowController *oWinCont = [[oDoc windowControllers] objectAtIndex:0];
		[oWinCont window];
		[oDoc showWindows];
        
        [oDoc getGlobalParameters:self];  //added Sander; after loading Patch data, the GlobalParameters are also loaded.
	}
    else
    {
        NSLog(@"getEditBuffer: No response from M1000.");
    }
}

- (void)storePatch:(id)sender
{
//	NSLog(@"storePatch");
	NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
	MyDocument *oDoc = [docCont currentDocument];
/*
	// version en dialog normal
	StorePatchPanel *oPanel = [[StorePatchPanel alloc] initWithWindowNibName:@"StorePatchPanel"];
	int oRes = [NSApp runModalForWindow:[oPanel window]];
	if (oRes > 0)
	{
		[mMIDIDriver storePatch:[oDoc patch] Bank:[oPanel bankNumber] Number:[oPanel patchNumber]];
	}
	[oPanel release];
	*/
	// version sheet 
    if (!mStoreSheet)
	{
        [NSBundle loadNibNamed: @"StoreSheet" owner: self];
	}	
	NSWindow *oWin = [oDoc windowForSheet];
    [NSApp beginSheet: mStoreSheet
            modalForWindow: oWin
            modalDelegate: self
            didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
            contextInfo: nil];
}

- (IBAction)storeOKAction:(id)sender
{
    [NSApp endSheet:mStoreSheet];
	NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
	MyDocument *oDoc = [docCont currentDocument];
	[mMIDIDriver storePatch:[oDoc patch] Bank:[bankNumber intValue] Number:[patchNumber intValue]];
}

- (IBAction)storeCancelAction:(id)sender
{
    [NSApp endSheet:mStoreSheet];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// indispensable sinon le sheet reste affiché
    [sheet orderOut:self];
}

@end


