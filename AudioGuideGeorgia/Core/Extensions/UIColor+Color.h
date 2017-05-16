//
//  UIColor+Color.h
//  TKT.GE
//
//  Created by Tornike Davitashvili on 10/18/16.
//  Copyright © 2016 Lemondo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Color)
/** UIColor category function for return true color from RGB
    @param red red RGB code
    @param green red RGB code
    @param blue red RGB code
    @return UIColor
 */
+(UIColor *)colorWithRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue alpha:(CGFloat)alpha;
/** UIColor category function for return true color from RGB
    @param red red RGB code
    @param green red RGB code
    @param blue red RGB code
    @return CGColorRef
 */
+(CGColorRef)cgColorWithRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue alpha:(CGFloat)alpha;
@end
