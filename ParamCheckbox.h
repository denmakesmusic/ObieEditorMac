/* ParamCheckbox */

#import <Cocoa/Cocoa.h>

#import "Description.h"
#import "Parameter.h"

@interface ParamCheckbox : NSButton <Parameter>
{
	int mask;
}

- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;

@end
