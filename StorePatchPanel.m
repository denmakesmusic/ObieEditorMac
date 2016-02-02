#import "StorePatchPanel.h"

@implementation StorePatchPanel

- (int)bankNumber
{
	return [bankNumber intValue];
}

- (int)patchNumber
{
	return [patchNumber intValue];
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
