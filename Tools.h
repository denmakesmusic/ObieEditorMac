//
//  Tools.h
//  ObieEditor2
//
//  Created by groumpf on 07/02/2016.
//
//

#import <Cocoa/Cocoa.h>


@interface Tools : NSObject
{
}


/**
	Show a simple alert.
	@param aWindow if not nil, alert is displayed as a sheet.
 */
+(void)showAlertWithMessage:(NSString*)aMessage andWindow:(NSWindow*)aWindow;



@end
