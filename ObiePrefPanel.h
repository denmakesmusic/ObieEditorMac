/* ObiePrefPanel */

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/NSPreferencePane.h>

@interface ObiePrefPanel : NSWindowController
{
    IBOutlet id midiInputPort;
    IBOutlet id midiOutputPort;
	IBOutlet id sendPatchOnOpen;
	IBOutlet NSButton* sendPatchForENV1_SUSTAIN;
	IBOutlet NSButton* sendPatchForENV2TOVCA2;
    IBOutlet NSButton* sendPatchForLFOSAMPLESOURCE;
}

- (int)midiInputPort;
- (int)midiOutputPort;
- (bool)sendPatchOnOpen;
- (bool)sendPatchForENV1_SUSTAIN;
- (bool)sendPatchForENV2TOVCA2;
- (bool)sendPatchForLFOSAMPLESOURCE;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
