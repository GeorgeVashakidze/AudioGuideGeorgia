//
//  PromotionVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PromotionVC.h"
#import "SlideNavigationController.h"
#import "SharedPreferenceManager.h"
#import "AlertManager.h"
#import "RegistrationController.h"
#import "LocalizableLabel.h"
#import "ServiceManager.h"
#import "MMMaterialDesignSpinner.h"

@interface PromotionVC ()<AlertDelegate,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *promoCodeTxtField;
@property (weak, nonatomic) IBOutlet UIButton *activeProBtn;
@property (weak, nonatomic) IBOutlet LocalizableLabel *titleLbl;
@property AlertManager *alertManager;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderSpiner;
@property (weak, nonatomic) IBOutlet UILabel *activatePromoLbl;
@property ServiceManager *manager;
@property NSString *touserpromocode;
@property NSString *alreadyactivepromo;
@property NSString *firstenterpormocode;
@property NSString *successactivepromo;
@end

@implementation PromotionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.alertManager = [[AlertManager alloc] init];
    self.alertManager.delegateAlert = self;
    _manager = [[ServiceManager alloc] init];
    _manager.delegate = self;
    // Do any additional setup after loading the view.
    [self drawControllersOnView];
    [self setLocalizable];
    [self loadForPromo];
}
-(void)loadForPromo{
    NSDictionary *dicUser = [SharedPreferenceManager getUserInfo];
    if ([dicUser[@"promotion"] intValue] == 1) {
        self.activeProBtn.hidden = YES;
        self.promoCodeTxtField.hidden = YES;
        self.activatePromoLbl.hidden = NO;
    }
}
-(void) setLocalizable{
    NSString *btnTitle = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"promoactivebtn"];
    NSString *placeHolder = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"insertpromocode"];
    [self.titleLbl changeLocalizable:@"promoviewtitle"];
    [self.activeProBtn setTitle:btnTitle forState:UIControlStateNormal];
    self.promoCodeTxtField.placeholder = placeHolder;
    self.touserpromocode = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"touserpromocode"];
    self.alreadyactivepromo = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"alreadyactivepromo"];
    self.firstenterpormocode = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"firstenterpormocode"];
    self.successactivepromo = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"successactivepromo"];
}
-(void)drawControllersOnView{
    self.promoCodeTxtField.layer.masksToBounds = YES;
    self.promoCodeTxtField.layer.cornerRadius = 2;
    self.promoCodeTxtField.layer.borderWidth = 1.0f;
    self.promoCodeTxtField.layer.borderColor = [UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1].CGColor;
    self.activeProBtn.layer.masksToBounds = YES;
    self.activeProBtn.layer.cornerRadius = 4;
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self goBack];
}

- (IBAction)activatePromo:(UIButton *)sender {
    NSDictionary *dic = [SharedPreferenceManager getUserInfo];
    if (dic == nil) {
        [self.alertManager showYesNoAlertWithController:self andTitle:@"Warning" withDesc:self.touserpromocode];
    }else{
        NSDictionary *dicUser = [SharedPreferenceManager getUserInfo];
        if ([dicUser[@"promotion"] intValue] == 1) {
            [self showAlertView:self.alreadyactivepromo];
        }else{
            if ([self.promoCodeTxtField.text isEqualToString:@""]) {
                 [self.alertManager showYesNoAlertWithController:self andTitle:@"Warning" withDesc:self.firstenterpormocode];
            }else{
                _loaderSpiner.hidden = NO;
                [_loaderSpiner startAnimating];
                NSString *token = [SharedPreferenceManager getUserToken];
                [_manager activatePromoCode:self.promoCodeTxtField.text withToken:token];
            }
        }
    }
}
-(void)showAlertView:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        [self goBack];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - AlertDelegate

-(void)pressNO{
    
}
-(void)pressYES{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    RegistrationController *reg = (RegistrationController *)[mainStoryboard
                                                            instantiateViewControllerWithIdentifier:@"RegistrationController"];
    reg.fromPromo = YES;
    [self presentViewController:reg animated:YES completion:nil];
}
-(void)stopAnimationLoader{
    _loaderSpiner.hidden = YES;
    [_loaderSpiner stopAnimating];
}
#pragma mark - ServicesManagerDelegate
-(void)activatePromoCode:(NSDictionary *)response{
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithDictionary:[SharedPreferenceManager getUserInfo]];
    [userDic setObject:[NSNumber numberWithInt:1] forKey:@"promotion"];
    [SharedPreferenceManager saveUserInfo:userDic];
    [self stopAnimationLoader];
    [self showAlertView:self.successactivepromo];
}
-(void)errorActivatePromoCode:(NSError *)error{
    [self stopAnimationLoader];
}
@end
