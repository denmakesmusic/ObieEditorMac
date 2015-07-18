/* ParamPopUpButton */

#import <Cocoa/Cocoa.h>

#import "Description.h"
#import "Parameter.h"

@interface ParamPopUpButton : NSPopUpButton <Parameter>
{
	int min;	// min affiche
	NSArray *values;
	
	// masque pour les champs de bits
	int mask;	
	
	id previousTarget;
}

- (void)popupAction:(id)sender;
- (NSArray*)values;
- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;

@end
