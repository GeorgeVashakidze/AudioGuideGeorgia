//
//  ToursDetailCustomCell.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/9/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SightModel.h"
#import "LocalizableLabel.h"

@interface ToursDetailCustomCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,weak) IBOutlet UILabel *tourTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *noteLbl;
@property (nonatomic,weak) IBOutlet UILabel *tourShorDescripton;
@property (nonatomic,weak) IBOutlet UILabel *tourStartLbl;
@property (nonatomic,weak) IBOutlet UILabel *tourEndLbl;
@property (nonatomic,weak) IBOutlet UILabel *stopCountLbl;
@property (nonatomic,weak) IBOutlet UILabel *breakTipLbl;
@property (nonatomic,weak) IBOutlet UICollectionView *tourStopCollectionView;
@property (nonatomic,weak) IBOutlet UILabel *longDescription;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *heightCollectio;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *heightstopsLbl;
@property (nonatomic,weak) IBOutlet LocalizableLabel *endLbl;
@property (nonatomic,weak) IBOutlet LocalizableLabel *startLbl;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *leftOpeningConstraint;
@property (nonatomic,weak) IBOutlet UILabel *deleteLbl;


@property (nonatomic,strong) NSArray<SightModel*> *sightsArray;
-(void)reloadDataCollectionView;
@end
