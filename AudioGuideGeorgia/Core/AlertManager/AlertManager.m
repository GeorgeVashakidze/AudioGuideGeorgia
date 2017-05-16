//
//  AlertManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/24/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "AlertManager.h"

@implementation AlertManager

-(void)showAlertWithController:(UIViewController *)controler andTitle:(NSString *)title withDesc:(NSString*)desc{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:desc preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];

    [alert addAction:okAction];
    [controler presentViewController:alert animated:YES completion:nil];
}
-(void)showYesNoAlertWithController:(UIViewController *)controler andTitle:(NSString *)title withDesc:(NSString*)desc{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:desc preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        [self.delegateAlert pressYES];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        [self.delegateAlert pressNO];
    }];
    [alert addAction:okAction];
    [alert addAction:noAction];
    [controler presentViewController:alert animated:YES completion:nil];
}
@end
