//
//  TourDownloadAlert.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/23/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "TourDownloadAlert.h"
#import "InAppPurchaseManager.h"
#import "LocalizableLabel.h"


@interface TourDownloadAlert()<PurchaseDelagate>{
    InAppPurchaseManager *purchaseManager;
    __weak IBOutlet MMMaterialDesignSpinner *loaderSpinner;
    __weak IBOutlet UILabel *subscribLbl;
    __weak IBOutlet UILabel *totalMemoryLbl;
    __weak IBOutlet UILabel *buyLbl;
    __weak IBOutlet UIView *loaderViewBox;
    __weak IBOutlet UIView *downloadAlertView;
    __weak IBOutlet UILabel *memoryLbl;
    __weak IBOutlet UIButton *downloadNobtn;
    __weak IBOutlet UIImageView *downloadImage;
    __weak IBOutlet UIButton *downloadBtn;
}
@property (weak, nonatomic) IBOutlet LocalizableLabel *tryDemoLbl;
@property NSString *buyTourLbl;
@property NSString *subcribeLbl;
@end

@implementation TourDownloadAlert
-(void)setPurchase{
    purchaseManager = [[InAppPurchaseManager alloc] init];
    purchaseManager.delegate = self;
    [purchaseManager setProductIDStr:self.productID];
    [purchaseManager getInAppDetails];
}
-(void)setLocalizable{
    [self.tryDemoLbl changeLocalizable:@"trydemolbl"];
    self.buyTourLbl = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"buytourlbl"];
    self.subcribeLbl = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"subcribelbl"];
    subscribLbl.text = self.subcribeLbl;
    buyLbl.text = self.buyTourLbl;
}
-(void)cornerRaidus{
    [self setPurchase];
    [self setLocalizable];
    self.tryView.layer.masksToBounds = YES;
    self.tryView.layer.cornerRadius = 8;
    self.buyView.layer.masksToBounds = YES;
    self.buyView.layer.cornerRadius = 8;
    self.subscribView.layer.masksToBounds = YES;
    self.subscribView.layer.cornerRadius = 8;
    self.downloadingView.layer.masksToBounds = YES;
    self.downloadingView.layer.cornerRadius = 8;
    self.purchaseImg.layer.masksToBounds = YES;
    self.purchaseImg.layer.cornerRadius = 8;
    self.purchashingTitle.text = self.titlePurchase;
    self.purchaseYesBtn.layer.masksToBounds = YES;
    self.purchaseYesBtn.layer.cornerRadius = 8;
    self.purchaseNoBtn.layer.masksToBounds = YES;
    self.purchaseNoBtn.layer.cornerRadius = 8;
    loaderViewBox.layer.masksToBounds = YES;
    loaderViewBox.layer.cornerRadius = 8;
    downloadBtn.layer.masksToBounds = YES;
    downloadBtn.layer.cornerRadius = 8;

    downloadNobtn.layer.masksToBounds = YES;
    downloadNobtn.layer.cornerRadius = 8;

    
    downloadImage.layer.masksToBounds = YES;
    downloadImage.layer.cornerRadius = 8;
    
    [self initProgpressLabel];
    [self setTotalMemory];
}
-(void)setTotalMemory{
    totalMemoryLbl.text = [NSString stringWithFormat:@"%.2f MB",(float)self.tourTotalMemory/(float)megabytes];
    memoryLbl.text = [NSString stringWithFormat:@"%.2f MB",(float)self.tourTotalMemory/(float)megabytes];
}
-(void)initProgpressLabel{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"DINPro-Medium" size:19];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor grayColor];
    textLabel.backgroundColor = [UIColor clearColor];
    self.downloadProgresView.lineWidth = 4;
    self.downloadProgresView.tintColor = [UIColor colorWithRed:42.0/255.0 green:253.0/255.0 blue:142.0/255.0 alpha:1];
    self.downloadProgresView.centralView = textLabel;
}
-(void)showButtonsWithAnimation:(int)alpha withHanlde:(void (^)())handler{
    __block typeof(self) blockSelf = self;
    [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blockSelf.tryView.alpha = alpha;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            blockSelf.buyView.alpha = alpha;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                blockSelf.subscribView.alpha = alpha;
            } completion:^(BOOL finished) {
                handler();
            }];
        }];
    }];
}
-(void)showAnimationDownloadProgress{
    self.downloadingView.hidden = NO;
    self.downloadingView.alpha = 0;
    self.userInteractionEnabled = NO;
    [self.downloadProgresView setProgress:0.0];
    __block typeof(self) blockSelf = self;

    [UIView animateWithDuration:0.15 animations:^{
        blockSelf.backgroundImage.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:18.0/255.0 blue:95.0/255.0 alpha:1];
        blockSelf.downloadingView.alpha = 1;
    } completion:^(BOOL finished) {
        [blockSelf.downloadAlertDelegate buyTour:_base64Recep];
    }];
}
-(void)showAnaimationPurchasingView:(int)alpha withHanlde:(void (^)())handler{
    self.purchasingView.hidden = NO;
    self.purchasingView.alpha = 0;
    __block typeof(self) blockSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        blockSelf.backgroundImage.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:18.0/255.0 blue:95.0/255.0 alpha:1];
        blockSelf.purchasingView.alpha = alpha;
    } completion:^(BOOL finished) {
        handler();
    }];
}
-(void)showAnaimationDownloadingView:(int)alpha withHanlde:(void (^)())handler{
    downloadAlertView.hidden = NO;
   downloadAlertView.alpha = 0;
    __block typeof(self) blockSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        blockSelf.backgroundImage.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:18.0/255.0 blue:95.0/255.0 alpha:1];
        blockSelf->downloadAlertView.alpha = alpha;
    } completion:^(BOOL finished) {
        handler();
    }];
}
-(void)showAnimationDownloadView{
    __block typeof(self) blockSelf = self;
    [self showButtonsWithAnimation:0 withHanlde:^{
        [blockSelf showAnaimationPurchasingView:1 withHanlde:^{
        }];
    }];
}
- (IBAction)startTour:(UIButton *)sender {
    [self.downloadAlertDelegate startTour];
}
- (IBAction)startDownloadTour:(UIButton *)sender {
    [self showAnaimationDownloadingView:0 withHanlde:^{
        [self showAnimationDownloadProgress];
    }];
}
- (IBAction)purchaseYes:(UIButton *)sender {
    self.userInteractionEnabled = NO;
    if (_isActivatePromoCode) {
        __block typeof(self) blockSelf = self;
        [self showAnaimationPurchasingView:0 withHanlde:^{
            [blockSelf showAnimationDownloadProgress];
        }];
    }else{
        loaderViewBox.hidden = NO;
        [loaderSpinner startAnimating];
        purchaseManager.buyTour = YES;
        [purchaseManager restorePurchase];
    }
}
- (IBAction)purchaseNo:(UIButton *)sender {
    [self removeFromSuperview];
}
- (IBAction)tryDemo:(UIButton *)sender {
    [self.downloadAlertDelegate tryDemoTour];
}
- (IBAction)buyTour:(UIButton *)sender {
    [self showAnimationDownloadView];
}
- (IBAction)subscribe:(UIButton *)sender {
    loaderViewBox.hidden = NO;
    [loaderSpinner startAnimating];
    purchaseManager.buyTour = NO;
    [purchaseManager restorePurchase];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self removeFromSuperview];
}
-(void)hideLoaderSpiner{
    loaderViewBox.hidden = YES;
    [loaderSpinner stopAnimating];
}
#pragma mark - PurchaseDelagate
-(void)completedBuy:(NSString *)base64Recept{
    [self hideLoaderSpiner];
    self.userInteractionEnabled = YES;
    _base64Recep = base64Recept;
    [self.downloadAlertDelegate downloadCompleted:base64Recept];
    if (purchaseManager.buyTour) {
        [self showAnaimationPurchasingView:0 withHanlde:^{
            [self showAnaimationDownloadingView:1 withHanlde:^{
            }];
        }];
    }else{
        [self showButtonsWithAnimation:0 withHanlde:^{
            [self showAnaimationDownloadingView:1 withHanlde:^{
            }];
        }];
    }

}
-(void)faildBuy:(NSString *)error{
    self.userInteractionEnabled = YES;
    [self hideLoaderSpiner];
    [_downloadAlertDelegate faildBuy:error];
}
-(void)updatePrice:(NSDecimalNumber *)price{
    buyLbl.text = [NSString stringWithFormat:@"%@ %@$",self.buyTourLbl,price];
    [self.downloadAlertDelegate updatePrice:price];
}
- (void)updateSubscriberPrice:(NSDecimalNumber *)price{
    subscribLbl.text = [NSString stringWithFormat:@"%@ %@$",self.subcribeLbl,price];
}
@end
