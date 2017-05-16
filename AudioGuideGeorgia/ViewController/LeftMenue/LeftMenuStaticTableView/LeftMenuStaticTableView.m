//
//  LeftMenuStaticTableView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/28/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "LeftMenuStaticTableView.h"
#import <MessageUI/MessageUI.h>
#import "SlideNavigationController.h"
#import "SharedPreferenceManager.h"

@interface LeftMenuStaticTableView ()<MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>

@end

@implementation LeftMenuStaticTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self LeftMenuEvents];
    if(IS_IPHONE6 || IS_IPHONE6P || IS_IPHONE5){
        self.tableView.scrollEnabled = NO;
    }
}
-(void)LeftMenuEvents{
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        [SlideNavigationController sharedInstance].needTapGesture = NO;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
    }];
}
#pragma mark - UITableview delegates

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.alpha = 0.6;
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.alpha = 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicUser = [SharedPreferenceManager getUserInfo];
    if ([dicUser[@"promotion"] intValue] == 1 && indexPath.row == 0) {
        return 0;
    }
    if (IS_IPHONE5) {
        return 46.0f;
    }
    return 48.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            //Promotion
            [self navigationToViewControllerByID:@"PromotionVC"];
            break;
        case 1:
            //Language
            [self navigationToViewControllerByID:@"LanguageVC"];
            break;
        case 2:
            //My Tours
            [self navigationToViewControllerByID:@"MyToursVC"];
            break;
        case 3:
            //Preferences
            [self navigationToViewControllerByID:@"PreferencesVC"];
            break;
        case 4:
            //Add a review
            break;
        case 5:
            //Help/Feedback
            [self sendEmailToContact];
            break;
        case 6:
            //Inv Friends
            [self navigationToViewControllerByID:@"InviteFriendsVC"];
            break;
        case 7:
            //Tell a friends
            [self showActionSheet];
            break;
        case 8:
            //About US
            [self navigationToViewControllerByID:@"AboutUsVC"];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation to Controllers

-(void)navigationToViewControllerByID:(NSString*)controllerIdentifire{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *viewController = (UIViewController *)[mainStoryboard
                                                                       instantiateViewControllerWithIdentifier:controllerIdentifire];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:viewController
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
}


#pragma mark - Email
///This private function present email send controller if support device
-(void)sendEmailToContact{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"exaple@gmail.com"]];
        
        mail.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [[SlideNavigationController sharedInstance] presentViewController:mail animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"No mail account setup on device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
        }];
        [alertController addAction:okAction];
        [[SlideNavigationController sharedInstance] presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [[SlideNavigationController sharedInstance] dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIActionSheetDelegate
-(void)showActionSheet{
    NSString *textToShare = @"";
    NSURL *myWebsite = [NSURL URLWithString:@"https://audioguidegeorgia.com"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    // Present action sheet.
     [[SlideNavigationController sharedInstance] presentViewController:activityVC animated:YES completion:nil];
}
@end
