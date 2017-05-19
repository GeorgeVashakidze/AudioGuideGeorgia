//
//  MapViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "MapViewController.h"
#import "CoreLocationManager.h"
#import "SightsViewController.h"
#import "SightsClickHelperView.h"
#import "SlideNavigationController.h"
#import "CustomAnnotationView.h"
#import "ToursDetailController.h"
#import "ServiceManager.h"
#import "SightBase.h"
#import "ToursModel.h"
#import "TourSightsView.h"
#import "SharedPreferenceManager.h"
#import "MMMaterialDesignSpinner.h"
#import "MyToursVC.h"
#import "Direction.h"

@interface MBXCustomCalloutAnnotation : MGLPointAnnotation
    @property (nonatomic, assign) BOOL anchoredToAnnotation;
    @property (nonatomic, assign) BOOL dismissesAutomatically;
    @end

@implementation MBXCustomCalloutAnnotation
    @end


@interface MapViewController ()<MGLMapViewDelegate,LocationManagerDelegate,GestureSwipeDownDelegate,ServicesManagerDelegate,DelegateForMapView,TourSightDelegate,DirectionDelegate>
    @property (nonatomic,strong) CoreLocationManager *managerLocation;
    @property (weak, nonatomic) IBOutlet UIProgressView *progressView;
    @property (weak, nonatomic) IBOutlet UIView *liveTourNavigatonbar;
    @property (weak, nonatomic) IBOutlet UIButton *myLocationBtn;
    @property (weak, nonatomic) IBOutlet UIButton *showSightBtn;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightDemoView;
    @property (weak, nonatomic) IBOutlet UILabel *liveTitle;
    @property (weak, nonatomic) IBOutlet UILabel *titleLbl;
    @property (weak, nonatomic) IBOutlet UIView *buyTourView;
    @property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *audioLoadIndicator;
    @property (weak, nonatomic) IBOutlet UIButton *autoPlayBtn;
    @property (strong,nonatomic) NSArray<SightModel*> *sights;
    @property (strong,nonatomic) NSArray<RestaurantsModel*> *restaurant;
    @property (weak, nonatomic) TourSightsView *sightsView;
    @property MBXCustomCalloutAnnotation *closeDirectionPoint;
    @property BOOL currentLocationIsSet;
    @property MGLPolyline *routeLine;
    @property CLLocation *currentLocation;
    @property (weak, nonatomic) IBOutlet UIView *sightViewSub;
    @property (weak, nonatomic) IBOutlet UIView *loaderView;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstreintSight;
    @property (strong,nonatomic) NSArray<ShopsModel*> *shops;
    @property (strong,nonatomic) SightModel *currentSelectedSight;
    @property (strong,nonatomic) NSArray<FestivalsModel*> *festivals;
    @property (strong,nonatomic) CustomAnnotationView *calloutView;
    @property (weak, nonatomic) IBOutlet UILabel *tourDemoPrice;
    @property NSMutableArray<NSDictionary *> *points;
    @property int selectedIndex;
    @property int unSelectedIndex;
    @property int lastGPSMatchedIndex;
    @property ServiceManager *manager;
    @property Direction *directionManager;
    @property BOOL isSelected;
    @property BOOL loadMApWithError;
    @property BOOL audioIsPlaying;
    @property BOOL isFirstLoadTour;
    @property CGFloat heplerViewY;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyDemoTourBottomConstraint;
    @property BOOL autoPlay;

    @property BOOL loadSights;
    @property BOOL loadRestaurants;
    @property BOOL loadEvents;
    @property BOOL loadShops;
    @end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioIsPlaying = NO;
    self.directionManager = [[Direction alloc] init];
    self.directionManager.delegateDirection = self;
    self.selectedIndex = -1;
    self.unSelectedIndex = -1;
    [self configureAutoPlay];
    [self startLocationMyPoint];
    self.topConstreintSight.constant = -148;
    if (self.needGPSCoordinates) {
        [self setMapToChoosenSights];
    }

    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;

    self.mapView.delegate = self;
    self.points = [[NSMutableArray alloc] init];

    self.mapView.showsUserLocation = YES;
    [self setCornerRadiusLocationBtn];
    [self loadHelperView];
    self.liveTourNavigatonbar.hidden = YES;
    if (self.tourModel) {
        self.titleLbl.text = self.tourModel.tourTitle;
        self.liveTitle.text = self.tourModel.tourTitle;
        [self loadSightsView];
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
        NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];

        if([self tourIslive] || self.tourModel.isDeleteTour == 1 || subscriberStr || [dicUserInfo[@"promotion"] integerValue] == 1){
            self.buyTourView.hidden = YES;
            self.liveTourNavigatonbar.hidden = NO;
            self.heightDemoView.constant = 37;
        }else{
            self.heightDemoView.constant = 60;
            self.buyTourView.hidden = NO;
        }
    }else{
        self.heightDemoView.constant = 0;
        self.buyTourView.hidden = YES;
    }
    [self setTourPrice];
}
-(BOOL)tourIslive{
    BOOL tourIslive = NO;
    if (self.tourModel.tourlive == 1 && self.tourModel.receptStr.length > 9) {
        tourIslive = YES;
    }else if(self.tourModel.tourlive == 1){
        NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
        if (userDic) {
            int countOfcheck = 0;
            for (int i = 0; i < self.tourModel.userTokens.count; i++) {
                NSString *userIDs = self.tourModel.userTokens[i];
                if ([userIDs isEqualToString:[userDic[@"id"] stringValue]]) {
                    tourIslive = YES;
                    break;
                }else{
                    countOfcheck += 1;
                }
            }
            if (countOfcheck == self.tourModel.userTokens.count) {
                tourIslive = NO;
            }
        }else{
            tourIslive = NO;
        }
    }
    return tourIslive;
}
-(void)setTourPrice{
    self.tourDemoPrice.text = [NSString stringWithFormat:@"Buy tour for %@$",self.currentTourPrice];
}
-(void)configureAutoPlay{
    NSDictionary *dic = [SharedPreferenceManager getPreferences];
    if (dic) {
        BOOL autoPlay = [dic[@"autoplayer"] boolValue];
        self.autoPlay = autoPlay;
        if (autoPlay) {
            [self.autoPlayBtn setTitle:@"Autoplay: on" forState:UIControlStateNormal];
        }else{
            [self.autoPlayBtn setTitle:@"Autoplay: off" forState:UIControlStateNormal];
        }
    }
}
-(void)loadSightsView{
    self.sightsView = [[[NSBundle mainBundle] loadNibNamed:@"TourSightsView" owner:self options:nil] objectAtIndex:0];
    self.sightsView.frame = CGRectMake(0, 0, SCREEN_WIDTH,185);
    self.sightsView.delegate = self;
    self.sightsView.dataSource = self.tourModel.sightTour;
    [self.sightsView reloadDataCollectionView];
    [self.sightViewSub addSubview:self.sightsView];
}
-(void)showSightViewHide:(BOOL)needHide{
    self.sightViewSub.hidden = NO;
    if(needHide){
        self.topConstreintSight.constant = -185;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }else{
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
        NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];

        if ([self tourIslive] || subscriberStr || [dicUserInfo[@"promotion"] integerValue] == 1 || self.tourModel.isDeleteTour == 1) {
            self.topConstreintSight.constant = 100;
        }else{
            self.topConstreintSight.constant = 125;
        }
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)loadTour{
    for (int i = 0; i < self.tourModel.sightTour.count; i++) {
        SightModel *sight = self.tourModel.sightTour[i];
        [self addPinstInMap:CLLocationCoordinate2DMake([sight.sightLat doubleValue], [sight.sightLng doubleValue]) withSight:sight withIndex:i];
    }

    [self drawRoutOnMap:self.tourModel.polyline];
    [self remoteNextTrack];
}
-(void)selectSightAuto{
    NSDictionary *dic = [self findDictionaryWithSightModel:self.modelSights];
    SightModel *model = self.modelSights;
    self.currentSelectedSight = model;
    if ([model isKindOfClass:[SightModel class]]) {
        //[self didSelectAnotation:dic withModel:model withIdenx:[dic[@"index"] intValue]];
        //[self mapView:self.mapView annotationCanShowCallout:dic[@"point"]];


        if (self.needGPSCoordinates) {
            [self setMapToChoosenSights];
            [self.mapView selectAnnotation:dic[@"point"] animated:YES];
        }



    }
}
-(void)setMapToChoosenSights{
    self.isFirstLoadTour = YES;
    [self.mapView setCenterCoordinate:self.sightChoosenCoordiantes
                            zoomLevel:18
                             animated:NO];
}
-(void)loadHelperView{
    self.pinHelperView = [[[NSBundle mainBundle] loadNibNamed:@"SightsClickHelperView" owner:self options:nil] objectAtIndex:0];
    self.pinHelperView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,SCREEN_HEIGHT);
    self.pinHelperView.swipeDelegate = self;
    [self.view addSubview:self.pinHelperView];
}
-(void)setCornerRadiusLocationBtn{
    self.myLocationBtn.layer.masksToBounds = YES;
    self.myLocationBtn.layer.cornerRadius = 5;
    self.buyTourView.layer.masksToBounds = YES;
    self.buyTourView.layer.cornerRadius = 5;
}

-(void)drawRoutOnMap:(NSArray *)pointArray{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"geojson"];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
    NSArray *feature = jsonDict[@"features"];
    NSDictionary *geomerty = feature[0][@"geometry"];
    NSArray *rawCoordinates = pointArray;
    NSUInteger coordinatesCount = rawCoordinates.count;
    CLLocationCoordinate2D coordinates[coordinatesCount];
    for (int index = 0; index< rawCoordinates.count; index++) {
        CLLocation *item = rawCoordinates[index];
        //        CLLocationDegrees lat = item.coordinate;
        //        CLLocationDegrees lng = [item[1] doubleValue];
        CLLocationCoordinate2D coordinateIner = item.coordinate;
        coordinates[index] = coordinateIner;
    }
    MGLPolyline *polyLine = [MGLPolyline polylineWithCoordinates:coordinates count:rawCoordinates.count];
    polyLine.title = @"Test my rout";
    [self.mapView addAnnotation:polyLine];
}
-(void)startLocationMyPoint{
    self.managerLocation = [[CoreLocationManager alloc] init];
    self.managerLocation.locationDelegate = self;
    self.managerLocation.forMapView = YES;
    [self.managerLocation startLocation];
}
-(void)addPinstInMap:(CLLocationCoordinate2D)coordinates withSight:(SightModel*)sight withIndex:(NSUInteger)index{
    MBXCustomCalloutAnnotation *point = [[MBXCustomCalloutAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
    point.title = @"To unlock  the audio please  purchase a tour";
    point.anchoredToAnnotation = YES;
    point.dismissesAutomatically = NO;

    NSString *anotationStr = @"";
    NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
    NSString *subscriberStr = [SharedPreferenceManager getSubscriber];

    if (sight.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![sight.baseReceptStr isEqualToString:@""] || subscriberStr) {
        anotationStr = [NSString stringWithFormat:@"unlocked_%lu",(unsigned long)index];
    }else{
        anotationStr = @"locked";
    }
    NSDictionary *dic = @{
                          @"point" : point,
                          @"sightModel" : sight,
                          @"anotation" : anotationStr,
                          @"index" :  [NSNumber numberWithInteger:index]
                          };
    [self.points addObject:dic];
    [self.mapView addAnnotation:point];
}
-(void)addOtherPinstInMap:(CLLocationCoordinate2D)coordinates withSight:(SightModel*)sight withIndex:(NSUInteger)index{
    MBXCustomCalloutAnnotation *point = [[MBXCustomCalloutAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
    point.title = sight.sightTitle;
    point.anchoredToAnnotation = YES;
    point.dismissesAutomatically = NO;
    NSDictionary *dic = @{
                          @"point" : point,
                          @"sightModel" : sight,
                          @"anotation" : @"unlocked",
                          @"index" :  [NSNumber numberWithInteger:-100]
                          };
    [self.points addObject:dic];
    [self.mapView addAnnotation:point];
}

#pragma mark - IBAction
- (IBAction)showMyLocation:(UIButton *)sender {
    [self.managerLocation startLocation];
}

- (IBAction)changeAutoPlay:(UIButton *)sender {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary: [SharedPreferenceManager getPreferences]];
    if (dic) {
        BOOL autoPlay = [dic[@"autoplayer"] boolValue];
        if (autoPlay) {
            [self.autoPlayBtn setTitle:@"Autoplay: off" forState:UIControlStateNormal];
            self.autoPlay = NO;
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"autoplayer"];
        }else{
            [self.autoPlayBtn setTitle:@"Autoplay: on" forState:UIControlStateNormal];
            self.autoPlay = YES;
            [dic setObject:[NSNumber numberWithBool:YES] forKey:@"autoplayer"];
        }
        [SharedPreferenceManager savePreferences:dic];
    }
}

- (IBAction)buyDemoTour:(UIButton *)sender {
    [self.delegateForBack buyDemoTour];
    [self.pinHelperView nullHysteriaPlayer];
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    self.currentSelectedSight.isSelected = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backTo:(UIButton *)sender {
    [self.pinHelperView nullHysteriaPlayer];
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    self.currentSelectedSight.isSelected = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)closeLiveTour:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TOUR" message:@"Do you want to quit the tour?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        [self.pinHelperView nullHysteriaPlayer];
        [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
        self.currentSelectedSight.isSelected = NO;
        [self.delegateForBack raitTour];
        [self.navigationController popViewControllerAnimated:YES];    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example

    }];
    [alert addAction:okAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)showSightsFromTop:(UIButton *)sender {
    if (self.topConstreintSight.constant < 0) {
        [self showSightViewHide:NO];
    }else{
        [self showSightViewHide:YES];
    }
}
- (IBAction)showSightBtnTaped:(UIButton *)sender {
    if (self.tourModel) {
        if (self.topConstreintSight.constant < 0) {
            [self showSightViewHide:NO];
        }else{
            [self showSightViewHide:YES];
        }
    }else{
        if (!self.needGPSCoordinates) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            SightsViewController *viewController = (SightsViewController *)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier:@"SightsViewController"];
            viewController.isFromMap = YES;
            viewController.forMapDelegate = self;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - MGLMapViewDelegate

- (UIView<MGLCalloutView> *)mapView:(__unused MGLMapView *)mapView calloutViewForAnnotation:(id<MGLAnnotation>)annotation
    {
        MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;
        NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
        SightModel *model = dic[@"sightModel"];
        self.calloutView = [[CustomAnnotationView alloc] init];
        self.calloutView.representedObject = annotation;
        self.calloutView.anchoredToAnnotation = pointAnotation.anchoredToAnnotation;
        self.calloutView.dismissesAutomatically = pointAnotation.dismissesAutomatically;
        self.calloutView.model = model;
        if ([model isKindOfClass:[SightModel class]]) {
            if (model.sightPrice == 0) {
                return self.calloutView;
            }
        }else{
            return self.calloutView;
        }
        return nil;
    }
- (void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation
    {
        MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;

        NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
        [mapView deselectAnnotation:annotation animated:YES];
        SightModel *model = dic[@"sightModel"];
        if ([model isKindOfClass:[SightModel class]]) {
            // Hide the callout
            NSArray *sightsTour = model.tours;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            if(sightsTour.count == 1){
                ToursDetailController *viewController = (ToursDetailController *)[mainStoryboard
                                                                                  instantiateViewControllerWithIdentifier:@"ToursDetailController"];
                viewController.tourID = model.tours[0].toursID;
                viewController.infoType = unknown;
                [self.navigationController pushViewController:viewController animated:YES];
            }else if(sightsTour.count > 1){
                MyToursVC *viewController = (MyToursVC *)[mainStoryboard
                                                          instantiateViewControllerWithIdentifier:@"MyToursVC"];
                viewController.filterToursArray = sightsTour;
                viewController.isFromMenu = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }

        }else{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            ToursDetailController *viewController = (ToursDetailController *)[mainStoryboard
                                                                              instantiateViewControllerWithIdentifier:@"ToursDetailController"];
            viewController.tourID = model.sightID;
            viewController.infoType = unknown;
            if ([model isKindOfClass:[RestaurantsModel class]]) {
                viewController.restModel = model;
                viewController.infoType = restaurants;
            }else if ([model isKindOfClass:[ShopsModel class]]){
                viewController.shopModel = model;
                viewController.infoType = shops;
            }else if ([model isKindOfClass:[FestivalsModel class]]){
                viewController.festivalModel = model;
                viewController.infoType = festivals;
            }
            viewController.isFormInfo = YES;
            viewController.isFromMapTapped = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }

    }
-(BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation{

    if (annotation == self.closeDirectionPoint) {
        return NO;
    }

    MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;
    NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
    SightModel *model = dic[@"sightModel"];
    if ([model isKindOfClass:[SightModel class]]) {
        if (model.sightPrice == 0) {
            if (self.tourModel) {
                return NO;
            }
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}
-(void) initService {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if (self.manager == nil) {
            self.manager = [[ServiceManager alloc] init];
            self.manager.delegate = self;
        }

        [self.manager getSights];

    });
}
-(void)loadDataOnMap{

    if (self.tourModel) {
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
        NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];

        if([self tourIslive] || self.tourModel.isDeleteTour == 1 || subscriberStr || [dicUserInfo[@"promotion"] integerValue] == 1){
            self.heightDemoView.constant = 37;
            self.buyTourView.hidden = YES;
        }else{
            self.heightDemoView.constant = 60;
            self.buyTourView.hidden = NO;
        }
        [self loadTour];
    }else{
        self.heightDemoView.constant = 0;
        [self initService];
        if (_needGPSCoordinates) {
            [self selectSightAuto];
        }
    }

}

-(void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style{

}
-(void)mapViewDidFailLoadingMap:(MGLMapView *)mapView withError:(NSError *)error{
    if (!self.loadMApWithError) {
        self.loadMApWithError = YES;
        [self loadDataOnMap];
    }
}
- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    if (!self.loadMApWithError) {
        [self loadDataOnMap];
    }
}
-(void)unselectSeelctedPin{
    NSDictionary *dic = nil;
    if (self.unSelectedIndex == -1) {
        dic = [self findDictionaryWithIndex:self.selectedIndex-1];
    }else{
        dic = [self findDictionaryWithIndex:self.unSelectedIndex-1];
    }

    SightModel *model = dic[@"sightModel"];
    NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
    if ([model isKindOfClass:[SightModel class]]) {
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
        if (self.tourModel && (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr)) {
            self.selectedIndex = -1;
            self.unSelectedIndex = -1;
            MBXCustomCalloutAnnotation *selectedPoint = dic[@"point"];
            [self.mapView removeAnnotation:selectedPoint];
            [self.points removeObject:dic];
            MBXCustomCalloutAnnotation *point = [[MBXCustomCalloutAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
            point.title = @"To unlock  the audio please  purchase a tour";
            point.anchoredToAnnotation = YES;
            point.dismissesAutomatically = NO;
            NSDictionary *newDic = @{
                                     @"point" : point,
                                     @"sightModel" : model,
                                     @"anotation" : @"dddddddddddddd",
                                     @"index" :  dic[@"index"]
                                     };
            [self.points addObject:newDic];
            [self.mapView addAnnotation:point];
            self.isSelected = NO;
            self.currentSelectedSight.isSelected = NO;
        }

        if (self.tourModel == nil && (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr)) {
            self.selectedIndex = -1;
            self.unSelectedIndex = -1;
            MGLAnnotationImage *annotationImage = [self.mapView dequeueReusableAnnotationImageWithIdentifier:dic[@"anotation"]];
            annotationImage.image = [UIImage imageNamed:@"enableMapPin"];
            MBXCustomCalloutAnnotation *selectedPoint = dic[@"point"];
            [self.mapView removeAnnotation:selectedPoint];
            [self.points removeObject:dic];

            MBXCustomCalloutAnnotation *point = [[MBXCustomCalloutAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
            point.title = @"Tor";
            point.anchoredToAnnotation = YES;
            point.dismissesAutomatically = NO;
            model.isSelected = NO;
            NSDictionary *newDic = @{
                                     @"point" : point,
                                     @"sightModel" : model,
                                     @"anotation" : dic[@"anotation"],
                                     @"index" :  dic[@"index"]
                                     };
            [self.points addObject:newDic];
            [self.mapView addAnnotation:point];
            self.isSelected = NO;
            self.currentSelectedSight.isSelected = NO;
        }
    }

}
-(void)adjustMapOnSelectAnotation:(SightModel *)model{
    if ([model isKindOfClass:[SightModel class]]) {
        CLLocationCoordinate2D selectCoordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue]-0.001, [model.sightLng doubleValue]);
        if (self.mapView.zoomLevel >= 16) {
            selectCoordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue]-0.0001, [model.sightLng doubleValue]);
            if (self.mapView.zoomLevel >= 18) {
                selectCoordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue]-0.00001, [model.sightLng doubleValue]);
            }
        }
        [self.mapView setCenterCoordinate:selectCoordinate
                                 animated:YES];

    }else if(model){
        CLLocationCoordinate2D selectCoordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
        [self.mapView setCenterCoordinate:selectCoordinate
                                 animated:YES];
    }
}
-(void)didSelectAnotation:(NSDictionary*)dic withModel:(SightModel*)model withIdenx:(int)selectedIndex{
    int index = [dic[@"index"] intValue] + 1;
    NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
    NSString *subscriberStr = [SharedPreferenceManager getSubscriber];

    if(model.isSelected && !self.isSelected){
        self.currentSelectedSight.isSelected = NO;
        [self hidePinHelperView];
    }else{
        self.currentSelectedSight.isSelected = YES;
        self.pinHelperView.needPlayer = YES;
        self.pinHelperView.selectedIndex = selectedIndex;
        self.pinHelperView.isliveTour = [self tourIslive];
        [self showPinHelperView:model withHanlde:^{
            [self.pinHelperView showView];
            if (self.isFirstLoadTour && ([self tourIslive] || model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr)) {
                self.isFirstLoadTour = NO;
                [self.pinHelperView playAuto];
            }else{
                if (self.autoPlay && ([self tourIslive] || model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr)) {
                    [self.pinHelperView playAuto];
                }
            }
        }];
    }
    if (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr) {
        if (self.isSelected) {
            [self unselectSeelctedPin];
        }
        self.isSelected = NO;
        MGLPointAnnotation *point = dic[@"point"];
        self.selectedIndex = index;

        MGLAnnotationImage *annotationImage = [self.mapView dequeueReusableAnnotationImageWithIdentifier:dic[@"anotation"]];
        annotationImage.image = [UIImage imageNamed:@"selectedPinTour"];
        [self.mapView removeAnnotation:point];
        [self.points removeObject:dic];
        MBXCustomCalloutAnnotation *selectedPoint = [[MBXCustomCalloutAnnotation alloc] init];
        selectedPoint.coordinate = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
        selectedPoint.title = @"To unlock  the audio please  purchase a tour";
        selectedPoint.anchoredToAnnotation = YES;
        selectedPoint.dismissesAutomatically = NO;
        model.isSelected = YES;
        NSDictionary *newDic = @{
                                 @"point" : selectedPoint,
                                 @"sightModel" : model,
                                 @"anotation" : dic[@"anotation"],
                                 @"index" :  [NSNumber numberWithInteger:index-1]
                                 };
        [self.points addObject:newDic];
        [self.mapView addAnnotation:selectedPoint];
        self.isSelected = YES;
    }
    [self adjustMapOnSelectAnotation:model];
}
-(void)mapView:(MGLMapView *)mapView didSelectAnnotation:(id<MGLAnnotation>)annotation{

    if (annotation == _closeDirectionPoint) {
        [_mapView removeAnnotation:_routeLine];
        [_mapView removeAnnotation:_closeDirectionPoint];
        _routeLine = nil;
        _closeDirectionPoint = nil;
    }

    MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;
    NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
    SightModel *model = dic[@"sightModel"];

    if ([model isKindOfClass:[SightModel class]]) {
        if(self.currentSelectedSight){
            if (self.currentSelectedSight == model) {
                if(model.isSelected){
                    [self hidePinHelperView];
                    return;
                }
            }
        }
        self.currentSelectedSight = model;
        [self didSelectAnotation:dic withModel:model withIdenx:[dic[@"index"] intValue]];
    }else{
        [self adjustMapOnSelectAnotation:model];
    }
    [self deactivateNextBtn];
}
-(void)mapView:(MGLMapView *)mapView didDeselectAnnotation:(id<MGLAnnotation>)annotation{
    MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;
    NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
    SightModel *model = dic[@"sightModel"];
    if ([model isKindOfClass:[SightModel class]]) {
        model.isSelected = NO;
    }
    if (self.isSelected && self.tourModel) {
        [self hidePinHelperView];
        [self.pinHelperView hideView];
    }
    //    if (self.tourModel) {
    //        self.selectedIndex = -1;
    //        [self.mapView addAnnotation:annotation];
    //    }
}

-(MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id<MGLAnnotation>)annotation{

    if (annotation == self.closeDirectionPoint) {
        MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"close"];
        UIImage *image = [UIImage imageNamed:@"closeDirection"];
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"close"];

        return annotationImage;
    }
    // Try to reuse the existing ‘pisa’ annotation image, if it exists.
    MBXCustomCalloutAnnotation *pointAnotation = (MBXCustomCalloutAnnotation*)annotation;
    NSDictionary *dic = [self findDictionaryWithValueForKey:pointAnotation];
    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:dic[@"anotation"]];
    SightModel *model = dic[@"sightModel"];
    if ([model isKindOfClass:[SightModel class]]) {
        UIImage *image = nil;
        NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];

        if (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr) {
            if (model.isSelected) {
                image = [UIImage imageNamed:@"selectedPinTour"];
            }else{
                image = [UIImage imageNamed:@"enableMapPin"];
            }
        }else{
            image = [UIImage imageNamed:@"lockMapPin"];
        }
        // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:dic[@"anotation"]];

        if (self.tourModel) {
            NSUInteger index = [dic[@"index"] integerValue] + 1;
            NSString *imageStr = [NSString stringWithFormat:@"sightOnDemo_%lu",(unsigned long)index];
            if (model.sightIsPass == 1) {
                imageStr = [NSString stringWithFormat:@"passSightIcon_%lu",(unsigned long)index];
            }
            annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:imageStr];
            if (annotationImage) {
                if (self.selectedIndex == -1) {
                    return annotationImage;
                }
            }
            UIImage *image = nil;

            if (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1|| ![model.baseReceptStr isEqualToString:@""] || subscriberStr) {
                if (self.tourModel) {
                    NSUInteger index = [dic[@"index"] integerValue] + 1;
                    NSString *imageStr = [NSString stringWithFormat:@"sightOnDemo_%lu",(unsigned long)index];
                    if (model.sightIsPass == 1) {
                        imageStr = [NSString stringWithFormat:@"passSightIcon_%lu",(unsigned long)index];
                    }
                    image = [UIImage imageNamed:imageStr];
                }
            }else{
                if(self.tourModel){
                    image = [UIImage imageNamed:@"lockedSightOnDemo"];
                }
            }
            if (index == self.selectedIndex) {
                image = [UIImage imageNamed:@"selectedPinTour"];
                imageStr = @"selectedPinTour";
            }
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:imageStr];
        }
    }else if([model isKindOfClass:[RestaurantsModel class]]){
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"restaurant"];
        NSString *kinde = ((RestaurantsModel*)model).restKind;
        if ([kinde isEqualToString:@"1"]) {
            annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"restaurantBar"];
        }
        if (!annotationImage) {
            UIImage *image = [UIImage imageNamed:@"restourantPin"];
            if ([kinde isEqualToString:@"1"]) {
                image = [UIImage imageNamed:@"winePin"];
            }
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"restaurant"];
            if ([kinde isEqualToString:@"1"]) {
                annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"restaurantBar"];
            }
        }

    }else if([model isKindOfClass:[ShopsModel class]]){
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"shop"];
        if (!annotationImage) {
            UIImage *image = [UIImage imageNamed:@"shopPin"];
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"shop"];
        }

    }else if([model isKindOfClass:[FestivalsModel class]]){
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"festivals"];
        if (!annotationImage) {
            UIImage *image = [UIImage imageNamed:@"ticketPin"];
            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"festivals"];
        }

    }
    return annotationImage;
}
- (NSDictionary *)findDictionaryWithSightModel:(SightModel*)model {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;

    [self.points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        SightModel *index = [dict valueForKey:@"sightModel"];
        if (model.sightID == index.sightID) {
            found = YES;
            *stop = YES;
        }
    }];

    if (found) {
        return dict;
    } else {
        return nil;
    }
}
- (NSDictionary *)findDictionaryWithIndex:(int)pointIndex {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;

    [self.points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        NSNumber *index = [dict valueForKey:@"index"];
        if (pointIndex == [index intValue]) {
            found = YES;
            *stop = YES;
        }
    }];

    if (found) {
        return dict;
    } else {
        return nil;
    }
}
- (NSDictionary *)findDictionaryWithValueForKey:(MGLPointAnnotation *)point {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;

    [self.points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        MGLPointAnnotation *title = [dict valueForKey:@"point"];
        if (title == point) {
            found = YES;
            *stop = YES;
        }
    }];

    if (found) {
        return dict;
    } else {
        return nil;
    }

}
#pragma mark - LocationManagerDelegate
-(void)getCurrentLocation:(CLLocation *)location{
    self.currentLocation = location;
    if(!_currentLocationIsSet){
        _currentLocationIsSet = YES;
        [self.mapView setCenterCoordinate:location.coordinate
                                zoomLevel:16
                                 animated:YES];
    }

    NSArray * coords = [self getNearestSightIndex];

    if (coords.count == 0) { return; }

    int index = [coords[0] intValue];
    double metres = [coords[1] doubleValue];

    //Need 50 meter not 0
    if (metres <= 50 && self.lastGPSMatchedIndex != index) {

        self.lastGPSMatchedIndex = index;
        //Play
        NSDictionary * dic = [self.points objectAtIndex:index];
        SightModel *model = (SightModel *)dic[@"sightModel"];
        NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
        if (self.tourModel && (model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![model.baseReceptStr isEqualToString:@""] || subscriberStr) && self.audioIsPlaying) {
            [self didSelectAnotation:dic withModel:model withIdenx:index];
        }
    }
}
-(NSArray *) getNearestSightIndex {
    int index = 0;

    if (self.points == nil || self.points.count == 0) { return @[]; }

    SightModel *sight = (SightModel *)[self.points objectAtIndex:0][@"sightModel"];

    CLLocationCoordinate2D firstLoc = CLLocationCoordinate2DMake([sight.sightLat doubleValue], [sight.sightLng doubleValue]);

    double nearest = [self metresBetweenPlace1And:firstLoc];

    for (int i = 1; i < self.points.count; i++) {

        SightModel *model = (SightModel *)[self.points objectAtIndex:i][@"sightModel"];

        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);

        double nearestLoc = [self metresBetweenPlace1And:loc];

        if (nearestLoc < nearest) {
            nearest = nearestLoc;
            index = i;
        }

    }

    return @[[NSNumber numberWithInteger:index], [NSNumber numberWithDouble:nearest]];
}

-(double) metresBetweenPlace1And :(CLLocationCoordinate2D) place2
    {
        CLLocation *poiLoc = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
        return [self.currentLocation distanceFromLocation:poiLoc];
    }

-(void)getCurrentCity:(NSString *)city{

}

- (void)dealloc {
    // Remove offline pack observers.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Animation pin view
-(void)showPinHelperViewFull{
    __block typeof(self) blockSelf = self;
    [self.pinHelperView sightPosterShow:nil withHanlde:^{

    }];
    [UIView animateWithDuration:0.35 animations:^{
        blockSelf.pinHelperView.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20);
    }];
}
-(void)animateBuydemoTourView:(BOOL)upAnimation{
    if (upAnimation) {
        self.buyDemoTourBottomConstraint.constant = 120;
    }else{
        self.buyDemoTourBottomConstraint.constant = 15;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)showPinHelperView:(SightModel*)sightModel withHanlde:(void (^)())handler{
    __block typeof(self) blockSelf = self;
    if (self.tourModel) {
        self.pinHelperView.isFromTour = YES;
    }else{
        self.pinHelperView.isFromTour = NO;
    }
    [self.pinHelperView sightPosterShow:sightModel withHanlde:^{
        handler();
    }];
    [UIView animateWithDuration:0.35 animations:^{
        blockSelf.pinHelperView.frame = CGRectMake(0, SCREEN_HEIGHT-heightShowHelperView, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}
-(void)hidePinHelperView{
    self.audioIsPlaying = NO;
    [self animateBuydemoTourView:NO];
    [self.calloutView dismissCalloutAnimated:YES];
    [self unselectSeelctedPin];
    [self.pinHelperView hideView];
    __block typeof(self) blockSelf = self;

    [UIView animateWithDuration:0.35 animations:^{
        blockSelf.pinHelperView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}
-(void)hidePinHelperViewWhenPlaying{
    [self animateBuydemoTourView:YES];
    __block typeof(self) blockSelf = self;

    [UIView animateWithDuration:0.35 animations:^{
        blockSelf.pinHelperView.frame = CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}
#pragma mark - PolyLine Draw Delegate

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation {
    // Set the alpha for all shape annotations to 1 (full opacity)
    return 1.0f;
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation {
    // Set the line width for polyline annotations
    return 6.0f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation {
    // Set the stroke color for shape annotations
    // ... but give our polyline a unique color by checking for its `title` property
    if (annotation == self.routeLine) {
        return [UIColor colorWithRed:254.0f/255.0f green:63.0f/255.0f blue:131.0f/255.0f alpha:1.0f];
    }
    return [UIColor colorWithRed:61.0f/255.0f green:56.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
}

#pragma mark - GestureSwipeDownDelegate

-(void)swipeDown:(CGFloat)currentPointY withPlaying:(BOOL)playing{
    if (playing && false) {

    }else{
        if(currentPointY > 0){
            CGRect tempRect = self.pinHelperView.frame;
            tempRect.origin.y += currentPointY;
            self.pinHelperView.frame = tempRect;
        }else{
            if (self.pinHelperView.frame.origin.y > 20) {
                CGRect tempRect = self.pinHelperView.frame;
                tempRect.origin.y += currentPointY;
                self.pinHelperView.frame = tempRect;
            }
        }
    }
}
-(void)startSwipe{
    self.heplerViewY = self.pinHelperView.frame.origin.y;
}
-(void)swipeEnd:(CGFloat)currentPointY withPlaying:(BOOL)playing{
    if (playing) {
        if (self.pinHelperView.frame.origin.y > SCREEN_HEIGHT - heightShowHelperView + 30) {
            if (self.pinHelperView.frame.origin.y > SCREEN_HEIGHT - 100) {
                [self hidePinHelperView];
                [self.pinHelperView fullVersionPlayer];
            }else{
                if (self.pinHelperView.frame.origin.y > self.heplerViewY) {
                    [self hidePinHelperViewWhenPlaying];
                    [self.pinHelperView showSmallPlayer];
                }else{
                    [self showPinHelperView:nil withHanlde:^{

                    }];
                    [self.pinHelperView fullVersionPlayer];
                }
            }
        }else{
            [self.pinHelperView fullVersionPlayer];
            if (self.pinHelperView.frame.origin.y < self.heplerViewY) {
                [self showPinHelperViewFull];
            }else{
                [self showPinHelperView:nil withHanlde:^{

                }];
            }
        }
    }else{
        if (self.pinHelperView.frame.origin.y > SCREEN_HEIGHT - heightShowHelperView + 30) {
            [self hidePinHelperView];
        }else{
            if (self.pinHelperView.frame.origin.y < self.heplerViewY) {
                [self showPinHelperViewFull];
            }else{
                [self showPinHelperView:nil withHanlde:^{

                }];
            }
        }
    }
}
-(void)prevTrack{
    if (self.selectedIndex - 2 >= 0) {
        SightModel *model = self.tourModel.sightTour[self.selectedIndex-2];
        NSDictionary *dic = [self findDictionaryWithIndex:self.selectedIndex-2];
        self.currentSelectedSight = model;
        [self didSelectAnotation:dic withModel:model withIdenx:self.selectedIndex-2];
    }
    [self deactivateNextBtn];

}
-(void)remoteNextTrack{
    if (self.tourModel.sightTour.count > self.selectedIndex) {
        SightModel *model = self.tourModel.sightTour[self.selectedIndex];
        NSDictionary *dic = [self findDictionaryWithIndex:self.selectedIndex];
        self.currentSelectedSight = model;
        [self didSelectAnotation:dic withModel:model withIdenx:self.selectedIndex];
    }
    if (self.selectedIndex == -1) {
        SightModel *model = self.tourModel.sightTour[0];
        NSDictionary *dic = [self findDictionaryWithIndex:0];
        self.currentSelectedSight = model;

        [self didSelectAnotation:dic withModel:model withIdenx:0];
    }
    [self deactivateNextBtn];

}
-(void)nextTreck{
    if (self.tourModel.sightTour.count > self.selectedIndex) {
        SightModel *model = self.tourModel.sightTour[self.selectedIndex];
        NSDictionary *dic = [self findDictionaryWithIndex:self.selectedIndex];
        self.currentSelectedSight = model;
        [self didSelectAnotation:dic withModel:model withIdenx:self.selectedIndex];
    }
    [self deactivateNextBtn];
}
-(void)deactivateNextBtn{
    if (self.tourModel.sightTour.count > self.selectedIndex) {
        [self.pinHelperView deactivateNextBtn:YES];
    }else{
        [self.pinHelperView deactivateNextBtn:NO];
    }
}
-(void)errorLoadAudio{
    [self.view bringSubviewToFront:self.loaderView];
    self.loaderView.hidden = YES;
    [self.audioLoadIndicator stopAnimating];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:@"Error, playing audio stream"
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];

    //Add your buttons to alert controller

    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)getDirection{
    if (self.routeLine == nil) {
        [self hidePinHelperView];
        CLLocationCoordinate2D aPoint = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        CLLocationCoordinate2D bPoint = CLLocationCoordinate2DMake([self.currentSelectedSight.sightLat doubleValue], [self.currentSelectedSight.sightLng doubleValue]);
        [self.directionManager getDirection:aPoint and:bPoint];
    }
}
-(void)loadAudio{
    self.audioIsPlaying = YES;
    [self.view bringSubviewToFront:self.loaderView];
    self.loaderView.hidden = YES;
    [self.audioLoadIndicator stopAnimating];
}
-(void)playerReachEnd{
    if (self.tourModel) {
        NSString *subscriberStr = [SharedPreferenceManager getSubscriber];

        if ([self tourIslive] || subscriberStr) {
            self.currentSelectedSight.sightIsPass = 1;
            [self.manager updateSigtToPass:[self.currentSelectedSight.sightID intValue]];
        }
    }
    [self hidePinHelperView];
}
-(void)startPlay{
    [self.view bringSubviewToFront:self.loaderView];
    self.loaderView.hidden = NO;
    [self.audioLoadIndicator startAnimating];
}
#pragma mark - ServicesManagerDelegate

-(void)getSights:(NSArray<SightModel *> *)sights{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (!self.loadSights) {
            self.loadSights = YES;
            self.sights = sights;
            for (int i = 0; i < sights.count; i++) {
                SightModel *model = self.sights[i];
                CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
                [self addPinstInMap:coordinates withSight:model withIndex:i];
            }
        }
    });
    [self.manager getRestaurants];
}
-(void)errorGetSights:(NSError *)error{
    [self.manager getRestaurants];
}

-(void)getShops:(NSArray<ShopsModel *> *)shops{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if(!self.loadShops){
            self.loadShops = YES;
            self.shops = shops;
            for (int i = 0; i < self.shops.count; i++) {
                ShopsModel *model = self.shops[i];
                CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
                [self addOtherPinstInMap:coordinates withSight:model withIndex:i];
            }
        }
    });
}
-(void)errorgetShop:(NSError *)error{

}

-(void)getFestivals:(NSArray<FestivalsModel *> *)festivals{
    [self.manager getShops];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (!self.loadEvents) {
            self.loadEvents = YES;
            self.festivals = festivals;
            for (int i = 0; i < self.festivals.count; i++) {
                FestivalsModel *model = self.festivals[i];
                CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
                [self addOtherPinstInMap:coordinates withSight:model withIndex:i];
            }
        }
    });
}
-(void)errorgetFestivals:(NSError *)error{
    [self.manager getShops];
}

-(void)getRestaurant:(NSArray<RestaurantsModel *> *)restaurants{
    [self.manager getFestivals];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (!self.loadRestaurants) {
            self.loadRestaurants = YES;
            self.restaurant = restaurants;
            for (int i = 0; i < self.restaurant.count; i++) {
                RestaurantsModel *model = self.restaurant[i];
                CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
                [self addOtherPinstInMap:coordinates withSight:model withIndex:i];
            }
        }
    });
}
-(void)errorgetRestaurants:(NSError *)error{
    [self.manager getFestivals];
}

-(void)selectObject:(CLLocationCoordinate2D)coordinates{
    self.sightChoosenCoordiantes = coordinates;
    [self setMapToChoosenSights];
}
#pragma mark - TourSightDelegate

-(void)clickeSight:(NSInteger)index{
    [self showSightViewHide:YES];
    self.unSelectedIndex = self.selectedIndex;
    if(index == 0){
        self.selectedIndex = 2;
        [self prevTrack];
    }else{
        self.selectedIndex = (int)index;
        [self remoteNextTrack];
    }
}

#pragma mark - DirectionDelegat
-(void)getDirection:(MBRoute *)route{
    if (route.coordinateCount) {
        self.closeDirectionPoint = [[MBXCustomCalloutAnnotation alloc] init];

        // Convert the route’s coordinates into a polyline.
        CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
        [route getCoordinates:routeCoordinates];

        CLLocationCoordinate2D coordinates = routeCoordinates[route.coordinateCount/2];
        _closeDirectionPoint.coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        _closeDirectionPoint.title = @"To unlock  the audio please  purchase a tour";
        _closeDirectionPoint.anchoredToAnnotation = YES;
        _closeDirectionPoint.dismissesAutomatically = NO;
        [_mapView addAnnotation:_closeDirectionPoint];
        self.routeLine = [MGLPolyline polylineWithCoordinates:routeCoordinates count:route.coordinateCount];
        
        // Add the polyline to the map and fit the viewport to the polyline.
        [_mapView addAnnotation:self.routeLine];
        [_mapView setVisibleCoordinates:routeCoordinates count:route.coordinateCount edgePadding:UIEdgeInsetsZero animated:YES];
        
        // Make sure to free this array to avoid leaking memory.
        free(routeCoordinates);
    }
}
    @end
