//
//  DownloadMapView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "DownloadMapView.h"

@implementation DownloadMapView
-(void)cornerRaidus{
    [self initDownloadManager];
    self.yesButton.layer.masksToBounds = YES;
    self.yesButton.layer.cornerRadius = 8;
    self.noButton.layer.masksToBounds = YES;
    self.noButton.layer.cornerRadius = 8;
    self.imageViewBackground.layer.masksToBounds = YES;
    self.imageViewBackground.layer.cornerRadius = 8;
    self.downloadingView.layer.masksToBounds = YES;
    self.downloadingView.layer.cornerRadius = 8;
    [self initProgpressLabel];
}
-(void)showDownloadCompletedAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congrats !" message:@"You've just download offline map pack" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        [self removeFromSuperview];
    }];
    
    [alert addAction:okAction];
    [_controler presentViewController:alert animated:YES completion:nil];
}
-(void)initProgpressLabel{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"DINPro-Medium" size:19];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor grayColor];
    textLabel.backgroundColor = [UIColor clearColor];
    self.downloadProgresView.lineWidth = 4;
    self.downloadProgresView.tintColor = [UIColor colorWithRed:42.0/255.0 green:253.0/255.0 blue:142.0/255.0 alpha:1];
    self.downloadProgresView.centralView = textLabel;
}
-(void)initDownloadManager{
    self.managerMapDownload = [[MapDownloadManager alloc] init];
    self.managerMapDownload.downloadDelegate = self;
}
#pragma mark - IBAction

- (IBAction)downloadYes:(UIButton *)sender {
    self.downloadAlertView.hidden = YES;
    self.downloadingView.hidden = NO;
    [self.managerMapDownload startDownload];
}

- (IBAction)downloadNo:(UIButton *)sender {
    [self removeFromSuperview];
}

#pragma mark - MapDownloadDelegate

-(void)progressDownload:(float)progress{
    NSString *persetStr = [NSString stringWithFormat:@"%.0f%%",progress*100];
    [self.downloadProgresView setProgress:progress];
    
    ((UILabel*)self.downloadProgresView.centralView).text = persetStr;
}

-(void)finishedDownload{
    self.downloadingView.hidden = YES;
    [self showDownloadCompletedAlert];
    
    [self.downloadDelegate downloadCompleted];
}
@end
