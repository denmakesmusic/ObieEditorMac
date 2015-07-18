/* StorePatchPanel */

#import <Cocoa/Cocoa.h>

@interface StorePatchPanel : NSWindowController
{
	IBOutlet id bankNumber;
    IBOutlet NSTextField *patchNumber;
}

-(int)bankNumber;
-(int)patchNumber;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
