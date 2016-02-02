/* ParamSlider */

#import <Cocoa/Cocoa.h>

#import "Description.h"
#import "Parameter.h"

@interface ParamSlider : NSSlider <Parameter>
{
	int offset;	// offset pour les valeurs du GUI
    int AddValueDisplay; // For display of values of a fader. (Sander)
}

- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;

@end
