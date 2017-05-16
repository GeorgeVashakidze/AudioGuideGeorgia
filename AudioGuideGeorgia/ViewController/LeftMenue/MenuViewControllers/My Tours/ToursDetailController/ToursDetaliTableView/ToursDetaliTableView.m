//
//  ToursDetaliTableView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ToursDetaliTableView.h"
#import "ToursDetailCustomCell.h"
#import "DrawStaticCell.h"
#import "SharedPreferenceManager.h"

@interface ToursDetaliTableView ()<DownloadTourDelegate,ServicesManagerDelegate>
@property (strong,nonatomic) ToursModel *tourDetail;
@property (strong,nonatomic) NSArray *images;
@property (strong,nonatomic) DrawStaticCell *drawCell;
@property ServiceManager *manager;
@property NSString *deletetouraler;
@property NSString *tourhours;
@property NSString *toursightsnumberstop;
@property NSString *tourdistanse;
@end

@implementation ToursDetaliTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.drawCell = [[DrawStaticCell alloc] init];
    self.drawCell.isFromInfo = self.isFromInfo;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 25;
    self.tableView.hidden = YES;
    _manager  = [[ServiceManager alloc] init];
    _manager.delegate = self;
    [self localizableStrings];
}
-(void)localizableStrings{
    self.deletetouraler = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"deletetouraler"];
}
-(ToursModel*)getTourModel{
    return self.tourDetail;
}
-(void)buildService{

    if (self.infoType == restaurants) {
        self.images = self.resDetail.imagesArray;
        self.tableView.hidden = NO;
        [self loadHeaderView];
    }else if(self.infoType == shops){
        self.images = self.shopDetail.imagesArray;
        self.tableView.hidden = NO;
        [self loadHeaderView];
    }else if (self.infoType == festivals){
        self.images = self.festival.imagesArray;
        self.tableView.hidden = NO;
        [self loadHeaderView];
    }else{
        if (self.toursModel) {
            self.tourDetail = self.toursModel;
            self.images = self.tourDetail.toursImages;
            self.tableView.hidden = NO;
            [self loadHeaderView];
        }else{
            [_manager getTourDetail:self.tourID];
        }
        
    }
    [self.tableView reloadData];
}

#pragma mark - Load Header View

-(void)loadHeaderView{
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"ToursDetailTableHeader" owner:self options:nil] objectAtIndex:0];
    if (IS_IPHONE4 || IS_IPHONE5) {
        _headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 188);
    }else{
        _headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 227);
    }
    NSString *imgUrl = @"";
    if (self.tourDetail.toursImages.count > 0) {
        imgUrl = self.tourDetail.toursImages[0];
    }
    _headerView.tourDownloadDelegate = self;
    _headerView.imgURL = imgUrl;
    if (self.tourDetail.receptStr.length > 9) {
        _headerView.tourRecept = self.tourDetail.receptStr;
    }else{
        _headerView.tourRecept = [SharedPreferenceManager getSubscriber];
    }
    if (self.isFromInfo) {
        [_headerView addSlideShow];
        _headerView.slideShowObj.datasource = self.images;
        [_headerView.slideShowObj.slideShow reloadData];
        _headerView.slideShowObj.pageConroller.numberOfPages = self.images.count;
    }
    _headerView.isFromIfno = self.isFromInfo;
    if (self.toursModel.tourlive == 1 && self.toursModel.receptStr.length > 9) {
        _headerView.isTourLive = YES;
    }else if(self.toursModel.tourlive == 1){
        NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
        if (userDic) {
            for (int i = 0; i < self.toursModel.userTokens.count; i++) {
                NSString *userIDs = self.toursModel.userTokens[i];
                if ([userIDs isEqualToString:[userDic[@"id"] stringValue]]) {
                    _headerView.isTourLive = YES;
                    break;
                }
            }
        }
    }
    if (self.toursModel.isDeleteTour == 1) {
        _headerView.isTourDeleted = YES;
    }
    [_headerView setCornerRadiuse];
    [self.tableView addSubview:_headerView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma makr - UITableviewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ToursDetailCustomCell *cell = (ToursDetailCustomCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (self.infoType) {
        case unknown:
            [self.drawCell drawTourDetail:cell withModel:self.tourDetail andIndex:indexPath];
            break;
        case restaurants:
            [self.drawCell drawRestaurantDetail:cell withModel:self.resDetail andIndex:indexPath];
            break;
        case shops:
            [self.drawCell drawShopDetail:cell withModel:self.shopDetail andIndex:indexPath];
            break;
        case festivals:
            [self.drawCell drawFestivalDetail:cell withModel:self.festival andIndex:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 58;
            break;
        case 1:
            return UITableViewAutomaticDimension;
            break;
        case 2:
            if (self.tourDetail.notes && ![self.tourDetail.notes isEqualToString:@""]) {
                return UITableViewAutomaticDimension;
            }else if(self.resDetail.contact && ![self.resDetail.contact isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else if(self.shopDetail.webURL && ![self.shopDetail.webURL isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else if(self.festival.venueName && ![self.festival.venueName isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else{
                return 1;
            }
            break;
        case 3:
            if (self.tourDetail.break_tip && ![self.tourDetail.break_tip isEqualToString:@""]) {
                return UITableViewAutomaticDimension;
            }else if(self.resDetail.address && ![self.resDetail.address isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else if(self.shopDetail.webURL && ![self.shopDetail.webURL isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else if(self.festival.venueName && ![self.festival.venueName isEqualToString:@""]){
                return UITableViewAutomaticDimension;
            }else{
                return 1;
            }
            break;
        case 4:
            return UITableViewAutomaticDimension;
            break;
        case 5:{
            if (self.tourDetail.tourlive && self.infoType == unknown) {
                return 70;
            }
            return 1;
        }
            break;
        default:
            return 58;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tourDetail.tourlive && self.infoType == unknown && indexPath.row == 5) {
        NSLog(@"Selected");
        [_manager updateTourTolive:self.toursModel withLive:0];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TOUR DELETE" message:_deletetouraler preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
            [_tourDownloadDelegate deleteTour];
        }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
        }];
        [alert addAction:okAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - DownloadTourDelegate

-(void)downloadTour{
    [self.tourDownloadDelegate downloadTour];
}

#pragma mark - ServicesManagerDelegate

-(void)errorGetTours:(NSError *)error{
    
}

-(void)getTourDetail:(ToursModel *)tours{
    self.tourDetail = tours;
    self.images = self.tourDetail.toursImages;
    self.tableView.hidden = NO;
    [self loadHeaderView];
    [self.tableView reloadData];
}

@end
