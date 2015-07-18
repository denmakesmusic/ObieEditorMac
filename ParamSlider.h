/* ParamSlider */

#import <Cocoa/Cocoa.h>

#import "Description.h"
#import "Parameter.h"

@interface ParamSlider : NSSlider <Parameter>
{
	int offset;	// offset pour les valeurs du GUI
}

- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;

@end
