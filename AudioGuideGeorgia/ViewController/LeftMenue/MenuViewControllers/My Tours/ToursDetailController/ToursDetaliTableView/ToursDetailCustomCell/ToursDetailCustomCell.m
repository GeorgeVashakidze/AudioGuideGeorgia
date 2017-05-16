//
//  ToursDetailCustomCell.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/9/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ToursDetailCustomCell.h"
#import "ToursSightCustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ToursDetailCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self setCollectionView];
    [self.startLbl changeLocalizable:@"tourstart"];
    [self.endLbl changeLocalizable:@"tourend"];
}
-(void)setCollectionView{
    self.tourStopCollectionView.delegate = self;
    self.tourStopCollectionView.dataSource = self;
}
-(void)reloadDataCollectionView{
    [self.tourStopCollectionView reloadData];
}
#pragma mark - UICollectionvView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.sightsArray.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ToursSightCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ToursSightCustomCell" forIndexPath:indexPath];
    if (self.sightsArray.count == indexPath.row) {
        cell.signtname.hidden = YES;
        cell.sightNumber.hidden = YES;
        cell.sightPoster.hidden = YES;
    }else{
        cell.signtname.hidden = NO;
        cell.sightNumber.hidden = NO;
        cell.sightPoster.hidden = NO;
        cell.sightNumber.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
        SightModel *model = self.sightsArray[indexPath.item];
        NSString *imgUrl = model.imagesFirst;
        if (model.imagesArray.count > 0) {
            imgUrl = model.imagesArray[0];
        }
        [cell.sightPoster sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        cell.signtname.text = model.sightTitle;
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sightsArray.count == indexPath.row) {
        return CGSizeMake(10, 148);
    }
    return CGSizeMake(247, 148);
}

@end
