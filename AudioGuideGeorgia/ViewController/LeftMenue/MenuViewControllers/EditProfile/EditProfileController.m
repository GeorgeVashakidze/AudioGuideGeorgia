//
//  EditProfileController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/7/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "EditProfileController.h"
#import "NSString+EmailValidation.h"
#import "UIColor+Color.h"
#import "SharedPreferenceManager.h"
#import "SlideNavigationController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ServiceManager.h"
#import "MMMaterialDesignSpinner.h"
#import "AlertManager.h"

@interface EditProfileController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *nameSeparator;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *emailSeparator;
@property (weak, nonatomic) IBOutlet UITextField *passTextField1;
@property (weak, nonatomic) IBOutlet UITextField *passTextField2;
@property (weak, nonatomic) IBOutlet UIImageView *passImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *passImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loadIndicator;
@property (strong,nonatomic) UIImage *chooseImage;
@property ServiceManager *manager;
@property AlertManager *alertManager;
@property NSString *fillname;
@property NSString *fillpassword;
@property NSString *passwordcharacters;
@property NSString *passnotmatch;
@end

@implementation EditProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _alertManager = [[AlertManager alloc] init];
    [self cornerRadiuseProfile];
    [self setUserInfo];
    [self buildService];
    [self setLocalizable];
}
-(void)setLocalizable{
    self.fillname = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"fillname"];
    self.fillpassword = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"fillpassword"];
    self.passwordcharacters = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"passwordcharacters"];
    self.passnotmatch = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"passnotmatch"];
}
- (void)buildService{
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
}
-(void)setUserInfo{
    NSDictionary *userInfo = [SharedPreferenceManager getUserInfo];
    self.emailTextField.text = userInfo[@"email"];
    self.nameTextField.text = userInfo[@"name"];
    [self setProfileImage:userInfo];
}
-(BOOL)checkIsNotEmpty{
    UIColor *grayColor = [UIColor colorWithRed:191.0 withGreen:191.0 withBlue:191.0 alpha:1];
    if (![self.nameTextField.text isEqualToString:@""]) {
        self.nameSeparator.backgroundColor = grayColor;
    }
    if (![self.passTextField1.text isEqualToString:@""]) {
        self.passImageView1.backgroundColor = grayColor;
    }
    if (![self.passTextField2.text isEqualToString:@""]) {
        self.passImageView2.backgroundColor = grayColor;
    }
    if ([self.passTextField1.text isEqualToString:self.passTextField2.text]) {
        self.passImageView1.backgroundColor = grayColor;
        self.passImageView2.backgroundColor = grayColor;
    }else{
        if (self.passTextField2.text.length > 6 ) {
            self.passImageView2.backgroundColor = grayColor;
        }
        if (self.passTextField1.text.length > 6) {
            self.passImageView1.backgroundColor = grayColor;
        }
    }
    return YES;
}
-(void)setProfileImage:(NSDictionary*)userInfo{
    NSString *userID = userInfo[@"email"];
    if (userID == nil) {
        userID = @"";
    }
    UIImage *profileSaveImage = [SharedPreferenceManager getProfileImage:userID];
    if (profileSaveImage) {
        self.profileImageView.image = profileSaveImage;
    }else{
        NSURL *imageFacebook = [SharedPreferenceManager getFacebookURl:userID];
        if (imageFacebook) {
            [self.profileImageView sd_setImageWithURL:imageFacebook placeholderImage:[UIImage imageNamed:@"userProfile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
        }else{
            NSString *avatar = userInfo[@"avatar"];
            if (avatar) {
                NSURL *avatarUrl = [NSURL URLWithString:[@ImageUrlHost stringByAppendingString:avatar]];
                [self.profileImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"userProfile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
            }
        }
        
    }
}
-(void)cornerRadiuseProfile{
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
}
-(BOOL)checkAllFields{
    UIColor *grayColor = [UIColor colorWithRed:191.0 withGreen:191.0 withBlue:191.0 alpha:1];
    if ([self.nameTextField.text isEqualToString:@""]) {
        self.nameSeparator.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillname];
        return NO;
    }else{
        self.nameSeparator.backgroundColor = grayColor;
    }
    if ([self.passTextField1.text isEqualToString:@""]) {
        self.passImageView1.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillpassword];
        return NO;
    }else{
        self.passImageView1.backgroundColor = grayColor;
    }
    if ([self.passTextField2.text isEqualToString:@""]) {
        self.passTextField2.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.fillpassword];
        return NO;
    }else{
        self.passImageView2.backgroundColor = grayColor;
    }
    if (![self.passTextField1.text isEqualToString:self.passTextField2.text]) {
        if (self.passTextField2.text.length < 6) {
            self.passImageView2.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        if (self.passTextField1.text.length < 6) {
            self.passImageView1.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        self.passImageView1.backgroundColor = [UIColor redColor];
        self.passImageView2.backgroundColor = [UIColor redColor];
        [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passnotmatch];
        return NO;
    }else{
        self.passImageView1.backgroundColor = grayColor;
        self.passImageView2.backgroundColor = grayColor;
        if (self.passTextField2.text.length < 6) {
            self.passImageView2.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
        if (self.passTextField1.text.length < 6) {
            self.passImageView1.backgroundColor = [UIColor redColor];
            [_alertManager showAlertWithController:self andTitle:@"REGISTRATION" withDesc:self.passwordcharacters];
            return NO;
        }
    }
    return YES;
}
#pragma mark - IBActions

- (IBAction)saveUser:(UIButton *)sender {
        if ([self checkAllFields]) {
            //DONE
            self.passImageView1.backgroundColor = [UIColor colorWithRed:191.0 withGreen:191.0 withBlue:191.0 alpha:1];
            self.passImageView2.backgroundColor = [UIColor colorWithRed:191.0 withGreen:191.0 withBlue:191.0 alpha:1];
            [SharedPreferenceManager setProfileImage:self.chooseImage withID:self.emailTextField.text];
            NSDictionary *dic;
            NSString *token = [SharedPreferenceManager getUserToken];
            if ([self.passTextField1.text isEqualToString:@"Tornike Davitashvili"]) {
                dic =    @{@"name":self.nameTextField.text,
                           @"email":self.emailTextField.text,
                           };
            }else{
                dic =    @{@"name":self.nameTextField.text,
                           @"email":self.emailTextField.text,
                           @"password":self.passTextField1.text,
                           };
            }
            
            [self.loadIndicator startAnimating];
            self.loadIndicator.hidden = NO;
            self.view.userInteractionEnabled = NO;
            [self.manager updateUserProfile:dic withToken:token];
        }
}

- (IBAction)backTo:(UIButton *)sender {
    [self checkIsNotEmpty];
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self setContetSizeToZero];
}

-(void)setContetSizeToZero{
    [self.view endEditing:YES];
    [self.scrollView setContentSize:self.scrollView.frame.size];
}

- (IBAction)changeProfilePicture:(UIButton *)sender {
    [self showActionSheet];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.emailTextField) {
        if ([textField.text isValidEmail]) {
            [self setContetSizeToZero];
            self.emailSeparator.backgroundColor = [UIColor colorWithRed:191.0 withGreen:191.0 withBlue:191.0 alpha:1];
            return YES;
        }else{
            self.emailSeparator.backgroundColor = [UIColor redColor];
            return NO;
        }
    }
    [self.view endEditing:YES];
    [self.scrollView setContentSize:self.scrollView.frame.size];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self checkIsNotEmpty];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+200)];
}

#pragma mark - UIActionSheet

-(void)showActionSheet{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:@"Choose" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showSourceTypeCamera];
//        [self dismissViewControllerAnimated:YES completion:^{
//        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showSourceTypeLibrary];
//        [self dismissViewControllerAnimated:YES completion:^{
//        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete it" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // Distructive button tapped.
        self.profileImageView.image = [UIImage imageNamed:@"userProfile"];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)showSourceTypeCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)showSourceTypeLibrary{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.chooseImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = self.chooseImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - ServicesManagerDelegate
-(void)updateUser:(NSDictionary *)user{
    
    [SharedPreferenceManager saveUserInfo:user[@"data"]];
    NSString *token = [SharedPreferenceManager getUserToken];
    if (self.chooseImage) {
        [self.manager updateUserImage:self.chooseImage withToken:token];
    }else{
        [self.loadIndicator stopAnimating];
        self.loadIndicator.hidden = YES;
        self.view.userInteractionEnabled = YES;
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(void)errorUpdateUser:(NSError *)error{
    [self.loadIndicator stopAnimating];
    self.loadIndicator.hidden = YES;
    self.view.userInteractionEnabled = YES;
}

-(void)errorUploadImage:(NSError *)error{
    [self.loadIndicator stopAnimating];
    self.loadIndicator.hidden = YES;
    self.view.userInteractionEnabled = YES;
}
-(void)uploadImage:(NSDictionary *)user{
    [self.loadIndicator stopAnimating];
    self.loadIndicator.hidden = YES;
    self.view.userInteractionEnabled = YES;
        [SharedPreferenceManager saveUserInfo:user[@"data"]];
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
        [self.navigationController popViewControllerAnimated:YES];
}
@end
