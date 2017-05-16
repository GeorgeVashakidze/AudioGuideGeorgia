//
//  LoginView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/19/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LoginView.h"
#import "SlideNavigationController.h"
#import "LoginManager.h"
#import "SharedPreferenceManager.h"
#import "ServiceManager.h"
#import "AlertManager.h"
#import "LocalizableLabel.h"
#import "MMMaterialDesignSpinner.h"

@interface LoginView ()<LoginManagerDelegate,ServicesManagerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet LocalizableLabel *orLbl;
@property (weak, nonatomic) IBOutlet UIButton *forgotBtn;
@property (weak, nonatomic) IBOutlet LocalizableLabel *titleLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *loginDescriptionLbl;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginFbBtn;
@property (nonatomic,strong) LoginManager *loginManager;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong,nonnull) ServiceManager *manager;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *laodIndicator;
@property (strong,nonatomic) AlertManager *alert;
@property BOOL isLogedInFromFb;
@property NSURL *facebookImageURL;
@end

@implementation LoginView

- (void)viewDidLoad {
    [super viewDidLoad];
    _facebookImageURL = [NSURL URLWithString:@""];
    // Do any additional setup after loading the view.
    self.alert = [[AlertManager alloc] init];
    [self setCornerRadiuse];
    self.loginManager = [[LoginManager alloc] init];
    self.loginManager.delegateLogin = self;
    [self configureTextField];
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    [self setLocalizable];
}
-(void)setLocalizable{
    [self.titleLbl changeLocalizable:@"logintitle"];
    [self.loginDescriptionLbl changeLocalizable:@"logindescription"];
    [self.orLbl changeLocalizable:@"orlbl"];
    NSString *login = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"logintitle"];
    NSString *forgotPass = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"forgotpass"];
    NSString *facebook = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"facebookBtn"];
    [self.forgotBtn setTitle:forgotPass forState:UIControlStateNormal];
    [self.loginBtn setTitle:login forState:UIControlStateNormal];
    [self.loginFbBtn setTitle:facebook forState:UIControlStateNormal];
}
-(void)buildService:(NSDictionary*)dic{
    [self.manager logiUser:dic];
}
-(void)configureTextField{
    if ([self.emailTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        NSString *mailAddress = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"mailadress"];
        NSString *password = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registerpassword"];
        UIColor *color = [[UIColor lightTextColor] colorWithAlphaComponent:0.3];
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:mailAddress attributes:@{NSForegroundColorAttributeName: color}];
        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:password attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}
-(void)setCornerRadiuse{
    self.loginBtn.layer.masksToBounds = YES;
    self.loginFbBtn.layer.masksToBounds = YES;
    self.loginFbBtn.layer.cornerRadius = 4;
    self.loginBtn.layer.cornerRadius = 4;
}
-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
#pragma mark - IBAction

- (IBAction)backTo:(id)sender {
    [self backTo];
}
- (IBAction)loginWithFb:(UIButton *)sender {
    [self.loginManager loginWithFBWithViewController:self];
}
- (IBAction)loginWithEmail:(UIButton *)sender {
    self.laodIndicator.hidden = NO;
    [self.laodIndicator startAnimating];
    self.loginBtn.enabled = NO;
    NSDictionary *dic = @{
                          @"email":self.emailTextField.text,
                          @"password":self.passwordTextField.text
                          };
    [self buildService:dic];
}
- (IBAction)forgotPass:(UIButton *)sender {
    
}
- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    [self.loginScrollView setContentSize:CGSizeMake(SCREEN_WIDTH,self.loginScrollView.frame.size.height)];
}

#pragma mark - LoginManagerDelegate

-(void)loginWithFacebookWithInfo:(NSDictionary *)userInfo{
    self.isLogedInFromFb = YES;
    [self.manager loginWithFacebook:userInfo];
}
-(void)getUserFacebookImage:(NSURL *)imageURl{
    _facebookImageURL = imageURl;
}
#pragma mark - ServicesManagerDelegate

-(void)errorLoginUser:(NSError *)error{
    self.loginBtn.enabled = YES;
    self.laodIndicator.hidden = YES;
    [self.laodIndicator stopAnimating];
    [self.alert showAlertWithController:self andTitle:@"Error" withDesc:@"User name or password is not correct"];
}

-(void)loginUser:(NSDictionary *)token{
    self.loginBtn.enabled = YES;
    self.laodIndicator.hidden = YES;
    [self.laodIndicator stopAnimating];
    [SharedPreferenceManager setUserToken:token[@"meta"][@"token"]];
    if (self.isLogedInFromFb) {
        [self.manager getUserProfile:token[@"meta"][@"token"]];
    }else{
        [SharedPreferenceManager saveUserInfo:token[@"data"]];
        [self backTo];
    }
    self.isLogedInFromFb = NO;
}
-(void)errorGetUserProfile:(NSError *)error{
    
}
-(void)getUserProfile:(NSDictionary *)user{
    [SharedPreferenceManager saveUserInfo:user];

    [self backTo];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.loginScrollView setContentSize:CGSizeMake(SCREEN_WIDTH,self.loginScrollView.frame.size.height)];
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.loginScrollView setContentSize:CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT+100)];
}

@end
