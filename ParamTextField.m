#import "ParamTextField.h"

#import "MIDIDriver.h"
#import "Description.h"
#import "MyDocument.h"

/*
	Classe servant a gerer des parametres dont la valeur
	se modifie en cliquant et en deplacant la souris verticalement.
*/
@implementation ParamTextField

/*
- (id)init
{
    self = [super init];
    if (self) 
	{	
    }
    return self;
}
*/

/* provoque un deadlock
+ (Class) cellClass
{
    return [ParamTextField class];
}
*/



- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription
{
	offset = [aDescription getOffset:aObject];
	min = [aDescription getMin:aObject];
	max = [aDescription getMax:aObject];
	displayMin = [aDescription getDisplayMin:aObject] + offset;
	displayMax = [aDescription getDisplayMax:aObject] + offset;
	mask = [aDescription getMask:aObject];
	offsetFrom = [aDescription offsetFrom:aObject];
}

- (int)max
{
	return max;
}

- (int)min
{
	return min;
}

/*
- (int)currentValue
{
	return currentValue;
}
*/

- (void)mouseDown:(NSEvent *)theEvent
{
	origine = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint loc = [theEvent locationInWindow];
	float diff = loc.y - origine.y;
	int oNewValue = [self intValue] + (int)diff;
	if (oNewValue > displayMax)
	{
		oNewValue  = displayMax;
	}
	if (oNewValue < displayMin)
	{
		oNewValue = displayMin;
	}
	[self updateValue:oNewValue];
	origine = [theEvent locationInWindow];
}

// retourne la valeur envoyee au synth a partir de la valeur affichee
- (int)getRealValue:(int)aValue
{
	return (int)round(((max - min)*(aValue - displayMin))/(displayMax - displayMin)) + min;
}

- (int)getDisplayValue:(int)aValue
{
	// gestion des parametres signés
	if (offsetFrom > 0)
	{
		if (aValue >= offsetFrom)
		{
			return aValue + offset;
		}
		return aValue;
	}
	return (int)ceil(((displayMax - displayMin)*((double)aValue - min))/(max - min)) + displayMin;
}

- (void)updateValue:(int)value
{
	// positionner la valeur affichee 
	[super setIntValue:value];
	
	int oTag = [self tag];
	int oParamNum = oTag;
	int oValue = [self getRealValue:value];
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
	if (oTag >= 40000)
	{
		// c'est juste un decalage, on soustrait 40000
		// ca sert pour un parametre qui vaut 0 par exemple
		oParamNum = oTag - 40000;
	}
	else if (oTag > 30000)
	{
		// recuperer l numero de parametre a partir de 30xxx, 31xxx, 32xxx
		oParamNum = (int)(oTag - 30000);
		while (oParamNum > 1000)
		{
			oParamNum -= 1000;
		}
		int oRest = mask % 2;
		int oFact = log2(mask) * (1 - oRest);
		oValue = ([myDoc getParameter:oParamNum] & ~mask ) | (oValue << oFact);
	}
	else if (oTag > 20000)
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
	//NSLog(@"selectedTag = %d", oTag);
	// mettre a jour le document
	[myDoc setParameter:oValue At:oParamNum];
	
}

- (void)setIntValueFromDoc:(int)aValue
{
	int oTag = [self tag];
	//NSLog(@"setIntValueFromDoc %d tag=%d", aValue, oTag);
	int oValue = aValue;
	if (oTag >= 40000)
	{}
	else if (oTag > 30000)
	{}
	else if (oTag > 20000)
	{
		// poids fort
		oValue = (oValue >> 4) & 0x0F;
	}
	else if (oTag > 10000)
	{
		// poids faible
		oValue = (oValue & 0x0F);
	}
	oValue = [self getDisplayValue:oValue];
	[super setIntValue:oValue];
}


@end
