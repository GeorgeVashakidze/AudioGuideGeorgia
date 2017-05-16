//
//  KASlideShowObj.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "KASlideShowObj.h"

@implementation KASlideShowObj

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
-(void)addPageController{
    self.slideShow = [[KASlideShow alloc] initWithFrame:self.slideShowFrame];
    self.slideShow.datasource = self;
    self.slideShow.delegate = self;
    self.slideShow.layer.masksToBounds = YES;
    [self.slideShow setDelay:1]; // Delay between transitions
    [self.slideShow setTransitionDuration:.5]; // Transition duration
    [self.slideShow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    [self.slideShow setTransitionType:KASlideShowTransitionSlideHorizontal];
    [self.slideShow addGesture:KASlideShowGestureSwipe];
    [self addPage];
}
-(void)addPage{
    self.pageConroller = [[UIPageControl alloc] init];
    self.pageConroller.frame = CGRectMake(0, self.self.slideShowFrame.size.height-30, self.self.slideShowFrame.size.width, 37);
    self.pageConroller.numberOfPages = self.datasource.count;
    self.pageConroller.currentPage = 0;
    [self.slideShow addSubview:self.self.pageConroller];
    self.slideShow.layer.zPosition = 999;
}
#pragma mark - KASlideShow datasource

- (NSObject *)slideShow:(KASlideShow *)slideShow objectAtIndex:(NSUInteger)index
{
    return [NSURL URLWithString:_datasource[index]];
}

- (NSUInteger)slideShowImagesNumber:(KASlideShow *)slideShow
{
    return _datasource.count;
}

#pragma mark - KASlideShow delegate

- (void) slideShowWillShowNext:(KASlideShow *)slideShow
{
    NSLog(@"slideShowWillShowNext, index : %@",@(slideShow.currentIndex));
}

- (void) slideShowWillShowPrevious:(KASlideShow *)slideShow
{
    NSLog(@"slideShowWillShowPrevious, index : %@",@(slideShow.currentIndex));
}

- (void) slideShowDidShowNext:(KASlideShow *)slideShow
{
    NSLog(@"slideShowDidShowNext, index : %@",@(slideShow.currentIndex));
    self.pageConroller.currentPage = slideShow.currentIndex;
}

-(void) slideShowDidShowPrevious:(KASlideShow *)slideShow
{
    NSLog(@"slideShowDidShowPrevious, index : %@",@(slideShow.currentIndex));
    self.pageConroller.currentPage = slideShow.currentIndex;
}
@end
