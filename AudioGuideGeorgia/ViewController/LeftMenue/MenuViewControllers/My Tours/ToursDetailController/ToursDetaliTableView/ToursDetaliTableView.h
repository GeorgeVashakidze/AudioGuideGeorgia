//
//  ToursDetaliTableView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceManager.h"
#import "Constants.h"
#import "ToursDetailTableHeader.h"

@class RestaurantsModel;
@protocol StatiTableviewDelegate <NSObject>

- (void) downloadTour;
- (void) deleteTour;
@end

@interface ToursDetaliTableView : UITableViewController
@property (weak,nonatomic) id<StatiTableviewDelegate> tourDownloadDelegate;
@property BOOL isFromInfo;
@property NSNumber *tourID;
@property Inforamtion infoType;
@property (strong,nonatomic) RestaurantsModel *resDetail;
@property (strong,nonatomic) ShopsModel *shopDetail;
@property (strong,nonatomic) FestivalsModel *festival;
@property (strong,nonatomic) ToursModel *toursModel;
@property (weak,nonatomic) ToursDetailTableHeader *headerView;
-(void)loadHeaderView;
-(void)buildService;
-(ToursModel*)getTourModel;
@end
