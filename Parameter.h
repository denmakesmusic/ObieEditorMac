//
//  Parameter.h
//  ObieEditor2
//
//  Created by groumpf on 22/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol Parameter

- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;


@end
