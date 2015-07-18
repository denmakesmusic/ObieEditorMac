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
	int oTag = [sender tag];
	int oParamNum = oTag;
	int oValue = [sender intValue];
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (oTag > 30000)
	{
		// recuperer l numero de parametre a partir de 30xxx, 31xxx, 32xxx
		oParamNum = (int)(oTag - 30000);
		while (oParamNum > 1000)
		{
			oParamNum -= 1000;
		}
		int oRest = mask % 2;
		// pour un masque de 1 bit ce calcul fonctionne
		int oFact = log2(mask) * (1 - oRest);
		oValue = ([myDoc getParameter:oParamNum] & ~mask ) | (oValue << oFact);
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
		int oRest = mask % 2;
		int oFact = log2(mask) * (1 - oRest);
		oValue = (aValue & mask) >> oFact;
	}
	[super setIntValue:oValue];
}

@end
