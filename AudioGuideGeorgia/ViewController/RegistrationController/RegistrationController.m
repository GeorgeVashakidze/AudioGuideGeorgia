//
//  RegistrationController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "RegistrationController.h"
#import "SlideNavigationController.h"
#import "UIColor+Color.h"
#import "NSString+EmailValidation.h"
#import "LoginManager.h"
#import "SharedPreferenceManager.h"
#import "ServiceManager.h"
#import "NationalitiesModel.h"
#import "LocalizableLabel.h"
#import "AlertManager.h"
#import "MMMaterialDesignSpinner.h"

@interface RegistrationController () <UITextFieldDelegate,LoginManagerDelegate,ServicesManagerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *natinalityBtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet LocalizableLabel *signUpLbl;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *emailSeparator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *pass1TextField;
@property (weak, nonatomic) IBOutlet UITextField *pass2TextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nationalityTextField;
@property (weak, nonatomic) IBOutlet UIImageView *nameSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *pass1Separator;
@property (weak, nonatomic) IBOutlet UIImageView *pass2Separator;
@property (weak, nonatomic) IBOutlet UIImageView *nationalitySeparator;
@property (nonatomic,strong) LoginManager *loginManager;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderSpinner;
@property (strong,nonatomic) ServiceManager *manager;
@property (weak, nonatomic) IBOutlet UIPickerView *nationalityPicker;
@property BOOL registerFromFb;
@property AlertManager *alertManager;
@property NSArray<NationalitiesModel *> *nationalities;
@property NationalitiesModel *choosenNationality;
@property NSString *fillname;
@property NSString *fillemail;
@property NSString *fillpassword;
@property NSString *emailformatcorrection;
@property NSString *choosenationality;
@property NSString *passwordcharacters;
@property NSString *passnotmatch;
@property NSString *emailIsUsed;
@end

@implementation RegistrationController

- (void)viewDidLoad {
    [super viewDidLoad];
    _alertManager = [[AlertManager alloc] init];
    // Do any additional setup after loading the view.
    self.loginManager = [[LoginManager alloc] init];
    self.loginManager.delegateLogin = self;
    [self configureTextField];
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    LanguageManager *lngManager = [LanguageManager sharedManager];
    NSString *currentLAngage = [lngManager getSelectedLanguage];
    if ([currentLAngage isEqualToString:@"ka"]) {
        _nationalityTextField.text = @"Georgia";
        _nationalityTextField.enabled = NO;
        self.natinalityBtn.enabled = NO;
    }else{
        [self getNationality];
    }
    [self setLocalizable];
}

-(void)setLocalizable{
    NSString *registerNow = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registernow"];
    NSString *facebookBtn = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"facebookBtn"];
    NSString *registertrsm = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registerterms"];
    [self.registerBtn setTitle:registerNow forState:UIControlStateNormal];
    [self.facebookBtn setTitle:facebookBtn forState:UIControlStateNormal];
    [self.acceptBtn setTitle:registertrsm forState:UIControlStateNormal];
    [self.signUpLbl changeLocalizable:@"registerpagetitle"];
    self.fillname = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"fillname"];
    self.fillemail = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"fillemail"];
    self.fillpassword = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"fillpassword"];
    self.emailformatcorrection = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"emailformatcorrection"];
    self.choosenationality = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"choosenationality"];
    self.passwordcharacters = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"passwordcharacters"];
    self.passnotmatch = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"passnotmatch"];
    self.emailIsUsed = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"emailisused"];
}
-(void)getNationality{
    [self.manager getNationalities];
}
-(void)buildService:(NSDictionary*)dic{
    
    [self.manager registerUser:dic];
}
-(void)configureTextField{
    if ([self.emailTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        NSString *name = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registername"];
        NSString *mail = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registermail"];
        NSString *password = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registerpassword"];
        NSString *confpassword = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registerconfirmpassowrd"];
        NSString *nationality = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"registernationality"];
        UIColor *color = [[UIColor lightTextColor] colorWithAlphaComponent:0.3];
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName: color}];
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:mail attributes:@{NSForegroundColorAttributeName: color}];
        self.pass1TextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:password attributes:@{NSForegroundColorAttributeName: color}];
        self.pass2TextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:confpassword attributes:@{NSForegroundColorAttributeName: color}];
        self.nationalityTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:nationality attributes:@{NSForegroundColorAttributeName: color}];

    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}
-(void)setContetSizeToZero{
    self.nationalityPicker.hidden = YES;
    [self.view endEditing:YES];
    [self.scrollView setContentSize:self.scrollView.frame.size];
}
-(BOOL)checkIsNotEmpty{
    if (![self.nameTextField.text isEqualToString:@""]) {
        self.nameSeparator.backgroundColor = [UIColor whiteColor];
    }
    if (![self.emailTextField.text isEqualToString:@""]) {
        self.emailSeparator.backgroundColor = [UIColor whiteColor];
    }
    if (![self.pass1TextField.text isEqualToString:@""]) {
        self.pass1Separator.backgroundColor = [UIColor whiteColor];
    }
    if (![self.pass2TextField.text isEqualToString:@""]) {
        self.pass2Separator.backgroundColor = [UIColor whiteColor];
    }
    if(![self.nationalityTextField.text isEqualToString:@""]){
        self.nationalitySeparator.backgroundColor = [UIColor whiteColor];
    }
    if ([self.pass1TextField.text isEqualToString:self.pass2TextField.text]) {
        self.pass1Separator.backgroundColor = [UIColor whiteColor];
        self.pass2Separator.backgroundColor = [UIColor whiteColor];
    }else{
        if (self.pass2TextField.text.length > 6 ) {
            self.pass2Separator.backgroundColor = [UIColor whiteColor];
        }
        if (self.pass1TextField.text.length > 6) {
            self.pass1Separator.backgroundColor = [UIColor whiteColor];
        }
    }
    return YES;
}
-(BOOL)checkAllFields{
    if ([self.nameTextField.text isEqualToString:@""]) {
        self.nameSeparator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillname];
        return NO;
    }else{
        self.nameSeparator.backgroundColor = [UIColor whiteColor];
    }
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.emailSeparator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillemail];
        return NO;
    }else if([self.emailTextField.text isValidEmail]){
            self.emailSeparator.backgroundColor = [UIColor whiteColor];
        }else{
            self.emailSeparator.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailformatcorrection];
            return NO;
    }
    if ([self.pass1TextField.text isEqualToString:@""]) {
        self.pass1Separator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillpassword];
        return NO;
    }else{
        self.pass1Separator.backgroundColor = [UIColor whiteColor];
    }
    if ([self.pass2TextField.text isEqualToString:@""]) {
        self.pass2Separator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillpassword];
        return NO;
    }else{
        self.pass2Separator.backgroundColor = [UIColor whiteColor];
    }
    if([self.nationalityTextField.text isEqualToString:@""]){
        self.nationalitySeparator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.choosenationality];
        return NO;
    }else{
        self.nationalitySeparator.backgroundColor = [UIColor whiteColor];
    }
    if (![self.pass1TextField.text isEqualToString:self.pass2TextField.text]) {
        if (self.pass2TextField.text.length < 6) {
            self.pass2Separator.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        if (self.pass1TextField.text.length < 6) {
            self.pass1Separator.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        self.pass1Separator.backgroundColor = [UIColor redColor];
        self.pass2Separator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passnotmatch];
        return NO;
    }else{
        self.pass1Separator.backgroundColor = [UIColor whiteColor];
        self.pass2Separator.backgroundColor = [UIColor whiteColor];
        if (self.pass2TextField.text.length < 6) {
            self.pass2Separator.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        if (self.pass1TextField.text.length < 6) {
            self.pass1Separator.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
    }
    return YES;
}
-(void)backTo{
    if (self.fromPromo) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }
}
#pragma mark - IBAction
- (IBAction)chooseNationality:(UIButton *)sender {
    [self.view endEditing:YES];
    self.nationalityPicker.hidden = NO;
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+200)];
}

- (IBAction)closeRegistratin:(UIButton *)sender {
    [self backTo];
}

- (IBAction)tapGesutre:(UITapGestureRecognizer *)sender {
    [self setContetSizeToZero];
    [self checkIsNotEmpty];
    self.nationalityPicker.hidden = YES;
}

- (IBAction)registerNow:(UIButton *)sender {
    if ([self checkAllFields]) {
        //Succed
        NSDictionary *dic = @{@"name":self.nameTextField.text,
                              @"email":self.emailTextField.text,
                              @"password":self.pass1TextField.text,
                              @"nationality":self.choosenNationality.modelID
                              };
        [self buildService:dic];
        self.view.userInteractionEnabled = NO;
        self.loaderSpinner.hidden = NO;
        [self.loaderSpinner startAnimating];
    }else{
        //Error
    }
}

- (IBAction)privacyBtn:(UIButton *)sender {
    
}

- (IBAction)loginWithFacebook:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    self.loaderSpinner.hidden = NO;
    [self.loaderSpinner startAnimating];
    [self.loginManager loginWithFBWithViewController:self];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.emailTextField) {
        if ([textField.text isValidEmail]) {
            [self setContetSizeToZero];
            self.emailSeparator.backgroundColor = [UIColor whiteColor];
            return YES;
        }else{
            self.emailSeparator.backgroundColor = [UIColor redColor];
             [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailformatcorrection];
            return NO;
        }
    }
    [self.view endEditing:YES];
    [self.scrollView setContentSize:self.scrollView.frame.size];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.nationalityPicker.hidden = YES;
    [self checkIsNotEmpty];
    if (textField == self.nameTextField) {
        self.nameSeparator.backgroundColor = [UIColor whiteColor];
    }
    if (textField == self.emailTextField) {
        self.emailSeparator.backgroundColor = [UIColor whiteColor];
    }
    if (textField == self.pass1TextField) {
        self.pass1Separator.backgroundColor = [UIColor whiteColor];
    }
    if (textField == self.pass2TextField) {
        self.pass2Separator.backgroundColor = [UIColor whiteColor];
    }
    if (textField == self.nationalityTextField) {
        self.nationalitySeparator.backgroundColor = [UIColor whiteColor];
    }
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+200)];
}

#pragma mark - LoginManagerDelegate

-(void)loginWithFacebookWithInfo:(NSDictionary *)userInfo{
    self.registerFromFb = YES;
    [self.manager loginWithFacebook:userInfo];
}

#pragma mark - ServicesManagerDelegate

-(void)registerUser:(NSDictionary *)user{
    NSDictionary *dic = user[@"data"];
    self.view.userInteractionEnabled = YES;
    self.loaderSpinner.hidden = YES;
    [self.loaderSpinner stopAnimating];
    if (dic) {
        [SharedPreferenceManager saveUserInfo:dic];
        [self backTo];
    }else{
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailIsUsed];
    }
}

-(void)errorRegisterUser:(NSError *)error{
    [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailIsUsed];
    self.view.userInteractionEnabled = YES;
    self.loaderSpinner.hidden = YES;
    [self.loaderSpinner stopAnimating];
}
-(void)loginUser:(NSDictionary *)token{
    
    [SharedPreferenceManager setUserToken:token[@"meta"][@"token"]];
    if (self.registerFromFb) {
        [self.manager getUserProfile:token[@"meta"][@"token"]];
    }else{
        [SharedPreferenceManager saveUserInfo:token[@"data"]];
        [self backTo];
        self.view.userInteractionEnabled = YES;
        self.loaderSpinner.hidden = YES;
        [self.loaderSpinner stopAnimating];
    }
    self.registerFromFb = NO;
}
-(void)errorLoginUser:(NSError *)error{
    [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailIsUsed];
    self.view.userInteractionEnabled = YES;
    self.loaderSpinner.hidden = YES;
    [self.loaderSpinner stopAnimating];
}

-(void)getUserProfile:(NSDictionary *)user{
    [SharedPreferenceManager saveUserInfo:user];
    self.view.userInteractionEnabled = YES;
    self.loaderSpinner.hidden = YES;
    [self.loaderSpinner stopAnimating];
    [self backTo];
}
-(void)errorGetUserProfile:(NSError *)error{
    [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.emailIsUsed];
    self.view.userInteractionEnabled = YES;
    self.loaderSpinner.hidden = YES;
    [self.loaderSpinner stopAnimating];
}
-(void)errorgetNationalities:(NSError *)error{
    
}
-(void)getNationalities:(NSArray<NationalitiesModel *> *)tourFilter{
    self.nationalities = tourFilter;
    [self.nationalityPicker reloadComponent:0];
}
#pragma mark - UIPicker
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.nationalities.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NationalitiesModel *model = self.nationalities[row];
    return model.name;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NationalitiesModel *model = self.nationalities[row];
    self.choosenNationality = model;
    self.nationalityTextField.text = model.name;
    self.nationalitySeparator.backgroundColor = [UIColor whiteColor];
}
@end
