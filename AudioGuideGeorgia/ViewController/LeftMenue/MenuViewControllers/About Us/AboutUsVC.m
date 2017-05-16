//
//  AboutUsVC.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "AboutUsVC.h"
#import "SlideNavigationController.h"
#import "KASlideShowObj.h"
#import "ServiceManager.h"
#import "LocalizableLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MMMaterialDesignSpinner.h"

@interface AboutUsVC ()<ServicesManagerDelegate>

@property (weak, nonatomic) IBOutlet LocalizableLabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *aboutUsOverLay;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIView *slideShow;
@property (weak, nonatomic) IBOutlet UIImageView *aboutUsBg;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *loadIndicator;
@property (strong,nonatomic) KASlideShowObj *slideShowObj;
@end

@implementation AboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureFromInfoView];
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.descriptionTextView setContentOffset:CGPointZero animated:NO];
}
-(void)getAboutPage{
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];
    ServiceManager *manager = [[ServiceManager alloc] init];
    manager.delegate = self;
    [manager getPages];
}
-(void)addSlideShow{
    self.slideShowObj = [[KASlideShowObj alloc] init];
    self.slideShowObj.slideShowFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.slideShow.frame.size.height);
    [self.slideShowObj addPageController];
    [self.slideShow addSubview:self.slideShowObj.slideShow];
}
-(void)configureFromInfoView{
    if (self.titleStr) {
        self.controllerTitle.text = self.titleStr;
    }else{
        [self.controllerTitle changeLocalizable:@"aboutustitle"];
    }
    if (self.isFromInfo) {
        self.descriptionTextView.hidden = YES;
        self.logo.hidden = YES;
        self.slideShow.hidden = NO;
        [self addSlideShow];
        [self getPage:self.model];
    }else{
        [self getAboutPage];
    }
}

#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (!self.isFromInfo) {
        [SlideNavigationController sharedInstance].needTapGesture = YES;
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }else{
        [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    }
}

-(void)getPage:(PagesModel *)page{
    self.descriptionTextView.hidden = NO;
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
    self.descriptionTextView.text = page.pageDescription;
    self.slideShowObj.datasource = @[page.imagesFirst];
    [self.slideShowObj.slideShow reloadData];
}
-(void)setAboutPage{
    self.descriptionTextView.hidden = NO;
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
    self.descriptionTextView.text = self.model.pageDescription;
    NSURL *urlImg = [NSURL URLWithString:self.model.imagesFirst];
    [self.aboutUsBg sd_setImageWithURL:urlImg placeholderImage:[UIImage imageNamed:@"aboutUsBg"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}
#pragma mark - GetPages
-(void)getPages:(NSArray<PagesModel *> *)pages{
    for (int i = 0; i<pages.count; i++) {
        PagesModel *model = pages[i];
        if([model.pageID intValue] == 33){
            self.model = model;
            [self setAboutPage];
            break;
        }
    }
}
-(void)errorGetPages:(NSError *)error{

}
@end
