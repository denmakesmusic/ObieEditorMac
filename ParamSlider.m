#import "ParamSlider.h"
#import "Description.h"
#import "MIDIDriver.h"
#import "MyDocument.h"

@implementation ParamSlider

- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription
{
	offset = [aDescription getOffset:aObject];
	
	[self setTarget:self];
	[self setAction:@selector(moveAction:)];
}

- (void)moveAction:(id)sender
{
	int oTag = [sender tag];
	int oParamNum = oTag;
	int oValue = [sender intValue] - offset;
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (oTag > 20000)
	{
		// poids fort
		oParamNum = (int)(oTag - 20000);
		oValue = ([myDoc getParameter:oParamNum] & 0x0F ) | (oValue << 4);
	}
	else if (oTag > 10000)
	{
		// poids faible
		oParamNum = oTag - 10000;
		oValue = ([myDoc getParameter:oParamNum] & 0xF0 ) | (oValue);
	}
	// mettre a jour le document
	[myDoc setParameter:oValue At:oParamNum];
	
	// cas particulier (aurait necessite d'autres classes...
	if (oTag == 20)
	{
		// balance DCO1 DCO2
		NSTextField *oTF = [[self superview] viewWithTag:999];
		[oTF setIntValue:oValue];
	}
}

- (void)setIntValueFromDoc:(int)aValue
{
	int oTag = [self tag];
	//NSLog(@"setIntValueFromDoc %d tag=%d", aValue, oTag);
	int oValue = aValue;
	if (oTag > 20000)
	{
		// poids fort
		oValue = (oValue >> 4) & 0x0F;
	}
	else if (oTag > 10000)
	{
		// poids faible
		oValue = (oValue & 0x0F);
	}
	oValue += offset;
	[super setIntValue:oValue];

	// cas particulier (aurait necessite d'autres classes...
	if (oTag == 20)
	{
		// balance DCO1 DCO2
		NSTextField *oTF = [[self superview] viewWithTag:999];
		[oTF setIntValue:oValue];
	}
}

@end
