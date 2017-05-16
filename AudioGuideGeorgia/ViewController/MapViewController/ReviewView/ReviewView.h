//
//  ReviewView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/9/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReviewDelegate <NSObject>

-(void)setTourRaitin:(NSInteger)raiting;

@end


@interface ReviewView : UIView
@property (weak,nonatomic) id<ReviewDelegate> delegateRaiting;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *raitButton;
@property NSInteger raiting;
@property int tourID;
@property UIViewController *controller;
@end
