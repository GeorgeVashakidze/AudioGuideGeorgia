//
//  ToursDetailTableHeader.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>
#import "Constants.h"
#import "KASlideShowObj.h"

@protocol DownloadTourDelegate <NSObject>

- (void)downloadTour;

@end

@interface ToursDetailTableHeader : GSKStretchyHeaderView
@property (weak,nonatomic) id<DownloadTourDelegate> tourDownloadDelegate;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIImageView *tourImage;
@property KASlideShowObj *slideShowObj;
@property NSString *imgURL;
@property BOOL isFromIfno;
@property BOOL isTourLive;
@property BOOL isTourDeleted;
@property NSString *tourRecept;
-(void)setCornerRadiuse;
-(void)addSlideShow;
@end
