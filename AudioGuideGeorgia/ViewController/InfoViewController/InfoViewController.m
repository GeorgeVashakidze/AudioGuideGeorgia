//
//  InfoViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "InfoViewController.h"
#import "LocalizableLabel.h"

@interface InfoViewController ()
    @property (weak, nonatomic) IBOutlet LocalizableLabel *titleLbl;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLbl changeLocalizable:@"inftitlelbl"];
}

#pragma mark - IBActions

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
