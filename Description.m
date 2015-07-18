//
//  Description.m
//  MQEditor
//
//  Created by groumpf on 06/05/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Description.h"


@implementation Description

// instance
static Description *soundInstance = NULL;

+ (Description *)soundInstance {
	if (soundInstance == nil)
	{
		soundInstance = [[self alloc] init:@"sounddesc"];
	}
    return soundInstance;
}


- (id)init:(NSString*)aFile 
{
	if (self = [super init]) 
	{
		//NSLog(@"Description.init\n");
		// charger la description
		NSString *path = [[NSBundle mainBundle] pathForResource:aFile ofType:@"plist"];
		//NSLog(@"path = %@", path);
		soundDesc =  [NSDictionary dictionaryWithContentsOfFile:path];
		[soundDesc retain];
    }
    return self;
}

- (void)dealloc {
    if (self != soundInstance) [super dealloc];	// Don't free the shared instance
}

- (NSDictionary*)soundDescription
{
	return soundDesc;
}

- (NSDictionary*)getObject:(int)aParameterNumber
{
	NSString *keyStr = [NSString stringWithFormat:@"%d", aParameterNumber];
	return [soundDesc objectForKey:keyStr];
}

- (id)getObjectParameter:(NSString*)aParameterNumber Key:(NSString*)aKey;
{
	NSDictionary *dico = [soundDesc objectForKey:aParameterNumber];
	return [dico objectForKey:aKey];
}

- (int)getMin:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"min"];
	int oMin = num == NULL ? 0 : [num intValue];
	return oMin;
}

- (int)getMax:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"max"];
	int oMax = num == NULL ? 127 : [num intValue];
	return oMax;
}

- (int)getOffset:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"offset"];
	int oOffset = num == NULL ? 0 : [num intValue];
	return oOffset;
}

- (NSArray*)getValueNames:(NSDictionary*)aObject
{
	NSArray *oArray = [aObject objectForKey:@"valueNames"];
	return oArray;
}

- (NSArray*)getValues:(NSDictionary*)aObject
{
	NSArray *oArray = [aObject objectForKey:@"values"];
	return oArray;
}

- (int)getMask:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"mask"];
	int oMask = num == NULL ? 127 : [num intValue];
	return oMask;	
}

// retourne le min affiche ou le min si aucun displayMin n'est defini
- (int)getDisplayMin:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"displayMin"];
	int oMin = num == NULL ? [self getMin:aObject] : [num intValue];
	return oMin;
}

// retourne le max affiche ou le max si aucun displayMax n'est defini
- (int)getDisplayMax:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"displayMax"];
	int oMax = num == NULL ? [self getMax:aObject] : [num intValue];
	return oMax;
}

- (int)offsetFrom:(NSDictionary*)aObject
{
	NSNumber *num = [aObject objectForKey:@"offsetFrom"];
	int oOff = num == NULL ? 0 : [num intValue];
	return oOff;
}



@end
