#import "ParamCheckbox.h"
#import "MIDIDriver.h"
#import "MyDocument.h"

@implementation ParamCheckbox

- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription
{
	//NSString *tagStr = [NSString stringWithFormat:@"%d", [self tag]];
	//NSLog(@"ParamPopUpButton awake tag = %@", tagStr);
	mask = [aDescription getMask:aObject];

	[self setTarget:self];
	[self setAction:@selector(checkAction:)];
}

- (void)checkAction:(id)sender
{
  //  NSLog(@"checkAction");
    int oTag = [sender tag];
	int oParamNum = oTag;
	int oValue = [sender intValue];
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (oTag > 30000)
	{
	//	NSLog(@"Tag= %d | intValue= %d | mask= %d", oTag, oValue, mask);
        // recuperer l numero de parametre a partir de 30xxx, 31xxx, 32xxx
		oParamNum = (int)(oTag - 30000);
		while (oParamNum > 1000)
		{
			oParamNum -= 1000;
		}
        if (oValue == 0)                                     // Code simplification (Sander)
        {
            oValue = ([myDoc getParameter:oParamNum] & ~mask);
        }
        else if (oValue == 1)
        {
            oValue = ([myDoc getParameter:oParamNum] | mask);
        }

	}

	// mettre a jour le document
	[myDoc setParameter:oValue  At:oParamNum];
}

- (void)setIntValueFromDoc:(int)aValue
{
	int oValue = aValue;
	int oTag = [self tag];
	if (oTag > 30000)
	{
//		  NSLog(@"Tag = %d | memValue = %d", oTag, aValue);
        oValue = (aValue & mask);                           // Code simplification (Sander)
//        NSLog(@"oValue = %d", oValue);
	}
	[super setIntValue:oValue];
}

@end
