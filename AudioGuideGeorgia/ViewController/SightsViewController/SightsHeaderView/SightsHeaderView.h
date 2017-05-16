//
//  SightsHeaderView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>
#import "ServiceManager.h"
#import "MMMaterialDesignSpinner.h"

@class CityModel;
@protocol FilterDelegate <NSObject>

- (void)chooseFilter:(NSArray*)filterID withMustSee:(BOOL)mustSee withNear:(BOOL)nearMee;
- (void)changeHeightOfHeader:(CGFloat)heightHeader;
@end

@interface SightsHeaderView : GSKStretchyHeaderView <UITableViewDataSource,UITableViewDelegate,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loadIndicator;
@property (weak,nonatomic) id<FilterDelegate> filterDelegate;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIButton *firstFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondFilterBtn;
@property (strong, nonatomic) NSMutableArray *selectedCellIndexArray;
@property (nonatomic) ServiceManager *manager;
@property CityModel *currentCity;
@property BOOL isFromTours;
@property BOOL needMustSee;
@property BOOL isSelecteedFirst;
@property BOOL isSelecteedSecond;
@property NSArray<FilterModel*> *filterTours;
-(void)selectedFirstBtn:(BOOL)isFirstBtn;
-(void)buildService;
-(void)setDefaultButtons;
@end
