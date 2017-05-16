//
//  AlertManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/24/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertDelegate <NSObject>

-(void)pressYES;
-(void)pressNO;

@end

@interface AlertManager : NSObject
@property (weak,nonatomic) id<AlertDelegate> delegateAlert;

-(void)showAlertWithController:(UIViewController *)controler andTitle:(NSString *)title withDesc:(NSString*)desc;
-(void)showYesNoAlertWithController:(UIViewController *)controler andTitle:(NSString *)title withDesc:(NSString*)desc;
@end
