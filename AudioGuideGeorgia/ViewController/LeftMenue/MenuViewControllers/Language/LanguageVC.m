//
//  LanguageVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LanguageVC.h"
#import "SharedPreferenceManager.h"
#import "LocalizableLabel.h"
#import "LanguageManager.h"
#import "SlideNavigationController.h"
#import "ServiceUpdateManager.h"

@interface LanguageVC ()
@property (weak, nonatomic) IBOutlet LocalizableLabel *languageLbl;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *langaugeBtns;
    @property (weak, nonatomic) IBOutlet LocalizableLabel *chooseLbl;

@end

@implementation LanguageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.languageLbl changeLocalizable:@"languagelbl"];
    [self.chooseLbl changeLocalizable:@"chooselbl"];

    Language language = [[LanguageManager sharedManager] currentLanguage];
    [self setCurrentLanguageBtn:language];
}
-(void)setCurrentLanguageBtn:(int)index{
    for (int i=0; i<self.langaugeBtns.count; i++) {
        UIButton *btn = self.langaugeBtns[i];
        if (i == index) {
            btn.layer.masksToBounds = YES;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.layer.borderWidth = 1.f;
        }else{
            btn.layer.masksToBounds = NO;
            btn.layer.borderWidth = 0;
        }
    }
}
-(void)updateServiceNeed{
    ServiceUpdateManager *manager = [ServiceUpdateManager sharedManager];
    manager.needFestivalUpdate = YES;
    manager.needShopUpdate = YES;
    manager.needRestaurantUpdate = YES;
    manager.needPageUpdate = YES;
    manager.needTourUpdate = YES;
    manager.needSightUpdate = YES;
    
    manager.needFestivalUpdateForLng = YES;
    manager.needShopUpdateForLng = YES;
    manager.needRestaurantUpdateForLng = YES;
    manager.needPageUpdateForLng = YES;
    manager.needTourUpdateForLng = YES;
    manager.needSightUpdateForLng = YES;
}
#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
- (IBAction)changeLanguage:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self setCurrentLanguageBtn:0];
            [SharedPreferenceManager saveLanguage:@"ka"];
            break;
        case 1:
            [self setCurrentLanguageBtn:1];
            [SharedPreferenceManager saveLanguage:@"ru"];
            break;
        case 2:
            [self setCurrentLanguageBtn:2];
            [SharedPreferenceManager saveLanguage:@"en"];
            break;
        default:
            break;
    }
    [self.languageLbl changeLocalizable:@"languagelbl"];
    [self.chooseLbl changeLocalizable:@"chooselbl"];
    [self updateServiceNeed];
}

@end
