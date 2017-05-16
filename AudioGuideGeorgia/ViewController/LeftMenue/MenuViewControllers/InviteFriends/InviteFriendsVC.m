//
//  InviteFriendsVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/19/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "InviteFriendsVC.h"
#import "SlideNavigationController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "LocalizableLabel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface InviteFriendsVC ()<FBSDKAppInviteDialogDelegate,FBSDKSharingDelegate>
    @property (weak, nonatomic) IBOutlet LocalizableLabel *invDescription;
    @property (weak, nonatomic) IBOutlet LocalizableLabel *invpagetitle;
    @property (weak, nonatomic) IBOutlet LocalizableLabel *invYourfrin;

@end

@implementation InviteFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLocalizable];
}
- (void)setLocalizable{
    [self.invDescription changeLocalizable:@"invfrienddescription"];
    [self.invpagetitle changeLocalizable:@"invitepagetitle"];
    [self.invYourfrin changeLocalizable:@"inviteyourfriends"];
}
-(void)inviteFriendsDialog{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    
    // Present the dialog. Assumes self is a view controller
    // which implements the protocol `FBSDKAppInviteDialogDelegate`.
    [FBSDKAppInviteDialog showFromViewController:[SlideNavigationController sharedInstance]
                                     withContent:content
                                        delegate:self];
}
-(void)shareOnFacebook{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://audioguidegeorgia.com"];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
}
#pragma mark - IBActions

- (IBAction)inviteFriends:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SlideNavigationController sharedInstance].needTapGesture = YES;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
- (IBAction)shareFacebookPoster:(UIButton *)sender {
    [self shareOnFacebook];
}
- (IBAction)invFbFriends:(UIButton *)sender {
    [self inviteFriendsDialog];
}

#pragma mark - FBSDKAppInviteDialogDelegate
-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    
}
-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    
}
#pragma mark - FBSDKSharingDelegate
-(void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    
}
-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    
}
-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    
}
@end
