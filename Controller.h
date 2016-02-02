#import <Cocoa/Cocoa.h>

#import "MIDIDriver.h"
#import "StorePatchPanel.h"
#import "MyDocument.h"

@interface Controller : NSObject <NSApplicationDelegate>
{

    NSMutableArray *openFailures;	// Files that couldn't be opened

	NSUserDefaults *mUserDefaults;
	MIDIDriver *mMIDIDriver;
	bool sendPatchOnOpen;
	bool sendPatchForENV1SUSTAIN;
	bool sendPatchForENV2TOVCA2;
    bool sendPatchForLFOSAMPLESOURCE;           // added Sander.
	
	id mStoreSheet;
	IBOutlet id bankNumber;
    IBOutlet id patchNumber;
    
    
}



// accessors
- (MIDIDriver *)getMIDIDriver;
- (bool)sendPatchOnOpen;
- (bool)sendPatchForENV1SUSTAIN;
- (bool)sendPatchForENV2TOVCA2;
- (bool)sendPatchForLFOSAMPLESOURCE;            // added Sander.

- (IBAction)storeOKAction:(id)sender;
- (IBAction)storeCancelAction:(id)sender;



/* NSApplication delegate methods */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app;
//-(BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication;
 
/* Action methods 
- (void)createNew:(id)sender;
- (void)open:(id)sender;
- (void)saveAll:(id)sender;
*/

- (void)openPreferences:(id)sender;

- (void)sendPatch:(id)sender;
- (void)getPatch:(id)sender;
- (void)storePatch:(id)sender;

- (void)sendPatchFromDoc:(MyDocument *)aDoc;

//
// recupere le patch en cours d'edition
//
- (void)getEditBuffer:(id)sender;

// appelee par le document lorsqu'il a initialisé ses donnees
- (void)notifyNewDocument:(MyDocument *)aDoc;

@end
