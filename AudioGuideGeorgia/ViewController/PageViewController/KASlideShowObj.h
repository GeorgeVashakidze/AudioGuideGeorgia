//
//  KASlideShowObj.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"

@interface KASlideShowObj : NSObject<KASlideShowDelegate,KASlideShowDataSource>
@property NSArray *datasource;
@property (strong,nonatomic) KASlideShow *slideShow;
@property (strong,nonatomic) UIPageControl *pageConroller;
@property CGRect slideShowFrame;
-(void)addPageController;
@end
