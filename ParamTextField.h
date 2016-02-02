/* ParamTextField */

#import <Cocoa/Cocoa.h>

#import "Description.h"
#import "Parameter.h"

@interface ParamTextField : NSTextField <Parameter>
{
	// point d'origine du clic
	NSPoint origine;	
	
	int max;	// max 
	int min;	// min 
	int offset;	// offset pour les valeurs du GUI
	int displayMin; // min affiche
	int displayMax; // max affiche
	int offsetFrom;
	
	// masque pour les champs de bits
	int mask;	
}

- (int)min;
- (int)max;
- (void)updateValue:(int)value;
- (void)setIntValueFromDoc:(int)aValue;
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription;

@end
