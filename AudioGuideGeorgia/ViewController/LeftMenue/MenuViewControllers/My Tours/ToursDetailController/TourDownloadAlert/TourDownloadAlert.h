//
//  TourDownloadAlert.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/23/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
#import "MMMaterialDesignSpinner.h"


#define megabytes 1048576

@protocol DownloadAlertDelegate <NSObject>

-(void)tryDemoTour;
-(void)startTour;
-(void)buyTour:(NSString*)base64Recept;
-(void)suscribeApp;
-(void)faildBuy:(NSString*)error;
-(void)updatePrice:(NSDecimalNumber *)price;
-(void)downloadCompleted:(NSString *)base64Recept;
@end

@interface TourDownloadAlert : UIView
@property NSString *base64Recep;
@property (weak, nonatomic) IBOutlet UIImageView *purchaseImg;
@property (weak, nonatomic) IBOutlet UIView *tryView;
@property (weak, nonatomic) IBOutlet UIView *buyView;
@property (weak, nonatomic) IBOutlet UIView *downloadingView;
@property (weak, nonatomic) IBOutlet UIView *purchasingView;
@property (weak, nonatomic) IBOutlet UILabel *purchashingTitle;
@property (weak,nonatomic) id<DownloadAlertDelegate> downloadAlertDelegate;
@property (weak, nonatomic) IBOutlet UIView *subscribView;
@property (weak, nonatomic) IBOutlet UIButton *purchaseYesBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *purchaseNoBtn;
@property (weak, nonatomic) IBOutlet UAProgressView *downloadProgresView;
@property (weak, nonatomic) NSString *titlePurchase;
@property (strong, nonatomic) NSString *productID;
@property BOOL isActivatePromoCode;
@property long long int tourTotalMemory;
-(void)showButtonsWithAnimation:(int)alpha withHanlde:(void (^)())handler;
-(void)showAnaimationDownloadingView:(int)alpha withHanlde:(void (^)())handler;
-(void)showAnimationDownloadView;
-(void)cornerRaidus;
-(void)showAnimationDownloadProgress;
@end
