//
//  SightsViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "SightsViewController.h"
#import "SightsCustomItem.h"
#import "SightsHeaderView.h"
#import "MapViewController.h"
#import "ServiceManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CoreLocationManager.h"

@interface SightsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ServicesManagerDelegate,FilterDelegate,LocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *sightsCollectionView;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loadIndicator;
@property NSArray<SightModel*> *sightsArray;
@property NSArray<SightModel*> *filterSightsArray;
@property ServiceManager *manager;
@property (weak,nonatomic) SightsHeaderView *headerView;
@property (strong, nonatomic) CoreLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * currentLocation;

@end

@implementation SightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadHeaderView];
    [self buildService];
    self.locationManager = [[CoreLocationManager alloc] init];
    self.locationManager.locationDelegate = self;
    [self.locationManager startLocation];
}

-(void)buildService{
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    [self.manager getSights];
}

-(NSMutableArray<SightModel*>*) sortByDistance :(NSMutableArray<SightModel*>*) arr {
    if (self.currentLocation != nil && arr != nil) {
        for (SightModel *obj in arr) {
            CLLocationDegrees lat = [obj.sightLat doubleValue];
            CLLocationDegrees lng = [obj.sightLng doubleValue];
            
            CLLocation *houseLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            CLLocationDistance meters = [houseLocation distanceFromLocation:_currentLocation];
            obj.currentDistance = @(meters);
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"currentDistance" ascending:YES];
        [arr sortUsingDescriptors:@[sort]];
    }
    return arr;
}

#pragma mark - Load Header View

-(void)loadHeaderView{
    CGFloat heightFilter = 279.0;
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"SightsHeaderView" owner:self options:nil] objectAtIndex:0];
    self.headerView.isFromTours = NO;
    self.headerView.currentCity = self.currentCity;
    self.headerView.filterDelegate = self;
    self.headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, heightFilter);
    [self.headerView setDefaultButtons];
    [self.headerView buildService];
    [self.sightsCollectionView addSubview:self.headerView];
}

#pragma mark - CollectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filterSightsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SightsCustomItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"SightsCustomItem" forIndexPath:indexPath];
    SightModel *model = self.filterSightsArray[indexPath.item];
    item.sightTitle.text = model.sightTitle;
    NSString *imgUrl = model.imagesFirst;
    if (model.imagesArray.count > 0) {
        imgUrl = model.imagesArray[0];
    }
    [item.imageLoader startAnimating];
    [item.sightPoster sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [item.imageLoader stopAnimating];
    }];
    return item;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE5) {
        return CGSizeMake(149, 135);
    }
        return CGSizeMake(176, 145);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 7, 0, 7);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SightModel *model = self.filterSightsArray[indexPath.item];
    if (self.isFromMap) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
        [self.forMapDelegate selectObject:location];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        MapViewController *viewController = (MapViewController *)[mainStoryboard
                                                                  instantiateViewControllerWithIdentifier:@"MapViewController"];
        //initWithLatitude:41.7123093 longitude:44.7801688
        viewController.needGPSCoordinates = YES;
        viewController.modelSights = model;
        viewController.sightChoosenCoordiantes = CLLocationCoordinate2DMake([model.sightLat doubleValue], [model.sightLng doubleValue]);
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ServicesManagerDelegate

-(void)getSights:(NSArray<SightModel *> *)sights{
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
    self.sightsArray = sights;
    self.filterSightsArray = sights;
    _filterSightsArray = [_filterSightsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = ((SightModel*)a).cityID;
        NSNumber *second = ((SightModel*)b).cityID;
        
        if([self.currentCity.cityID intValue] == [first intValue] && [self.currentCity.cityID  intValue] != [second intValue]){
            return NSOrderedAscending;
        }else if([self.currentCity.cityID intValue] != [first intValue] && [self.currentCity.cityID  intValue] == [second intValue]){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    [self.sightsCollectionView reloadData];
    [self.manager getTours];
}

-(void)errorGetSights:(NSError *)error{
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
}

-(void)getTours:(NSArray<ToursModel *> *)tours{
    
}

-(void)errorGetTours:(NSError *)error{
    
}

#pragma mark - FilterDelegate
-(void)changeHeightOfHeader:(CGFloat)heightHeader{
//    self.headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, heightHeader);
    [self.sightsCollectionView reloadData];
}
-(void)chooseFilter:(NSArray *)filterID withMustSee:(BOOL)mustSee withNear:(BOOL)nearMee{
    if (mustSee) {
        if (filterID.count == 0) {
            self.filterSightsArray = self.sightsArray;
            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
            self.filterSightsArray = [self.sightsArray filteredArrayUsingPredicate:mustSeePredicate];
        }else{
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",filterID];
            
            self.filterSightsArray = [self.sightsArray filteredArrayUsingPredicate:predicate];
            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
            self.filterSightsArray = [self.filterSightsArray filteredArrayUsingPredicate:mustSeePredicate];
        }
        
        if (nearMee) {
//            NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
//            self.filterSightsArray = [self.filterSightsArray filteredArrayUsingPredicate:predicateCity];
            self.filterSightsArray = [self sortByDistance: _filterSightsArray.mutableCopy];
        }
        
    }else{
        if (nearMee) {
            if (filterID.count == 0) {
//                 NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
//                    self.filterSightsArray = [self.sightsArray filteredArrayUsingPredicate:predicateCity];
                self.filterSightsArray = [self sortByDistance: self.sightsArray.mutableCopy];

            }else{
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",filterID];
                
                self.filterSightsArray = [self.sightsArray filteredArrayUsingPredicate:predicate];
//                NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
//                self.filterSightsArray = [self.filterSightsArray filteredArrayUsingPredicate:predicateCity];
                self.filterSightsArray = [self sortByDistance: self.filterSightsArray.mutableCopy];

            }
        }else{
            if (filterID.count == 0) {
                self.filterSightsArray = self.sightsArray;
            }else{
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",filterID];
                
                self.filterSightsArray = [self.sightsArray filteredArrayUsingPredicate:predicate];
            }
        }
        if (mustSee) {
            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
            self.filterSightsArray = [self.filterSightsArray filteredArrayUsingPredicate:mustSeePredicate];
        }

    }
    [self.sightsCollectionView reloadData];
}
-(void)getCurrentCity:(NSString *)city{
    
}

-(void)getCurrentLocation:(CLLocation *)location {
    if (self.currentLocation == nil) {
        self.currentLocation = location;
    }
}
@end
