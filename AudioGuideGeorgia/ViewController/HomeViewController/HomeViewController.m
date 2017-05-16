//
//  HomeViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/28/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "HomeViewController.h"
#import "MapViewController.h"
#import "MyToursVC.h"
#import "SightsViewController.h"
#import "CoreLocationManager.h"
#import "ServiceManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SharedPreferenceManager.h"
#import "LocalizableLabel.h"
#import "FBSDKCoreKit.h"

@interface HomeViewController ()<UIGestureRecognizerDelegate,LocationManagerDelegate,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet LocalizableLabel *infoLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *sightsLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *mapLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *toursLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *locationLbl;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfNavigation;
@property (nonatomic,strong) UIStoryboard *mainStoryboard;
@property (weak, nonatomic) IBOutlet UIButton *tourBtn;
@property (nonatomic,strong) CoreLocationManager *locationManager;
@property NSArray<CityModel*> *cityarray;
@property CityModel *currentCity;
@property CLLocation *currentLocation;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FBSDKAppEvents logEvent:@"Launching App"];

    // Do any additional setup after loading the view.
    [self configureSlideMenu];
    [self initStoryBoard];
    [self drawCornerLocationBtn];
    self.locationManager = [[CoreLocationManager alloc] init];
    self.locationManager.locationDelegate = self;
    [self.locationManager startLocation];
    [self adjustConstants];
    [self buildService];
    [self setCurrentLocation];
    [self localizableLbl];
    __block typeof(self) blockSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        [blockSelf localizableLbl];
    }];
    [self setDefaultPreferences];
    [SlideNavigationController sharedInstance].needTapGesture = NO;
}
-(void)setDefaultPreferences{
    NSDictionary *dic = [SharedPreferenceManager getPreferences];
    if (dic == nil) {
        dic = @{@"autoplayer":[NSNumber numberWithBool:YES]};
        [SharedPreferenceManager savePreferences:dic];
    }
}
-(void)localizableLbl{
    [self.infoLbl changeLocalizable:@"info"];
    [self.sightsLbl changeLocalizable:@"sights"];
    [self.mapLbl changeLocalizable:@"map"];
    [self.toursLbl changeLocalizable:@"tours"];
    [self.locationLbl changeLocalizable:@"currentlocation"];
}
-(void)setCurrentLocation{
    CityModel *dic = [SharedPreferenceManager getCurrentLocation];
    if (dic) {
        self.currentCity = dic;
        NSURL *imageURL = [NSURL URLWithString:dic.imagesFirst];
        __block typeof(self) blockSelf = self;
        __block BOOL loadImage;
        [self.posterByCity sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"HomeBG"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (cacheType == SDImageCacheTypeNone) {
                if (!loadImage) {
                    blockSelf.posterByCity.alpha = 0;
                    [UIView animateWithDuration:0.5 animations:^{
                        blockSelf.posterByCity.alpha = 1;
                    }];
                }
            } else {
                loadImage = YES;
                blockSelf.posterByCity.alpha = 1;
            }
        }];
        [self.locationButton setTitle:dic.cityTitle forState:UIControlStateNormal];
    }
}
-(void)buildService{
    ServiceManager *manager = [[ServiceManager alloc] init];
    manager.delegate = self;
    [manager getCities];
}
-(void)adjustConstants{
    if (IS_IPHONE6) {
        self.heightOfNavigation.constant = 370;
    }else if (IS_IPHONE5){
        self.heightOfNavigation.constant = 330;
    }
}
-(void)drawCornerLocationBtn{
    self.locationButton.layer.masksToBounds = YES;
    self.locationButton.layer.borderWidth = 1.0f;
    self.locationButton.layer.cornerRadius = 5.0f;
    self.locationButton.layer.borderColor = [UIColor whiteColor].CGColor;
}
-(void) initStoryBoard{
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
}
-(void)configureSlideMenu{
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    [SlideNavigationController sharedInstance].enableShadow = YES;
    [SlideNavigationController sharedInstance].portraitSlideOffset = 60.0f;
    [SlideNavigationController sharedInstance].landscapeSlideOffset = 60.0f;
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

#pragma mark - IBActins

- (IBAction)showMenu:(UIButton *)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)showMapView:(UIButton *)sender {
    MapViewController *viewController = (MapViewController *)[self.mainStoryboard
                                                            instantiateViewControllerWithIdentifier:@"MapViewController"];
    [[SlideNavigationController sharedInstance] pushViewController:viewController animated:YES];

}

- (IBAction)showTours:(UIButton *)sender {
    MyToursVC *viewController = (MyToursVC *)[self.mainStoryboard
                                                              instantiateViewControllerWithIdentifier:@"MyToursVC"];
    viewController.isFromMenu = YES;
    viewController.isEmpty = YES;
    viewController.currentCity = self.currentCity;
    [[SlideNavigationController sharedInstance] pushViewController:viewController animated:YES];

}

- (IBAction)showSights:(UIButton *)sender {
    SightsViewController *viewController = (SightsViewController *)[self.mainStoryboard
                                                              instantiateViewControllerWithIdentifier:@"SightsViewController"];
    viewController.currentCity = self.currentCity;
    [[SlideNavigationController sharedInstance] pushViewController:viewController animated:YES];
}
-(void)filterCityByCurrentLocation{
    for (int i = 0; i< self.cityarray.count; i++) {
        CityModel *model = self.cityarray[i];
        if (self.currentLocation.coordinate.longitude > model.west && self.currentLocation.coordinate.longitude < model.east && self.currentLocation.coordinate.latitude > model.south && self.currentLocation.coordinate.latitude < model.north) {
            self.currentCity = model;
            NSURL *imageURL = [NSURL URLWithString:model.imagesFirst];
            __block typeof(self) blockSelf = self;
            __block BOOL loadImage;
            [self.posterByCity sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"HomeBG"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (cacheType == SDImageCacheTypeNone) {
                    if (!loadImage) {
                        blockSelf.posterByCity.alpha = 0;
                        [UIView animateWithDuration:0.5 animations:^{
                            blockSelf.posterByCity.alpha = 1;
                        }];
                    }

                } else {
                    loadImage = 1;
                    blockSelf.posterByCity.alpha = 1;
                }
            }];
            [SharedPreferenceManager saveCurrentLocation:model];
            break;
        }
    }
}
#pragma mark - LocationManagerDelegate

-(void)getCurrentCity:(NSString *)city{
    [self.locationButton setTitle:city forState:UIControlStateNormal];
}
-(void)getCurrentLocation:(CLLocation *)location{
    self.currentLocation = location;
    [self filterCityByCurrentLocation];
    
}

#pragma mark - ServicesManagerDelegate
-(void)errorgetCityModel:(NSError *)error{

}
-(void)getCityModel:(NSArray<CityModel *> *)tourFilter{
    self.cityarray = tourFilter;
    [self filterCityByCurrentLocation];
}

@end
