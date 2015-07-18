//
//  MatrixPatchController.h
//  ObieEditor
//
//  Created by groumpf on Tue Apr 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface MatrixPatchController : NSWindowController 
{
	IBOutlet NSTextField *mPatchName;	
}

- (IBAction)patchNameAction:(id)sender;

	// get Global parameters
- (IBAction)getGlobalParameters:(id)sender;

	// send global parameters
- (IBAction)sendGlobalParameters:(id)sender;

-(void)updateGlobalParameters;

- (void)setObjectUI:(NSView*)aView dico:(id)aDico tag:(int)aTag;


@end
