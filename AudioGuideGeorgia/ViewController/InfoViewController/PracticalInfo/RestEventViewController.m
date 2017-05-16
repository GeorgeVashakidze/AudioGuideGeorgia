//
//  RestEventViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "RestEventViewController.h"
#import "RestEventCell.h"
#import "ToursDetailController.h"
#import "ServiceManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MMMaterialDesignSpinner.h"

@interface RestEventViewController () <UITableViewDelegate,UITableViewDataSource,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *indicator;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property NSArray<RestaurantsModel*> *restaurant;
@property NSArray<ShopsModel*> *shops;
@property NSArray<FestivalsModel*> *festivals;

@end

@implementation RestEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.controllerTiTle.text = self.titleStr;
    [self buildService];
}
-(void)buildService{
    ServiceManager *manager = [[ServiceManager alloc] init];
    manager.delegate = self;
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    switch (self.info) {
        case restaurants:
            [manager getRestaurants];
            break;
        case shops:
            [manager getShops];
            break;
        case festivals:
            [manager getFestivals];
            break;
        default:
            break;
    }
}
#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableviewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.info) {
        case restaurants:
            return self.restaurant.count;
            break;
        case shops:
            return self.shops.count;
            break;
        case festivals:
            return self.festivals.count;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RestEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestEventCell" forIndexPath:indexPath];
    switch (self.info) {
        case restaurants:
            [self drawRestaurant:cell withIndexPath:indexPath];
            break;
        case shops:
            [self drawShop:cell withIndexPath:indexPath];
            break;
        case festivals:
            [self drawFestivals:cell withIndexPath:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}

-(void)drawRestaurant:(RestEventCell*)cell withIndexPath:(NSIndexPath*)indexPath{
    RestaurantsModel *model = self.restaurant[indexPath.row];
    cell.titleLbl.text = model.sightTitle;
    cell.typeLbl.text = model.restType;
    cell.dateLbl.text = @"";
    cell.dateBg.hidden = YES;
    [cell.posterImg sd_setImageWithURL:[NSURL URLWithString:model.imagesFirst] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

-(void)drawShop:(RestEventCell*)cell withIndexPath:(NSIndexPath*)indexPath{
    ShopsModel *model = self.shops[indexPath.row];
    cell.titleLbl.text = model.sightTitle;
    cell.typeLbl.text = model.typeShop;
    cell.dateLbl.text = @"";
    cell.dateBg.hidden = YES;
    [cell.posterImg sd_setImageWithURL:[NSURL URLWithString:model.imagesFirst] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}
-(void)drawFestivals:(RestEventCell*)cell withIndexPath:(NSIndexPath*)indexPath{
    FestivalsModel *model = self.festivals[indexPath.row];
    cell.titleLbl.text = model.sightTitle;
    cell.typeLbl.text = model.typeFestival;
    cell.dateLbl.text = [self getDateFestival:model.eventDate];
    cell.dateBg.hidden = NO;
    [cell.posterImg sd_setImageWithURL:[NSURL URLWithString:model.imagesFirst] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}
-(NSString*)getDateFestival:(NSDate*)festivalDate{
    NSString *dateStr = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setDateFormat:@"dd.MM"];
    NSString *stringDate = [dateFormatter stringFromDate:festivalDate];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *stringHours = [dateFormatter stringFromDate:festivalDate];
    return [[[dateStr stringByAppendingString:stringDate] stringByAppendingString:@" / "] stringByAppendingString:stringHours];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RestEventCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    ToursDetailController *viewController = (ToursDetailController *)[mainStoryboard
                                              instantiateViewControllerWithIdentifier:@"ToursDetailController"];
    viewController.isFormInfo = YES;
    viewController.titleStr = cell.titleLbl.text;
    switch (self.info) {
        case restaurants:{
            RestaurantsModel *model = self.restaurant[indexPath.row];
            viewController.restModel = model;
            viewController.infoType = self.info;
        }
            break;
        case shops:{
            ShopsModel *model = self.shops[indexPath.row];
            viewController.shopModel = model;
            viewController.infoType = self.info;
        }
            break;
        case festivals:{
            FestivalsModel *model = self.festivals[indexPath.row];
            viewController.festivalModel = model;
            viewController.infoType = self.info;
        }
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - ServicesManagerDelegate

-(void)getShops:(NSArray<ShopsModel *> *)shops{
    self.shops = shops;
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    [self.tableview reloadData];
}

-(void)errorgetShop:(NSError *)error{
    if (error) {
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }
}
-(void)getRestaurant:(NSArray<RestaurantsModel *> *)restaurants{
    self.restaurant = restaurants;
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    [self.tableview reloadData];
}
-(void)errorgetRestaurants:(NSError *)error{
    if (error) {
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }
}
-(void)errorgetFestivals:(NSError *)error{
    if (error) {
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }
}
-(void)getFestivals:(NSArray<FestivalsModel *> *)festivals{
    self.festivals = festivals;
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    [self.tableview reloadData];
}
@end
