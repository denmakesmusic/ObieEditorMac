//
//  Tools.m
//  ObieEditor2
//
//  Created by groumpf on 07/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "Tools.h"

@implementation Tools


+(void)showAlertWithMessage:(NSString *)aMessage andWindow:(NSWindow *)aWindow
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:aMessage];
	[alert setAlertStyle:NSWarningAlertStyle];
	if (aWindow == nil)
	{
		[alert runModal];
	}
	else
	{
		[alert beginSheetModalForWindow:aWindow	modalDelegate:nil didEndSelector:NULL contextInfo:nil];
	}
}



@end