//
//  ToursDetailTableHeader.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ToursDetailTableHeader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SharedPreferenceManager.h"

@implementation ToursDetailTableHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // you can change wether it expands at the top or as soon as you scroll down
    self.expansionMode = GSKStretchyHeaderViewExpansionModeTopOnly;
    
    // You can change the minimum and maximum content heights
    self.minimumContentHeight = 0; // you can replace the navigation bar with a stretchy header view
    if (IS_IPHONE5 || IS_IPHONE4) {
        self.maximumContentHeight = 188;
    }else{
        self.maximumContentHeight = 227;
    }
    
    // You can specify if the content expands when the table view bounces, and if it shrinks if contentView.height < maximumContentHeight. This is specially convenient if you use auto layout inside the stretchy header view
    self.contentShrinks = YES;
    self.contentExpands = NO; // useful if you want to display the refreshControl below the header view
    
    // You can specify wether the content view sticks to the top or the bottom of the header view if one of the previous properties is set to NO
    // In this case, when the user bounces the scrollView, the content will keep its height and will stick to the bottom of the header view
    self.contentAnchor = GSKStretchyHeaderViewContentAnchorBottom;
}
-(void)addSlideShow{
    self.sliderView.hidden = NO;
    self.slideShowObj = [[KASlideShowObj alloc] init];
    self.slideShowObj.slideShowFrame = CGRectMake(0, 0, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
    [self.slideShowObj addPageController];
    [self.sliderView addSubview:self.slideShowObj.slideShow];
}
-(void)setCornerRadiuse{
    self.downloadButton.layer.masksToBounds = YES;
    self.downloadButton.layer.cornerRadius = 2;
    if (self.isFromIfno) {
        self.downloadButton.hidden = YES;
    }else{
        [self.tourImage sd_setImageWithURL:[NSURL URLWithString:self.imgURL] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    NSDictionary *userDic = [SharedPreferenceManager getUserInfo];
    if(self.isTourLive){
        [self.downloadButton setTitle:@"Start tour" forState:UIControlStateNormal];
    }else if ((self.isTourDeleted && self.tourRecept) || [userDic[@"promotion"] intValue] == 1) {
        [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    }
}

#pragma mark - IBAction


- (IBAction)downloadTour:(UIButton *)sender {
    [self.tourDownloadDelegate downloadTour];
}

@end
