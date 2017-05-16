//
//  LeftMenuController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/28/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LeftMenuController.h"
#import "SlideNavigationController.h"
#import "SharedPreferenceManager.h"
#import "LoginManager.h"
#import "SharedPreferenceManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ServiceManager.h"
#import "LanguageManager.h"
#import "EditProfileController.h"
#import "LeftMenuStaticTableView.h"

@interface LeftMenuController ()<LoginManagerDelegate,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userProflie;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *editProfileBtn;
@property (weak, nonatomic) IBOutlet UIButton *signUpWithEmail;
@property (weak, nonatomic) IBOutlet UIButton *signUpWithFacebook;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpEmailBottomConstrait;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpEmailHEight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpFacebookHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menueTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *logOutBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileTopConstraint;
@property (nonatomic,strong) LoginManager *loginManager;
@property (nonatomic,strong) ServiceManager *manager;
@property (weak, nonatomic) LeftMenuStaticTableView *statiTableView;
@property NSURL *facebookURL;
@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _statiTableView = self.childViewControllers.lastObject;
    
    self.loginManager = [[LoginManager alloc] init];
    self.loginManager.delegateLogin = self;
    [self checkIfLogedIn];
    if(IS_IPHONE5){
        self.menueTopConstraint.constant -= 20;
        self.profileTopConstraint.constant -= 20;
    }
    [self setLocatizable];

    [self cornerRadiuseProfileImage];
    __block typeof(self) blockSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [blockSelf checkIfLogedIn];
        NSDictionary *userInfo = [SharedPreferenceManager getUserInfo];
        [blockSelf setUserData:userInfo];
        [blockSelf setLocatizable];
    }];

}
-(void)setLocatizable{
    NSString *loginBtn = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"loginBtn"];
    NSString *facebookBtn = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"facebookBtn"];
    NSString *signUpEmail = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"signUpEmail"];
    NSString *logOut = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"logOut"];
    NSString *editProfile = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"editProfile"];
    
    [self.signUpWithFacebook setTitle:facebookBtn forState:UIControlStateNormal];
    [self.signUpWithEmail setTitle:signUpEmail forState:UIControlStateNormal];
    [self underLineTextBtn:self.logOutBtn withText:logOut];
    [self underLineTextBtn:self.editProfileBtn withText:editProfile];
    [self underLineTextBtn:self.loginBtn withText:loginBtn];
}
-(void)checkIfLogedIn{
    NSDictionary *userInfo = [SharedPreferenceManager getUserInfo];
    if ([self.loginManager getAccessToken] || userInfo) {
        [self loadSignUserMenue];
        NSDictionary *userInfo = [SharedPreferenceManager getUserInfo];
        [self setUserData:userInfo];
    }else{
        [self loadUnSignUserMenue];
    }
}
-(void)setUserData:(NSDictionary*)userInfo{
    self.userName.text = userInfo[@"name"];
    NSString *userID = userInfo[@"email"];
    if (userID == nil) {
        userID = @"";
    }
    UIImage *profileSaveImage = [SharedPreferenceManager getProfileImage:userID];
    if (profileSaveImage) {
        self.userProflie.image = profileSaveImage;
    }else{
        NSURL *imageFacebook = [SharedPreferenceManager getFacebookURl:userID];
        if (imageFacebook) {
            _facebookURL = imageFacebook;
            [self.userProflie sd_setImageWithURL:imageFacebook placeholderImage:[UIImage imageNamed:@"userProfile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
        }else{
            NSString *avatar = userInfo[@"avatar"];
            if (avatar) {
                NSURL *avatarUrl = [NSURL URLWithString:[@ImageUrlHost stringByAppendingString:avatar]];
                [self.userProflie sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"userProfile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }];
            }
        }
 
    }
}
-(void)cornerRadiuseProfileImage{
    self.userProflie.layer.masksToBounds = YES;
    self.userProflie.layer.cornerRadius = self.userProflie.frame.size.width/2;
}

-(void)underLineTextBtn:(UIButton*)sender withText:(NSString*)titleText{
    NSDictionary * linkAttributes = @{NSForegroundColorAttributeName:sender.titleLabel.textColor, NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:titleText attributes:linkAttributes];
        [sender setAttributedTitle:attributedString forState:UIControlStateNormal];
}
-(void)loadSignUserMenue{
    self.signUpWithEmail.hidden = YES;
    self.signUpEmailHEight.constant = 0;
    self.signUpWithFacebook.hidden = YES;
    self.signUpFacebookHeight.constant = 0;
    self.signUpEmailBottomConstrait.constant = 10;
    self.userName.hidden = NO;
    self.userProflie.hidden = NO;
    self.editProfileBtn.hidden = NO;
    if (IS_IPHONE5) {
        self.menueTopConstraint.constant = 120;
    }else{
        self.menueTopConstraint.constant = 140;
    }
    self.logOutBtn.hidden = NO;
    self.loginBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)loadUnSignUserMenue{
    self.logOutBtn.hidden = YES;
    self.loginBtn.hidden = NO;
    if (IS_IPHONE5) {
        self.menueTopConstraint.constant = 56;
    }else{
        self.menueTopConstraint.constant = 76;
    }
    self.signUpWithEmail.hidden = NO;
    self.signUpEmailHEight.constant = 30;
    self.signUpWithFacebook.hidden = NO;
    self.signUpFacebookHeight.constant = 30;
    self.signUpEmailBottomConstrait.constant = 50;
    self.userName.hidden = YES;
    self.userProflie.hidden = YES;
    self.editProfileBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - IBActions

- (IBAction)loginUserEmail:(UIButton *)sender {
    [self navigatioToController:@"LoginView"];
}

- (IBAction)logOutUser:(UIButton *)sender {
    [self loadUnSignUserMenue];
    [self.loginManager logOutUser];
    NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
    [SharedPreferenceManager saveFacebookURl:nil withID:userDic[@"email"]];
    [SharedPreferenceManager saveUserInfo:nil];
    [SharedPreferenceManager setUserToken:nil];
    [self.statiTableView.tableView reloadData];
    
//    [self.manager updateTourToNoLive];
    
    NSArray *arrayDownloadTours = [SharedPreferenceManager getSaveToursIDs];
    NSMutableArray *arrayOfDOwnllotTOur = [[NSMutableArray alloc] initWithArray:arrayDownloadTours];
    for (NSDictionary *dic in arrayOfDOwnllotTOur) {
        if ([dic[@"tourrecept"] isEqualToString:@""] || [dic[@"tourrecept"] length] < 9) {
            [SharedPreferenceManager removeDownloadToursID:dic];
        }
    }
}
- (IBAction)loginWithEmail:(UIButton *)sender {
    [self navigatioToController:@"RegistrationController"];    
}
- (IBAction)loginWithFacebook:(UIButton *)sender {
    [self.loginManager loginWithFBWithViewController:[SlideNavigationController sharedInstance]];
}

- (IBAction)editProfileTaped:(UIButton *)sender {
    [self navigatioToController:@"EditProfileController"];
}
-(void)navigatioToController:(NSString*)identifire{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *viewController = (UIViewController *)[mainStoryboard
                                                            instantiateViewControllerWithIdentifier:identifire];
    if ([viewController isKindOfClass:[EditProfileController class]]) {
        ((EditProfileController*)viewController).facebookUrl = _facebookURL;
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:viewController
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}

#pragma mark - LoginManagerDelegate

-(void)loginWithFacebookWithInfo:(NSDictionary *)userInfo{
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    [self.manager loginWithFacebook:userInfo];
}
-(void)getUserFacebookImage:(NSURL *)imageURl{
    _facebookURL= imageURl;
    [self.userProflie sd_setImageWithURL:imageURl placeholderImage:[UIImage imageNamed:@"userProfile"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    
    }];
}
#pragma mark - ServicesManagerDelegate

-(void)errorLoginUser:(NSError *)error{
    
}

-(void)loginUser:(NSDictionary *)token{
    [SharedPreferenceManager setUserToken:token[@"meta"][@"token"]];
    [self.manager getUserProfile:token[@"meta"][@"token"]];
}

-(void)getUserProfile:(NSDictionary *)user{
    [SharedPreferenceManager saveUserInfo:user];

    [self setUserData:user];
    [self loadSignUserMenue];
    [self.statiTableView.tableView reloadData];
}
-(void)errorGetUserProfile:(NSError *)error{
    
}
@end
