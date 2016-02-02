#import "ParamSlider.h"
#import "Description.h"
#import "MIDIDriver.h"
#import "MyDocument.h"

@implementation ParamSlider

- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription
{
	offset = [aDescription getOffset:aObject];
    AddValueDisplay = [aDescription getAddValueDisplay:aObject];                            // Added for value display (Sander)
	
	[self setTarget:self];
	[self setAction:@selector(moveAction:)];
}

- (void)moveAction:(id)sender
{
	int oTag = [sender tag];
	int oParamNum = oTag;
	int oValue = [sender intValue] - offset;
    int oAddValueDisplay = AddValueDisplay;                                                 // added Sander.
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
//	NSLog(@"moveAction %d tag=%d", oValue, oTag);
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
    
    if(oAddValueDisplay)                        // Is AddValueDisplay=1, for this parameter (sounddesc.plist)? If TRUE, send value to tag + 1000.(Sander)
    {
        NSTextField *oTF = [[self superview] viewWithTag:(oTag + 1000)];
        [oTF setIntValue:oValue];
    }
}

- (void)setIntValueFromDoc:(int)aValue
{
	int oTag = [self tag];
//	NSLog(@"setIntValueFromDoc %d tag=%d", aValue, oTag);
	int oValue = aValue;
    int oAddValueDisplay = AddValueDisplay;
    
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
    
    if(oAddValueDisplay)                        // Is AddValueDisplay=1, for this parameter (sounddesc.plist)? If TRUE, send value to tag + 1000.(Sander)
    {
        NSTextField *oTF = [[self superview] viewWithTag:(oTag + 1000)];
        [oTF setIntValue:oValue];
    }

}

@end
