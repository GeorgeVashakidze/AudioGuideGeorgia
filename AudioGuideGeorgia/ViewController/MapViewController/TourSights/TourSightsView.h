//
//  TourSightsView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SightModel;

@protocol TourSightDelegate <NSObject>

- (void)clickeSight:(NSInteger)index;

@end

@interface TourSightsView : UIView<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *sightCountLb;
@property (weak,nonatomic) id<TourSightDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *sightCollectionView;
@property NSArray<SightModel*> *dataSource;
-(void)reloadDataCollectionView;
@end
