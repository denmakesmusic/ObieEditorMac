//
//  PatchNameFormatter.m
//  ObieEditor2
//
//  Created by groumpf on 25/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatchNameFormatter.h"


@implementation PatchNameFormatter

- (id)init {
	[super init];
	maxLength = 8;
	characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789()*-+'\"?.[]/$=^_!:;,&@#<>"] retain];
	return self;
}


- (NSString *)stringForObjectValue:(id)object {
	return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
	*object = string;
	return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
	   proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
			  originalString:(NSString *)origString
	   originalSelectedRange:(NSRange)origSelRange
			errorDescription:(NSString **)error 
{
//	NSLog(@"*partialStringPtr = >%@<", *partialStringPtr);
	
    if ([*partialStringPtr length] > maxLength) {
//        NSLog(@"partialString > maxLength: %d", maxLength);
        return NO;
    }
	
	NSString* oNewStr = [*partialStringPtr uppercaseString];
//    NSLog(@"patchNameFormatter | newStr = >%@<", oNewStr);
	int i;
	for (i = 0; i < [oNewStr length]; i++)
	{
//        NSLog(@"i = %d | stringLength = %lu", i, (unsigned long)[oNewStr length]);
        if ([characterSet characterIsMember:[oNewStr characterAtIndex:i]] == FALSE)
		{
            return NO;
		}
	}
	
    if (![*partialStringPtr isEqual:[*partialStringPtr uppercaseString]]) {
		*partialStringPtr = [*partialStringPtr uppercaseString];
//        NSLog(@"*partialStringPtr uppercase corrected.");
		return NO;
    }

//    NSLog(@"Return YES: i = %d | *partialStringPtr = >%@<", i, *partialStringPtr);
    return YES;
}


- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return nil;
}

-(void)dealloc
{
	[characterSet release];
	[super dealloc];
}

@end
