//
//  ReviewView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/9/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "ReviewView.h"
#import "ServiceManager.h"
#import "MMMaterialDesignSpinner.h"

@interface ReviewView()<ServicesManagerDelegate>{
    
}
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loaderSppiner;
@property NSString *raittour;
@end

@implementation ReviewView
-(void)awakeFromNib{
    [super awakeFromNib];
    self.raiting = 0;
    self.raittour = [[LanguageManager sharedManager] getLocalizedStringFromKey:@"raittour"];
}
#pragma mark - IBAction

- (IBAction)raitTour:(UIButton *)sender {
    self.raiting = sender.tag+1;
    for (int i=0; i<_raitButton.count; i++) {
        UIButton *rait = _raitButton[i];
        if (i <= sender.tag) {
            [rait setImage:[UIImage imageNamed:@"raitSelectStar"] forState:UIControlStateNormal];
        }else{
            [rait setImage:[UIImage imageNamed:@"raitUnselectStar"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)submitRaiting:(UIButton *)sender {
    if (_raiting == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message" message:self.raittour preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
        }];
        [alert addAction:okAction];
        [self.controller presentViewController:alert animated:YES completion:nil];
    }else{
        self.userInteractionEnabled = NO;
        self.loaderSppiner.hidden = NO;
        [self.loaderSppiner startAnimating];
        ServiceManager *manager = [[ServiceManager alloc] init];
        manager.delegate  = self;
        [manager submitRaiting:self.raiting withTourID:self.tourID];
    }
}

#pragma mark - ServicesManagerDelegate

-(void)submitTourRaview:(NSDictionary *)response{
    self.userInteractionEnabled = YES;
    self.loaderSppiner.hidden = YES;
    [self.loaderSppiner stopAnimating];
    [self.delegateRaiting setTourRaitin:self.raiting];
    [self removeFromSuperview];
}

-(void)errorSubmitTourRaview:(NSError *)error{
    self.userInteractionEnabled = YES;
    self.loaderSppiner.hidden = YES;
    [self.loaderSppiner stopAnimating];
    [self.delegateRaiting setTourRaitin:self.raiting];
    [self removeFromSuperview];
}

@end
