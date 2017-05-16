//
//  PasswordRecovery.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/19/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PasswordRecovery.h"
#import "MMMaterialDesignSpinner.h"
#import "LocalizableLabel.h"
#import "AlertManager.h"
#import "ServiceManager.h"
#import "NSString+EmailValidation.h"

@interface PasswordRecovery ()<ServicesManagerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderSpinner;
@property (strong, nonatomic) ServiceManager *manager;
@property AlertManager *alertManager;
@property NSString *emailformatcorrection;
@end

@implementation PasswordRecovery

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self cornerRadiuse];
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    self.alertManager = [[AlertManager alloc] init];
}
-(void)setLocalizable{
    self.emailformatcorrection = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"emailformatcorrection"];
}
-(void)cornerRadiuse{
    self.recoveryBtn.layer.masksToBounds = YES;
    self.recoveryBtn.layer.cornerRadius = 4;
    UIColor *color = [UIColor whiteColor];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"E-mail address" attributes:@{NSForegroundColorAttributeName: color}];
}
-(void)stopLoaderSpinner{
    [self.loaderSpinner stopAnimating];
    self.loaderSpinner.hidden = YES;
    self.view.userInteractionEnabled = YES;
}
-(void)retstorePassword{
    if ([_emailTextField.text isValidEmail]) {
        [self.manager restorePassword:self.emailTextField.text];
        self.view.userInteractionEnabled = NO;
        [self.manager restorePassword:self.emailTextField.text];
        [self.loaderSpinner startAnimating];
    }else{
        [self.alertManager showAlertWithController:self andTitle:@"RESET" withDesc:self.emailformatcorrection];
    }
}
#pragma mark - IBAction

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)recoverPass:(UIButton *)sender {
    [self retstorePassword];
}

#pragma mark - ServiceManager

-(void)restorePassword:(NSDictionary *)response{
    [self stopLoaderSpinner];
    if ([response[@"message"] isEqualToString:@"success"]) {
          [self.alertManager showAlertWithController:self andTitle:@"RESET" withDesc:@"We have e-mailed your password reset link!"];
    }else{
         [self.alertManager showAlertWithController:self andTitle:@"RESET" withDesc:@"This mail does not exist"];
    }
  
}
-(void)errorRestorePasswor:(NSError *)error{
    [self stopLoaderSpinner];
        [self.alertManager showAlertWithController:self andTitle:@"RESET" withDesc:@"This mail does not exist"];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    [self retstorePassword];
    return YES;
}

@end
