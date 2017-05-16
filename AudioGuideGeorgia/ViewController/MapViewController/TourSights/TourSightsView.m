//
//  TourSightsView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "TourSightsView.h"
#import "SightModel.h"
#import "SightsCustomCellNib.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TourSightsView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setCollectionView];
    UINib *nib = [UINib nibWithNibName:@"SightsCustomCellNib" bundle:nil];
    [self.sightCollectionView registerNib:nib forCellWithReuseIdentifier:@"SightsCustomCellNib"];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)setCollectionView{
    self.sightCollectionView.delegate = self;
    self.sightCollectionView.dataSource = self;
}
-(void)reloadDataCollectionView{
    self.sightCountLb.text = [NSString stringWithFormat:@"%lu sights",(unsigned long)self.dataSource.count];
    [self.sightCollectionView reloadData];
}
#pragma mark - UICollectionvView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SightsCustomCellNib *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SightsCustomCellNib" forIndexPath:indexPath];
    if (self.dataSource.count == indexPath.row) {
        cell.signtname.hidden = YES;
        cell.sightNumber.hidden = YES;
        cell.sightPoster.hidden = YES;
    }else{
        cell.signtname.hidden = NO;
        cell.sightNumber.hidden = NO;
        cell.sightPoster.hidden = NO;
        cell.sightNumber.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
        SightModel *model = self.dataSource[indexPath.item];
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
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate clickeSight:indexPath.item];
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count == indexPath.row) {
        return CGSizeMake(10, 148);
    }
    return CGSizeMake(247, 148);}

@end
