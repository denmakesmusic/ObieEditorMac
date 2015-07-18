//
//  GetPatchPanel.h
//  ObieEditor
//
//  Created by groumpf on Wed Apr 21 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface GetPatchPanel : NSWindowController {

    IBOutlet NSSlider *bankNumber;
    IBOutlet NSSlider *patchNumber;

}

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

- (int)bankNumber;
- (int)patchNumber;

@end
