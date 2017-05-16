//
//  PreferencesVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PreferencesVC.h"
#import "SlideNavigationController.h"
#import "SharedPreferenceManager.h"
#import "LocalizableLabel.h"
#import "InAppPurchaseManager.h"
#import "SharedPreferenceManager.h"
#import "MMMaterialDesignSpinner.h"
#import "PreferenceManager.h"
#import "ServiceManager.h"
#import "DownloadMapView.h"

@interface PreferencesVC ()<PurchaseDelagate,DownloadMapViewtDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restorePurchaseHeight;
@property (weak, nonatomic) IBOutlet LocalizableLabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UISwitch *autoPlaySwitch;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderSpiner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfDownloadView;
@property InAppPurchaseManager *inappmanager;
@property ServiceManager *managerService;
@property (weak, nonatomic) DownloadMapView *downloadView;
@end

@implementation PreferencesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _managerService = [[ServiceManager alloc] init];
    [self setDefaultPreferences];
    [self.controllerTitle changeLocalizable:@"preferencesmenu"];
    _inappmanager = [[InAppPurchaseManager alloc] init];
    _inappmanager.delegate = self;
    _inappmanager.restorePurchaseMode = YES;
    _inappmanager.buyTour = YES;
    NSNumber *restore = [SharedPreferenceManager getSaveRestore];
    NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
    if (restore || [userDic[@"promotion"] intValue] == 1) {
        self.restorePurchaseHeight.constant = 0;
    }
    [self detectPushNotification];
    [self detectDownloadPack];
}
-(void)detectDownloadPack{
    NSNumber *downlaodPack = [SharedPreferenceManager getDownloadPack];
    if (downlaodPack) {
        self.heightOfDownloadView.constant = 0;
    }
}
-(void)loadDownloadView{
    self.downloadView = [[[NSBundle mainBundle] loadNibNamed:@"DownloadMapView" owner:self options:nil] objectAtIndex:0];
    self.downloadView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.downloadView.downloadDelegate = self;
    [self.downloadView cornerRaidus];
    self.downloadView.controler = self;
    [self.view addSubview:self.downloadView];
}
-(void)animationHideRestore{
    self.restorePurchaseHeight.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)detectPushNotification{
    PreferenceManager *manager = [PreferenceManager sharedManager];
    
    BOOL pushIsEnable = manager.pushNotification;
    if (pushIsEnable)
    {
        _pushNotificationSwitcher.on = YES;
    }else{
        _pushNotificationSwitcher.on = NO;
    }
}
-(void)setDefaultPreferences{
    NSDictionary *dic = [SharedPreferenceManager getPreferences];
    if (dic) {
        BOOL autoPlay = [dic[@"autoplayer"] boolValue];
        self.autoPlaySwitch.on = autoPlay;
    }
}
- (IBAction)downloadMap:(UIButton *)sender {
    [self loadDownloadView];
}
- (IBAction)clearAllAudio:(UIButton *)sender {
    self.loaderSpiner.hidden = NO;
    self.view.userInteractionEnabled = NO;
    [self.loaderSpiner startAnimating];
    [_managerService updateAllLiveTourToDelete];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.view.userInteractionEnabled = YES;
        [self.loaderSpiner stopAnimating];
        self.loaderSpiner.hidden = YES;
        [self showAlert:@"All audio succesfully deleted" withTitle:@"Warning"];
    });
}
-(void)showAlert:(NSString*)message withTitle:(NSString*)title{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - IBAction

- (IBAction)onOffPushNotification:(UISwitch *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
- (IBAction)onOffAutoPlay:(UISwitch *)sender {
    NSDictionary *dic = @{@"autoplayer":[NSNumber numberWithBool:sender.on]};
    [SharedPreferenceManager savePreferences:dic];
}
- (IBAction)restorePurchase:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    self.loaderSpiner.hidden = NO;
    [self.loaderSpiner startAnimating];
    [_inappmanager restorePurchase];
}

#pragma mark - PurchaseDelagate

- (void)completedBuy:(NSString*)base64Recept{
    [self animationHideRestore];
    self.loaderSpiner.hidden = YES;
    self.view.userInteractionEnabled = YES;
    [self.loaderSpiner stopAnimating];
    [SharedPreferenceManager saveRestore:[NSNumber numberWithInt:12]];
    [self showAlert:@"Welcome back, your purchase has been restored free of charge. Now you can enjoy Audio Guide Georga." withTitle:@""];
}
- (void)faildBuy:(NSString*)error{
    self.view.userInteractionEnabled = YES;
    self.loaderSpiner.hidden = YES;
    [self.loaderSpiner stopAnimating];
    [self showAlert:@"We remember all the purchase, but unfortunately yours doesn't exist." withTitle:@"No purchase has been found"];
}
- (void)updatePrice:(NSDecimalNumber*)price{
    
}
- (void)updateSubscriberPrice:(NSDecimalNumber*)price{
    
}

#pragma mark - DownloadMapViewtDelegate

-(void)downloadCompleted{
    self.heightOfDownloadView.constant = 0;
}

@end
