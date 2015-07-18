//
//  PatchNameFormatter.h
//  ObieEditor2
//
//  Created by groumpf on 25/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PatchNameFormatter : NSFormatter {

	int maxLength;
	NSCharacterSet* characterSet;
}

@end
