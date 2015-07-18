//
//  GetPatchPanel.m
//  ObieEditor
//
//  Created by groumpf on Wed Apr 21 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "GetPatchPanel.h"


@implementation GetPatchPanel

- (IBAction)okAction:(id)sender
{
	[NSApp stopModalWithCode:1];
}

- (IBAction)cancelAction:(id)sender;
{
	[NSApp stopModalWithCode:0];
}

- (int)bankNumber
{
	return [bankNumber intValue];
}

- (int)patchNumber
{
	return [patchNumber intValue];
}

@end
