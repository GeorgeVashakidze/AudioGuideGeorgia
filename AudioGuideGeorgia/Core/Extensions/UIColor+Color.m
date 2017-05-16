//
//  UIColor+Color.m
//  TKT.GE
//
//  Created by Tornike Davitashvili on 10/18/16.
//  Copyright © 2016 Lemondo. All rights reserved.
//

#import "UIColor+Color.h"

@implementation UIColor (Color)
+(UIColor *)colorWithRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}
+(CGColorRef)cgColorWithRed:(CGFloat)red withGreen:(CGFloat)green withBlue:(CGFloat)blue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha].CGColor;
}
@end
