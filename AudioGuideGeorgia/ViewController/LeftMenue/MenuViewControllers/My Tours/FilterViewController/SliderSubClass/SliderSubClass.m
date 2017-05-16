//
//  SliderSubClass.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/9/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "SliderSubClass.h"

@implementation SliderSubClass


//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

-(CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect tempRect = bounds;
    if (self.tag == 11) {
        tempRect.origin.y += 32;
        tempRect.size.height = 8;
    }else{
        tempRect.size.height = 20;
    }
    return tempRect;
}
@end
