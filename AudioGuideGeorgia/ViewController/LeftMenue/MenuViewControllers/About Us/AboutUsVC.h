//
//  AboutUsVC.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class PagesModel;
@interface AboutUsVC : UIViewController
@property (weak,nonatomic) NSString *titleStr;
@property BOOL isFromInfo;
@property NSNumber *pageID;
@property PagesModel *model;
@end
