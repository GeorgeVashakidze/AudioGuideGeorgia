//
//  DownloadMapView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
#import "MapDownloadManager.h"
@protocol DownloadMapViewtDelegate <NSObject>

-(void)downloadCompleted;

@end
@interface DownloadMapView : UIView<MapDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIView *downloadingView;
@property (weak,nonatomic) id<DownloadMapViewtDelegate> downloadDelegate;
@property (weak, nonatomic) IBOutlet UAProgressView *downloadProgresView;
@property (weak, nonatomic) IBOutlet UIView *downloadAlertView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBackground;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property MapDownloadManager *managerMapDownload;
@property (weak,nonatomic) UIViewController *controler;
-(void)cornerRaidus;
@end
