//
//  MyToursVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "MyToursVC.h"
#import "MyToursCustomCell.h"
#import "ToursDetailController.h"
#import "SlideNavigationController.h"
#import "ServiceManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FilterViewController.h"
#import "LocalizableLabel.h"
#import "MMMaterialDesignSpinner.h"
#import "SharedPreferenceManager.h"

@interface MyToursVC ()<UITableViewDelegate,UITableViewDataSource,ServicesManagerDelegate,FilterTourDelegate>
@property (weak, nonatomic) IBOutlet UIView *emptyTourView;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet LocalizableLabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UITableView *toursTableView;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderIndicator;
@property (weak, nonatomic) IBOutlet LocalizableLabel *emptyDescriptionLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *emptyLbl;
@property NSArray<ToursModel*> *toursArray;
@property NSArray *filterIDS;
@property ServiceManager *manager;
@property BOOL isSelectedFirst;
@property BOOL isSelectedSecond;
@property CGFloat toursTotalPrice;
@property CGFloat saveCurrentFilterPrice;
@property NSString *tourhours;
@property NSString *toursightsnumber;
@property NSString *tourdistanse;
@end

@implementation MyToursVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toursTotalPrice = 0.0f;
    self.saveCurrentFilterPrice = 0.0f;
    // Do any additional setup after loading the view.
    [self confgureController];
    if (self.filterToursArray == nil) {
        [self buildServiceManager];
    }
    [self setLocalizable];
}

-(void) fetchTours {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self.manager getTours];

    });
}

-(void)viewDidAppear:(BOOL)animated {
    [self fetchTours];
}

-(void)filterTour{
    _filterToursArray = [_filterToursArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = ((ToursModel*)a).cityID;
        NSNumber *second = ((ToursModel*)b).cityID;
        int firstPopular = ((ToursModel*)a).isPopupar;
        int secondPopular = ((ToursModel*)b).isPopupar;
        
        if([self.currentCity.cityID intValue] == [first intValue] && [self.currentCity.cityID  intValue] != [second intValue]){
            return NSOrderedAscending;
        }else if([self.currentCity.cityID intValue] != [first intValue] && [self.currentCity.cityID  intValue] == [second intValue]){
            return NSOrderedDescending;
        }
        if (firstPopular == 1 && secondPopular == 0) {
            return NSOrderedAscending;
        }else if(firstPopular == 0 && secondPopular == 1){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}
-(void)setLocalizable{
    [self.emptyLbl changeLocalizable:@"emptylbl"];
    [self.emptyDescriptionLbl changeLocalizable:@"emptydescriptionlbl"];
    [self.filterBtn setTitle:[[LanguageManager sharedManager] getLocalizedStringFromKey:@"filterbtn"] forState:UIControlStateNormal];
    self.tourhours = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"tourhours"];
    self.tourdistanse = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"tourdistanse"];
    self.toursightsnumber =  [[LanguageManager sharedManager] getLocalizedStringFromKey:@"toursightsnumber"];
}
-(void)buildServiceManager{
    self.loaderIndicator.hidden = NO;
    [self.loaderIndicator startAnimating];
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
}

-(void)confgureController{
    if (!self.isFromMenu) {
        [self.controllerTitle changeLocalizable:@"mytourlbl"];
        if(!self.isEmpty){
            self.filterBtn.hidden = YES;
            self.emptyTourView.hidden = NO;
        }
    }else{
        [self.controllerTitle changeLocalizable:@"tourlbl"];
    }
    
}
-(NSString*)getMiniDescription:(NSUInteger)sightCount withDuration:(NSNumber*)duration withDistance:(NSNumber*)distance{
    
    NSString *value = [NSString stringWithFormat:@"%lu %@, %@ %@, %@ %@",(unsigned long)sightCount,self.toursightsnumber,duration,self.tourhours,distance,self.tourdistanse];
    return value;
}
#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filterToursArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyToursCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyToursCustomCell" forIndexPath:indexPath];
    ToursModel *tour = self.filterToursArray[indexPath.row];
    cell.tourTitle.text = tour.tourTitle;
    NSString *imageUrl = @"";
    if (tour.toursImages.count > 0) {
      imageUrl = tour.toursImages[0];
    }
    for (int i=0; i<5; i++) {
        UIImageView *rait = cell.tourStar[i];
        if (i+1 <= tour.tourRaiting) {
            rait.image = [UIImage imageNamed:@"starIcon"];
        }else{
            rait.image = [UIImage imageNamed:@"raitUnselectStar"];
        }
    }
    cell.tourMiniDescription.text = [self getMiniDescription:tour.sightTour.count withDuration:tour.duration withDistance:tour.distance];
    [cell.loaderImage startAnimating];
    [cell.tourPosterImg sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    [cell.loaderImage stopAnimating];
        cell.loaderImage.hidden = YES;
    }];
    if (tour.isPopupar == 1) {
        if (self.isFromMenu) {
            cell.popularBadge.hidden = NO;
        }else{
            cell.popularBadge.hidden = YES;
        }
    }else{
        cell.popularBadge.hidden = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    ToursModel *tour = self.filterToursArray[indexPath.row];
    ToursDetailController *viewController = (ToursDetailController *)[mainStoryboard
                                                            instantiateViewControllerWithIdentifier:@"ToursDetailController"];
    viewController.tourID = tour.toursID;
    viewController.infoType = unknown;
    
    viewController.tourModel = tour;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 287;
}


#pragma mark - IBAction
- (IBAction)goToFilterView:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    FilterViewController *viewController = (FilterViewController *)[mainStoryboard
                                                                      instantiateViewControllerWithIdentifier:@"FilterViewController"];
    viewController.filterDelegate = self;
    viewController.tourTotalPrice = self.toursTotalPrice;
    viewController.filterIDS = self.filterIDS;
    viewController.currentCity = self.currentCity;
    viewController.isSelectedSecond = self.isSelectedSecond;
    viewController.isSelectedFirst = self.isSelectedFirst;
    viewController.currentPrice = self.saveCurrentFilterPrice;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (!self.isFromMenu) {
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }
}

-(void)tourTotalPrice:(NSArray<ToursModel *> *)tours{
    self.toursTotalPrice = 0;
    for (ToursModel *model in tours) {
        self.toursTotalPrice += [model.tourTotalPrice floatValue];
    }
    self.saveCurrentFilterPrice = self.toursTotalPrice;
}
#pragma mark - ServicesManagerDelegate

-(void)errorGetTours:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (error) {
            self.loaderIndicator.hidden = YES;
            [self.loaderIndicator stopAnimating];
        }
    });
}
/*
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
 
 */
-(void)getTours:(NSArray<ToursModel *> *)tours{

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self tourTotalPrice:tours];

        self.loaderIndicator.hidden = YES;

        [self.loaderIndicator stopAnimating];

        self.toursArray = tours;

        self.filterToursArray = tours;

        [self.manager getSights];

        if (!self.isFromMenu) {
            self.filterBtn.hidden = YES;

            NSDictionary *tonek = [SharedPreferenceManager getUserInfo];
            if (tonek) {
                NSArray *token = @[[tonek[@"id"] stringValue]];
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"tourlive == 1 && (userTokens == nil || ANY %K IN %@)",@"userTokens",token];

                self.toursArray = [self.toursArray filteredArrayUsingPredicate:predicate];

                self.filterToursArray = [self.filterToursArray filteredArrayUsingPredicate:predicate];
            }else{
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"tourlive == 1 && (userTokens == nil || receptStr.length > 9)"];

                self.toursArray = [self.toursArray filteredArrayUsingPredicate:predicate];

                self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:predicate];
            }
            if (self.toursArray.count > 0) {
                self.emptyTourView.hidden = YES;
            }else{
                self.emptyTourView.hidden = NO;
            }
        }else{

            [self filterTour];

        }
        
        [self.toursTableView reloadData];
    });

}
-(void)getSights:(NSArray<SightModel *> *)sights{
    
}
-(void)errorGetSights:(NSError *)error{
    
}
#pragma mark - FilterTourDelegate
-(void)filterTour:(NSArray *)categoryID withCity:(BOOL)needCity withNearMee:(BOOL)nearMee withPirceRange:(CGFloat )price{
    self.filterIDS = categoryID;
    self.isSelectedSecond = needCity;
    self.isSelectedFirst = nearMee;
    self.saveCurrentFilterPrice = price;
    if (needCity) {
        if (categoryID.count == 0) {
            self.filterToursArray = self.toursArray;
//            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
//            self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:mustSeePredicate];
        }else{
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",categoryID];
            
            self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:predicate];
//            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
//            self.filterToursArray = [self.filterToursArray filteredArrayUsingPredicate:mustSeePredicate];
        }
        if (nearMee) {
            NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
            self.filterToursArray = [self.filterToursArray filteredArrayUsingPredicate:predicateCity];
        }
    }else{
        if (nearMee) {
            if (categoryID.count == 0) {
                NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
                self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:predicateCity];
                
            }else{
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",categoryID];
                
                self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:predicate];
                NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"cityID == %@",self.currentCity.cityID];
                self.filterToursArray = [self.filterToursArray filteredArrayUsingPredicate:predicateCity];
            }
        }else{
            if (categoryID.count == 0) {
                self.filterToursArray = self.toursArray;
            }else{
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"category.filterID",categoryID];
                
                self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:predicate];
            }
        }
        if (needCity) {
            //            NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"must_see == 1"];
            //            self.filterToursArray = [self.toursArray filteredArrayUsingPredicate:mustSeePredicate];
        }
    }
    NSPredicate *mustSeePredicate = [NSPredicate predicateWithFormat:@"tourTotalPrice >= %@ && tourTotalPrice <= %@",[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:price]];
    self.filterToursArray = [self.filterToursArray filteredArrayUsingPredicate:mustSeePredicate];
    [self.toursTableView reloadData];
}
@end
