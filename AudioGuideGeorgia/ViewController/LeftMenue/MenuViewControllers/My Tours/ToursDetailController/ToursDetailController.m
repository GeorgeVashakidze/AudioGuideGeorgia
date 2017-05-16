//
//  ToursDetailController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ToursDetailController.h"
#import "ToursDetaliTableView.h"
#import "SlideNavigationController.h"
#import "MapViewController.h"
#import "TourDownloadAlert.h"
#import "ServiceManager.h"
#import "SharedPreferenceManager.h"
#import "ReviewView.h"
#import "DownloadMapView.h"
#import "LocalizableLabel.h"

@interface ToursDetailController ()<StatiTableviewDelegate,DownloadAlertDelegate,ServicesManagerDelegate,MapViewDelegateForBack,ReviewDelegate,DownloadMapViewtDelegate>
@property (weak, nonatomic) IBOutlet LocalizableLabel *controllerTitle;
@property (weak, nonatomic) ToursDetaliTableView *statiTableView;
@property (weak, nonatomic) TourDownloadAlert *downloadAlert;
@property (weak, nonatomic) IBOutlet UIButton *mapViewBtn;
@property ServiceManager *manager;
@property NSUInteger downloadCount;
@property NSUInteger downloadIndex;
@property int tourIsLive;
@property BOOL needTourUpdate;
@property NSString *base64Str;
@property int countOfUpdateSights;
@property long long int tourTotalMemory;
@property NSDecimalNumber *currentTourPrice;
@property (weak,nonatomic) ReviewView *reviewView;
@property (weak, nonatomic) DownloadMapView *downloadView;
@property NSString *updatetoursights;
@end

@implementation ToursDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _base64Str = @"";
    self.tourTotalMemory = 0;
    // Do any additional setup after loading the view.
    [self configureFromInfo];
    self.tourIsLive = self.tourModel.tourlive;
    self.downloadCount = self.tourModel.sightTour.count;
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
    self.statiTableView.tourDownloadDelegate = self;
    if(self.isFormInfo){
        if (self.isFromMapTapped) {
            self.mapViewBtn.hidden = YES;
        }else{
            self.mapViewBtn.hidden = NO;
        }
    }else{
        self.mapViewBtn.hidden = YES;
    }
    [self buildService];
    [self needTourUpdates];
    [self GetMemoryTour];
    [self setLocalizavleStrings];
}
-(void)setLocalizavleStrings{
    self.updatetoursights = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"updatetoursights"];
}
-(void)loadReviewView{
    self.reviewView =  [[[NSBundle mainBundle] loadNibNamed:@"ReviewView" owner:self options:nil] objectAtIndex:0];
    self.reviewView.delegateRaiting = self;
    self.reviewView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.reviewView.tourID = [self.tourID intValue];
    self.reviewView.controller = self;
    [self.view addSubview:self.reviewView];
}

-(void)GetMemoryTour{
    for (SightModel *model in self.tourModel.sightTour) {
        self.tourTotalMemory += [model.auidoFileMemory unsignedIntegerValue];
    }
}
-(void)needTourUpdates{
    _countOfUpdateSights = 0;
    for (SightModel *sight in self.tourModel.sightTour) {
        if (sight.needUpdate == 1) {
            _countOfUpdateSights += 1;
            _needTourUpdate = YES;
        }
    }
}
-(void)downloadOfflineMap{
    self.downloadView = [[[NSBundle mainBundle] loadNibNamed:@"DownloadMapView" owner:self options:nil] objectAtIndex:0];
    self.downloadView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.downloadView.downloadDelegate = self;
    [self.downloadView cornerRaidus];
    self.downloadView.controler = self;
    [self.view addSubview:self.downloadView];
}
-(void)updateViewToDelete:(NSString*)tourStatuse{
    self.tourModel.isDeleteTour = 1;
    [self.statiTableView.headerView.downloadButton setTitle:tourStatuse forState:UIControlStateNormal];
    for (SightModel *sightModel in self.tourModel.sightTour) {
        sightModel.sightPrice = 1;
        [self.manager updateSightAudio:[sightModel.sightID intValue] withAudio:@"" withRecept:self.tourModel.receptStr];
    }
}
-(void)updateViewToLive:(NSString*)tourStatuse{
    self.tourIsLive = 1;
    ToursModel *model =  [self.statiTableView getTourModel];
    model.tourlive = 1;
    NSDictionary *userDIc = [SharedPreferenceManager getUserInfo];
    if(userDIc){
        self.tourModel.userTokens = @[[userDIc[@"id"] stringValue]];
    }
    [self.manager updateTourTolive:self.tourModel withLive:1];
    [self.statiTableView.headerView.downloadButton setTitle:tourStatuse forState:UIControlStateNormal];
    NSNumber *offlineMap = [SharedPreferenceManager getDownloadPack];
    if(offlineMap == nil){
        [self downloadOfflineMap];
    }
}
-(void)buildService{
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
}
-(void)loadDownloadAlert{
    self.downloadAlert = [[[NSBundle mainBundle] loadNibNamed:@"TourDownloadAlert" owner:self options:nil] objectAtIndex:0];
    self.downloadAlert.downloadAlertDelegate = self;
    self.downloadAlert.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20);
    [self.view addSubview:self.downloadAlert];
    self.downloadAlert.tourTotalMemory = self.tourTotalMemory;
    if ([self.tourModel.receptStr isEqualToString:@""]) {
        NSString *subcribStr = [SharedPreferenceManager getSubscriber];
        if (subcribStr) {
            self.downloadAlert.base64Recep = subcribStr;
        }
    }else{
        self.downloadAlert.base64Recep = self.tourModel.receptStr;
    }
    self.downloadAlert.titlePurchase = self.tourModel.tourTitle;
    self.downloadAlert.productID = [self.tourModel.toursID stringValue];
    [self.downloadAlert cornerRaidus];
    NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
    NSString *subscriber = [SharedPreferenceManager getSubscriber];
    BOOL tourIsFree = NO;
    if (_tourModel.tourIsFree == 1) {
        tourIsFree = YES;
    }
    NSArray *arrayDownloadTours = [SharedPreferenceManager getSaveToursIDs];
    BOOL buyAnotherLanguage = NO;
    for (NSDictionary *item in arrayDownloadTours) {
        if ([item[@"tourId"] intValue] == [self.tourModel.toursID intValue]) {
            buyAnotherLanguage = YES;
            _downloadAlert.base64Recep = item[@"tourrecept"];
            break;
        }
    }
    if (buyAnotherLanguage || [userDic[@"promotion"] intValue] == 1 || (subscriber && self.tourModel.isDeleteTour == 1) || tourIsFree || self.tourModel.receptStr.length > 9) {
        self.downloadAlert.isActivatePromoCode = YES;
        if (self.tourModel.isDeleteTour == 1) {
            [self.downloadAlert showAnaimationDownloadingView:1 withHanlde:^{
            }];
        }else if(subscriber || [userDic[@"promotion"] intValue] == 1){
            [self.downloadAlert showAnaimationDownloadingView:1 withHanlde:^{
            }];
        }else{
            [self.downloadAlert showAnimationDownloadView];
        }
    }else{
        self.downloadAlert.isActivatePromoCode = NO;
        [self.downloadAlert showButtonsWithAnimation:1 withHanlde:^{
            
        }];
    }
}
-(void)configureFromInfo{
    if (self.titleStr) {
        self.controllerTitle.text = self.titleStr;
    }else{
        [self.controllerTitle changeLocalizable:@"detailtitle"];
    }
    self.statiTableView = self.childViewControllers.lastObject;
    self.statiTableView.isFromInfo = self.isFormInfo;
    self.statiTableView.tourID = self.tourID;
    self.statiTableView.shopDetail = self.shopModel;
    self.statiTableView.resDetail = self.restModel;
    self.statiTableView.infoType = self.infoType;
    self.statiTableView.toursModel = self.tourModel;
    self.statiTableView.festival = self.festivalModel;
    [self.statiTableView buildService];
}
#pragma mark - IBAction

- (IBAction)backTo:(UIButton*)sender {
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToMapView:(UIButton *)sender {

    if (self.tourIsLive == 1) {
        [self tryDemoTour];
    }else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        MapViewController *viewController = (MapViewController *)[mainStoryboard
                                                                  instantiateViewControllerWithIdentifier:@"MapViewController"];
        //initWithLatitude:41.7123093 longitude:44.7801688
        RestaurantsModel *model = self.statiTableView.resDetail;
        ShopsModel *shops = self.statiTableView.shopDetail;
        FestivalsModel *festModel = self.statiTableView.festival;
        if (model) {
            viewController.needGPSCoordinates = YES;
            viewController.sightChoosenCoordiantes = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
        }else if (shops){
            viewController.needGPSCoordinates = YES;
            viewController.sightChoosenCoordiantes = CLLocationCoordinate2DMake([shops.sightLat doubleValue], [shops.sightLng doubleValue]);
        }else if (festModel){
            viewController.needGPSCoordinates = YES;
            viewController.sightChoosenCoordiantes = CLLocationCoordinate2DMake([festModel.sightLat doubleValue], [festModel.sightLng doubleValue]);
        }
        viewController.currentTourPrice = self.currentTourPrice;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (void)showUpdateAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TOUR UPDATE" message:self.updatetoursights preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        self.downloadAlert = [[[NSBundle mainBundle] loadNibNamed:@"TourDownloadAlert" owner:self options:nil] objectAtIndex:0];
        self.downloadAlert.downloadAlertDelegate = self;
        self.downloadAlert.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20);
        [self.view addSubview:self.downloadAlert];
        if ([self.tourModel.receptStr isEqualToString:@""]) {
            NSString *subcribStr = [SharedPreferenceManager getSubscriber];
            if (subcribStr) {
                self.downloadAlert.base64Recep = subcribStr;
            }
        }else{
            self.downloadAlert.base64Recep = self.tourModel.receptStr;
        }
        self.downloadAlert.titlePurchase = self.tourModel.tourTitle;
        self.downloadAlert.productID = [self.tourModel.toursID stringValue];
        [self.downloadAlert cornerRaidus];
        [self.downloadAlert showAnimationDownloadProgress];
        
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    [alert addAction:okAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma - mark StatiTableviewDelegate

-(void)downloadTour{
    if(self.tourIsLive == 1 && self.tourModel.receptStr.length > 9){
        if (self.needTourUpdate) {
            [self showUpdateAlert];
        }else{
            [self tryDemoTour];
        }
    }else if(self.tourIsLive == 1){
        NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
        if (userDic) {
            int countOfcheck = 0;
            for (int i = 0; i < self.tourModel.userTokens.count; i++) {
                NSString *userIDs = self.tourModel.userTokens[i];
                if ([userIDs isEqualToString:[userDic[@"id"] stringValue]]) {
                    if (self.needTourUpdate) {
                        [self showUpdateAlert];
                    }else{
                        [self tryDemoTour];
                    }
                    break;
                }else{
                    countOfcheck += 1;
                }
            }
            if (countOfcheck == self.tourModel.userTokens.count) {
                [self loadDownloadAlert];
            }
        }else{
            [self loadDownloadAlert];
        }
    }else{
        [self loadDownloadAlert];
    }
}
-(void)deleteTour{
    self.tourIsLive = 0;
    ToursModel *model =  [self.statiTableView getTourModel];
    model.tourlive = 0;
    [self.statiTableView.headerView.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    for (SightModel *sight in self.tourModel.sightTour ) {
        [self.manager updateSightAudio:[sight.sightID intValue] withAudio:@"" withRecept:self.tourModel.receptStr];
    }
    self.tourModel.isDeleteTour = 1;
    [self.manager updateTourToDelete:self.tourModel];
    [self.statiTableView.tableView reloadData];
}
-(void)showAlertView:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - DownloadAlertDelegate
-(void)updatePrice:(NSDecimalNumber *)price{
    self.currentTourPrice = price;
}
-(void)tryDemoTour{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    MapViewController *viewController = (MapViewController *)[mainStoryboard
                                                              instantiateViewControllerWithIdentifier:@"MapViewController"];
    //initWithLatitude:41.7123093 longitude:44.7801688
    viewController.needGPSCoordinates = YES;
    ToursModel *model =  [self.statiTableView getTourModel];
    viewController.tourModel = model;
    if (model.sightTour.count > 0) {
        SightModel *sight = model.sightTour[0];
        viewController.sightChoosenCoordiantes = CLLocationCoordinate2DMake([sight.sightLat doubleValue], [sight.sightLng doubleValue]);
        [self.navigationController pushViewController:viewController animated:YES];
    }
    viewController.delegateForBack = self;
    viewController.currentTourPrice = self.currentTourPrice;
    [self.downloadAlert removeFromSuperview];
}
-(void)faildBuy:(NSString *)error{
    [self showAlertView:error];
}
-(void)downloadCompleted:(NSString *)base64Recept{
    self.tourModel.receptStr = base64Recept;
    [self.manager updateTourToDelete:self.tourModel];
    for (SightModel *sightModel in self.tourModel.sightTour) {
        sightModel.baseReceptStr = self.tourModel.receptStr;
        [self.manager updateSightAudio:[sightModel.sightID intValue] withAudio:@"" withRecept:self.tourModel.receptStr];
    }
    [self updateViewToDelete:@"Download"];
}
-(void)startTour{
    [self tryDemoTour];
}
-(void)buyTour:(NSString *)base64Recept{
    NSArray<SightModel*> *sightArray = self.tourModel.sightTour;
    NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
    NSString *baseSubscriber = [SharedPreferenceManager getSubscriber];
    BOOL promoCodeActivate = NO;
    NSString *token = @"";
    if ([userDic[@"promotion"] intValue] == 1) {
        promoCodeActivate = YES;
        token = [SharedPreferenceManager getUserToken];
    }
    if (baseSubscriber) {
        base64Recept = baseSubscriber;
    }
    BOOL isFreeTour = NO;
    if (_tourModel.tourIsFree == 1) {
        isFreeTour = YES;
    }
    _base64Str = base64Recept;
    
    if (sightArray.count > 0 && _downloadIndex < sightArray.count) {
        NSString *persetStr = [NSString stringWithFormat:@"0%%"];
        [self.downloadAlert.downloadProgresView setProgress:0];
        ((UILabel*)self.downloadAlert.downloadProgresView.centralView).text = persetStr;
        NSUInteger i = _downloadIndex;
        SightModel *modelSight = sightArray[i];
            NSArray *audioArray=  modelSight.audiosFirst;
            NSArray *audioArrayName =  modelSight.audiosFirstName;
            if (audioArray.count > 0) {
                NSString *audio = audioArray[0];
                NSString *fileName = audioArrayName[0];
                if(audio){
                    if (![audio isEqualToString:@""]) {
                        NSString *audioStr = [[audio stringByAppendingString:@"?lang="] stringByAppendingString:[[LanguageManager sharedManager] getSelectedLanguage]];
                        NSString *urlAudioWithKey = @"";
                        if (promoCodeActivate) {
                            urlAudioWithKey = [[audioStr stringByAppendingString:@"&token="] stringByAppendingString:token];
                        }else{
                                 urlAudioWithKey = [[audioStr stringByAppendingString:@"&receipt="] stringByAppendingString:base64Recept];
                        }
                        if (isFreeTour) {
                            urlAudioWithKey = [[audioStr stringByAppendingString:@"&tour="] stringByAppendingString:[_tourModel.toursID stringValue]];
                        }
                        if (_needTourUpdate) {
                            if (modelSight.needUpdate == 1) {
                                [self.manager downloadTour:urlAudioWithKey withFileName:fileName];
                            }
                        }else{
                            [self.manager downloadTour:urlAudioWithKey withFileName:fileName];
                        }
                    }else{
                        _downloadIndex += 1;
                        [self buyTour:_base64Str];
                    }
                }
            }
    }
}

-(void)suscribeApp{
    [self.downloadAlert removeFromSuperview];
}
-(void)updateSightWihtLocalPath:(NSString *)filePath withFileName:(NSString*)fileName withID:(NSString*)sightsID{
    for (int i = 0; i<self.tourModel.sightTour.count; i++) {
        SightModel *sightModel = self.tourModel.sightTour[i];
        NSArray *audioArrayName =  sightModel.audiosFirstName;
        if (audioArrayName.count > 0) {
            NSString *audio = audioArrayName[0];
            if(audio){
                if ([filePath hasSuffix:audio]) {
                    sightModel.audioName_Local = audio;
                    sightModel.sightPrice = 1;
                    [self.manager updateSightAudio:[sightModel.sightID intValue] withAudio:audio withRecept:self.tourModel.receptStr];
                }
            }
        }
    }
}
#pragma mark - Servicemanager
-(void)completedDownloadTour:(NSString *)filePath withFileName:(NSString *)fileName withID:(NSString *)sightsID{
    self.downloadIndex+=1;
    [self buyTour:_base64Str];
    float progress = (float)_downloadIndex/(float)_downloadCount;
    NSString *persetStr = [NSString stringWithFormat:@"%.0f%%",progress*100];
    [self.downloadAlert.downloadProgresView setProgress:progress];
    
    ((UILabel*)self.downloadAlert.downloadProgresView.centralView).text = persetStr;
    [self updateSightWihtLocalPath:filePath withFileName:fileName withID:sightsID];
    
    if (_needTourUpdate) {
        if (_countOfUpdateSights == self.downloadIndex) {
            _needTourUpdate = NO;
            [UIView animateWithDuration:0.4 animations:^{
                self.downloadAlert.alpha = 0;
            } completion:^(BOOL finished) {
                [self.downloadAlert removeFromSuperview];
                self.tourModel.receptStr = _base64Str;
                [self.manager updateTourTolive:self.tourModel withLive:1];
                if (self.base64Str == nil) {
                    self.base64Str = @"";
                }
                NSDictionary *tourDic = @{@"tourId":self.tourModel.toursID,@"tourrecept":self.base64Str};
                [SharedPreferenceManager saveDownloadToursID:tourDic];
                [self updateViewToLive:@"Start tour"];
            }];
            return;
        }
    }
    
    if (self.downloadIndex == self.downloadCount) {
        [UIView animateWithDuration:0.4 animations:^{
            self.downloadAlert.alpha = 0;
        } completion:^(BOOL finished) {
            [self.downloadAlert removeFromSuperview];
            self.tourModel.receptStr = _base64Str;
            [self.manager updateTourTolive:self.tourModel withLive:1];
            if (self.base64Str == nil) {
                self.base64Str = @"";
            }
            NSDictionary *tourDic = @{@"tourId":self.tourModel.toursID,@"tourrecept":self.base64Str};
            [SharedPreferenceManager saveDownloadToursID:tourDic];
            [self updateViewToLive:@"Start tour"];
        }];
    }
}
-(void)progressDownload:(float)progress{
   
}
#pragma mark - MapViewDelegateForBack
-(void)buyDemoTour{
    self.downloadAlert = [[[NSBundle mainBundle] loadNibNamed:@"TourDownloadAlert" owner:self options:nil] objectAtIndex:0];
    self.downloadAlert.downloadAlertDelegate = self;
    self.downloadAlert.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20);
    [self.view addSubview:self.downloadAlert];
    self.downloadAlert.tourTotalMemory = self.tourTotalMemory;
    self.downloadAlert.titlePurchase = self.tourModel.tourTitle;
    self.downloadAlert.productID = [self.tourModel.toursID stringValue];
    [self.downloadAlert cornerRaidus];
    BOOL tourIsFree = NO;
    if (_tourModel.tourIsFree == 1) {
        tourIsFree = YES;
    }
    [self.downloadAlert showAnimationDownloadView];
}
-(void)raitTour{
    int passSights = 0;
    for (SightModel *sights in self.tourModel.sightTour) {
        if (sights.sightIsPass == 1) {
            passSights += 1;
        }
    }
    if (passSights == self.tourModel.sightTour.count) {
        if (self.tourModel.tourIsRait == 0) {
            [self loadReviewView];
        }
    }
}
#pragma mark - ReviewDelegate
-(void)setTourRaitin:(NSInteger)raiting{
    self.tourModel.tourRaiting = raiting;
    self.tourModel.tourIsRait = 1;
}
#pragma mark - DownloadMapViewtDelegate
-(void)downloadCompleted{
    
}
@end
