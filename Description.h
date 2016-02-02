//
//  Description.h
//  MQEditor
//
//  Created by groumpf on 06/05/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Description : NSObject 
{
	NSDictionary *soundDesc;

}

+ (Description *)soundInstance;

- (id)init:(NSString*)aFile;

- (id)getObjectParameter:(NSString*)aParameterNumber Key:(NSString*)aKey;
- (NSDictionary*)getObject:(int)aParameterNumber;
- (int)getMin:(NSDictionary*)aObject;
- (int)getMax:(NSDictionary*)aObject;
- (int)getOffset:(NSDictionary*)aObject;
- (NSArray*)getValueNames:(NSDictionary*)aObject;
- (NSArray*)getValues:(NSDictionary*)aObject;
- (int)getMask:(NSDictionary*)aObject;
- (int)getDisplayMin:(NSDictionary*)aObject;
- (int)getDisplayMax:(NSDictionary*)aObject;
- (int)offsetFrom:(NSDictionary*)aObject;
- (int)getAddValueDisplay:(NSDictionary*)aObject;    // added Sander: for displaying fader values.

@end
