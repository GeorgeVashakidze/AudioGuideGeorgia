//
//  SightsClickHelperView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/8/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShowObj.h"
#import "SliderSubClass.h"
#import "Constants.h"
#import "AudioPlayer.h"

@class SightModel;
@protocol GestureSwipeDownDelegate <NSObject>

-(void)startSwipe;
-(void)swipeDown:(CGFloat)currentPointY withPlaying:(BOOL)playing;
-(void)swipeEnd:(CGFloat)currentPointY withPlaying:(BOOL)playing;
-(void)nextTreck;
-(void)loadAudio;
-(void)startPlay;
-(void)errorLoadAudio;
-(void)playerReachEnd;
-(void)getDirection;
@end

@interface SightsClickHelperView : UIView<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnWidth;
@property (weak, nonatomic) IBOutlet UILabel *sightTitle;
@property (weak,nonatomic) id<GestureSwipeDownDelegate> swipeDelegate;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *playBAckButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel *durationLbl;
@property (weak, nonatomic) IBOutlet UISlider *horizonTalSlider;
@property (strong,nonatomic) AudioPlayer *player;
@property  UIPanGestureRecognizer *gesture;
@property CGPoint startTouchPoint;
@property CGFloat startHeightPsoter;
@property CGFloat constantHeightPsoter;
@property BOOL isPlaying;
@property BOOL needPlayer;
@property BOOL isFromTour;
@property BOOL isliveTour;
@property int selectedIndex;
@property (strong,nonatomic) KASlideShowObj *slideShowObj;
@property (strong,nonatomic) SightModel *model;
-(void)sightPosterShow:(SightModel*)model withHanlde:(void (^)())handler;
-(void)showView;
-(void)hideView;
-(void)nullHysteriaPlayer;
-(void)playAuto;
-(void)showSmallPlayer;
-(void)fullVersionPlayer;
-(void)deactivateNextBtn:(BOOL)deactivate;
@end
