#import "ParamPopUpButton.h"
#import "Description.h"
#import "MIDIDriver.h"
#import "MyDocument.h"

@implementation ParamPopUpButton


// charge les element du menu a partir des valeurs du dico
// selectionne l'element courant 
- (void)setUI:(NSDictionary*)aObject description:(Description*)aDescription
{
	NSString *tagStr = [NSString stringWithFormat:@"%ld", (long)[self tag]];
	//NSLog(@"ParamPopUpButton awake tag = %@", tagStr);
	NSArray *oArray = [aDescription getValueNames:aObject];
	if (oArray == nil)
	{
		NSLog(@"ERROR: no valueNames defined for tag %@", tagStr);
		return;
	}
	mask = [aDescription getMask:aObject];
	//NSLog(@"array = %@", oArray);
	// le retain semble indispensable
	values = [[aDescription getValues:aObject] retain];
	//NSLog(@"values = %@", values);
	
	[self removeAllItems];
	[self addItemsWithTitles:oArray];
	[self selectItemAtIndex:0];
	// j'enregistre le target car il est positionné dans IB 
	// pour certains menus qui doivent controler un autre objet
	previousTarget = [self target];
	[self setTarget:self];
	[self setAction:@selector(popupAction:)];
}

- (void)popupAction:(id)sender
{	
	if (previousTarget != nil && [previousTarget isKindOfClass:[NSTabView class]])
	{
		// si le target est un NSTabView
		[previousTarget takeSelectedTabViewItemFromSender:self];
	}
	int oTag = [sender tag];
	int oParamNum = oTag;
	int oValue = [sender indexOfSelectedItem];	
	if ([sender values] != NULL)
	{
		NSNumber *num = [[sender values] objectAtIndex:oValue];
		oValue = [num intValue];
	}
	MyDocument *myDoc = [[NSDocumentController sharedDocumentController] currentDocument];
    
//    NSLog(@"Tag= %d | ParamNR= %d | outValue= %d | mask= %d", oTag, oParamNum, oValue, mask);
    
	if (oTag > 30000)
	{
		// recuperer l numero de parametre a partir de 30xxx, 31xxx, 32xxx
		oParamNum = (int)(oTag - 30000);
		while (oParamNum > 1000)
		{
			oParamNum -= 1000;
		}
		// pas de decalage par defaut
		int oFact = 0; 
		if (mask == 112)
		{
			oFact = 4; // pour un masque = 112, je ne vois pas comment calculer ca
		}
		int oOldValue = [myDoc getParameter:oParamNum];
		oValue = (oOldValue & ~mask ) | (oValue << oFact);
	}
	else
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
//	NSLog(@"Tag= %d | ParamNR= %d | outValue= %d | mask= %d", oTag, oParamNum, oValue, mask);
    // mettre a jour le document
	[myDoc setParameter:oValue At:oParamNum];
	
}

- (void)setIntValueFromDoc:(int)aValue
{
	int oTag = [self tag];
//	NSLog(@"setIntValueFromDoc %d tag=%d", aValue, oTag);
	int oValue = aValue;
	if (oTag > 30000)
	{
		// pas de decalage par defaut
		int oFact = 0; 
		if (mask == 112)
		{
			oFact = 4; // pour un masque = 112, je ne vois pas comment calculer ca
		}
		oValue = (aValue & mask) >> oFact;
	}
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
	if ([self values] != NULL)
	{
		int i = 0;
		for (i = 0; i < [values count]; i++)
		{
			NSNumber *num = [[self values] objectAtIndex:i];
			if ([num intValue] == oValue)
			{
				[self selectItemAtIndex:i];
				break;
			}
		}
	}
	else
	if (oValue < [self numberOfItems])
	{
		[self selectItemAtIndex:oValue];
	}
	else
	{
		NSLog(@"Unable to set value %d for tag %d", aValue, oTag);
	}
}

/*
- (int)indexOfSelectedItem
{
	NSLog(@"indexOfSelectedItem = %d", [super indexOfSelectedItem]);
	return [super indexOfSelectedItem];
}
*/

- (NSArray*)values
{
	return values;
}

@end
