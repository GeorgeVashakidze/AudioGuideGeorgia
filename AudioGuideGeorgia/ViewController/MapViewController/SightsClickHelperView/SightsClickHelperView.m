
//
//  SightsClickHelperView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/8/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "SightsClickHelperView.h"
#import "SightModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SharedPreferenceManager.h"

CGFloat const gestureMinimumTranslation = 20.0;

@interface SightsClickHelperView()<AudioPlayerDelegate>{
    CameraMoveDirection direction;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintSlider;
@property (weak, nonatomic) IBOutlet UIImageView *sightFirstImage;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (nonatomic) NSTimer *musicDurationTimer;
@end

@implementation SightsClickHelperView

-(void)awakeFromNib{
    [super awakeFromNib];

    [self setGestureRecognizer];
}
-(void)deactivateNextBtn:(BOOL)deactivate{
    self.nextBtn.enabled = deactivate;
}
-(void)configureCustomSlider{
    UIImage *circleImage = nil;
    NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];
    NSString *subscriberStr = [SharedPreferenceManager getSubscriber];

    if (self.model.sightPrice > 0 || self.isliveTour == 1 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![_model.baseReceptStr isEqualToString:@""] || subscriberStr) {
        circleImage = [UIImage imageNamed:@"slidercircle"];
        UIColor *deactivateColor = [UIColor colorWithRed:226.0/255.0 green:23.0/255.0 blue:96.0/255.0 alpha:1];
        UIColor *maxtrack = [UIColor colorWithRed:246.0/255.0 green:185.0/255.0 blue:206.0/255.0 alpha:1];
        self.durationLbl.textColor = deactivateColor;
        self.horizonTalSlider.minimumTrackTintColor = deactivateColor;
        self.horizonTalSlider.maximumTrackTintColor = maxtrack;
        [self.playBAckButton setImage:[UIImage imageNamed:@"playBtnIcon"] forState:UIControlStateNormal];
        [self.muteBtn setImage:[UIImage imageNamed:@"soundEnableIcon"] forState:UIControlStateNormal];
        self.playBAckButton.userInteractionEnabled = YES;
        self.horizonTalSlider.userInteractionEnabled = YES;
        self.muteBtn.userInteractionEnabled = YES;
        self.nextBtn.hidden = NO;
    }else{
        self.nextBtn.hidden = YES;
        circleImage = [UIImage imageNamed:@"deactivateCircle"];
        UIColor *deactivateColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1];
        self.durationLbl.textColor = deactivateColor;
        self.horizonTalSlider.minimumTrackTintColor = deactivateColor;
        self.horizonTalSlider.maximumTrackTintColor = deactivateColor;
        [self.playBAckButton setImage:[UIImage imageNamed:@"deactivatePlayBtn"] forState:UIControlStateNormal];
        [self.muteBtn setImage:[UIImage imageNamed:@"deactivateSound"] forState:UIControlStateNormal];
        self.playBAckButton.userInteractionEnabled = NO;
        self.horizonTalSlider.userInteractionEnabled = NO;
        self.muteBtn.userInteractionEnabled = NO;
    }
    [self.horizonTalSlider setThumbImage:circleImage forState:UIControlStateNormal];
    [self.horizonTalSlider setThumbImage:circleImage forState:UIControlStateSelected];
    [self.horizonTalSlider setThumbImage:circleImage forState:UIControlStateApplication];
    [self.horizonTalSlider setThumbImage:circleImage forState:UIControlStateReserved];
}
-(void)showView{
    [self configureCustomSlider];
    [self fullVersionPlayer];
    NSDictionary *dicUserInfo = [SharedPreferenceManager getUserInfo];

    if (self.model.sightPrice > 0 || [dicUserInfo[@"promotion"] integerValue] == 1 || ![_model.baseReceptStr isEqualToString:@""]) {
        [self.playBAckButton setImage:[UIImage imageNamed:@"playBtnIcon"] forState:UIControlStateNormal];
    }else{
         [self.playBAckButton setImage:[UIImage imageNamed:@"deactivatePlayBtn"] forState:UIControlStateNormal];
    }
    self.durationLbl.text = @"0:00";
    self.horizonTalSlider.value = 0.0f;
}
-(void)hideView{
    [self.musicDurationTimer invalidate];
    self.musicDurationTimer = nil;
    [self.player pause];
    self.isPlaying = NO;
}
-(void)addSlideShow{
    self.slideShowObj = [[KASlideShowObj alloc] init];
    self.slideShowObj.slideShowFrame = CGRectMake(0, 0, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
    [self.slideShowObj addPageController];
    [self.sliderView addSubview:self.slideShowObj.slideShow];
}
-(void)setGestureRecognizer{
    self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognaizer:)];
    self.gesture.delegate = self;
    [self addGestureRecognizer:self.gesture];
}
-(void) setUpLockScreen {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        if (playingInfoCenter) {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            if (self.sightFirstImage.image) {
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: self.sightFirstImage.image];
                [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            }

            [songInfo setObject:self.model.sightTitle forKey:MPMediaItemPropertyTitle];
            NSString *authorName = [NSString stringWithFormat:@"Audio Guide"];
            [songInfo setObject:authorName forKey:MPMediaItemPropertyArtist];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
    });
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self addSlideShow];
}
-(void)sightPosterEndHeight:(CGFloat)currentY{
    
}
-(void)nullHysteriaPlayer{
    [self.musicDurationTimer invalidate];
    self.musicDurationTimer = nil;
    [self.player pause];
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    [hysteriaPlayer deprecatePlayer];
    hysteriaPlayer = nil;
}

- (IBAction)getDirection:(UIButton *)sender {
    [self.swipeDelegate getDirection];
}

-(void)setData:(SightModel*)model withHanlde:(void (^)())handler{
    if (!self.isFromTour) {
        self.nextBtn.hidden = YES;
        self.nextBtnWidth.constant = 0;
    }
    
    NSURL *imageURL = [NSURL URLWithString:model.imagesFirst];
    __block typeof(self) blockSelf = self;
    [self.swipeDelegate startPlay];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Do background work
        [blockSelf nullHysteriaPlayer];

        dispatch_async(dispatch_get_main_queue(), ^{
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSLog(@"Do some work");
                //Update UI
                self.player = [[AudioPlayer alloc] init];
                self.player.audioDelegate = self;
                [self.player.hysteriaPlayer seekToTime:0];
                self.model = model;
                if (self.model.audioName_Local && ![self.model.audioName_Local isEqualToString:@""]) {
                    self.player.isLocalFile = YES;
                    self.player.audioStr = @[self.model.audioName_Local];
                }else{
                    self.player.isLocalFile = NO;
                    self.player.audioStr = self.model.audiosFirst;
                    self.player.baseReceptStr = self.model.baseReceptStr;
                }
                if(self.model.audiosFirst == nil || self.model.audiosFirst.count == 0){
                    self.playBAckButton.enabled = NO;
                }
                
                self.sightTitle.text = model.sightTitle;
                self.descriptionLbl.text = model.sightDescription;
                if (model.imagesArray.count == 0) {
                    if (model.imagesFirst) {
                        self.slideShowObj.datasource = @[model.imagesFirst];
                        self.slideShowObj.pageConroller.numberOfPages = 1;
                    }
                }else{
                    self.slideShowObj.datasource = model.imagesArray;
                    self.slideShowObj.pageConroller.numberOfPages = model.imagesArray.count;
                }
                [self.slideShowObj.slideShow reloadData];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                [self.swipeDelegate loadAudio];
                handler();
                [self.sightFirstImage sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (blockSelf.isFromTour && ![blockSelf.model.audioName_Local isEqualToString:@""]) {
                        [blockSelf setUpLockScreen];
                    }
                }];
            });
        });
    });

}
-(void)sightPosterShow:(SightModel*)model withHanlde:(void (^)())handler{
    if (model) {
        [self setData:model withHanlde:^{
            handler();
        }];
    }
}
#pragma mark - Gesture

- (void)gestureRecognaizer:(UIPanGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self];
    CGPoint translation = [sender translationInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startTouchPoint = touchPoint;
//        self.startHeightPsoter = self.heightOfPoster.constant;
        [self.swipeDelegate startSwipe];
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        if(true){
            [self.swipeDelegate swipeDown:(touchPoint.y - self.startTouchPoint.y) withPlaying:NO];
        }else{
//            [self sightPosterChangeHeight:(touchPoint.y - self.startTouchPoint.y)];
            [self.swipeDelegate swipeDown:(touchPoint.y - self.startTouchPoint.y) withPlaying:YES];
        }
    }else if(sender.state == UIGestureRecognizerStateEnded){
        direction = [self determineCameraDirectionIfNeeded:translation];
        int directAlpha = 0;
        if (direction == kCameraMoveDirectionUp) {
            directAlpha = 1;
        }else if(direction == kCameraMoveDirectionDown){
            directAlpha = -1;
        }
        if(!self.isPlaying){
            [self.swipeDelegate swipeEnd:directAlpha withPlaying:NO];
        }else{
            [self.swipeDelegate swipeEnd:directAlpha withPlaying:YES];
        }
    }
}
- (void)showSmallPlayer{
    self.heightConstraintSlider.constant = 0;
    self.sightFirstImage.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.sliderView.alpha = 0;
            self.slideShowObj.slideShow.frame = CGRectMake(0, 0, self.sliderView.frame.size.width, 0);
        self.slideShowObj.slideShow.alpha = 0;
    }];
}
- (void)fullVersionPlayer{
    self.heightConstraintSlider.constant = 204;
    self.sightFirstImage.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.sliderView.alpha = 1;
            self.slideShowObj.slideShow.frame = CGRectMake(0, 0, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
        self.slideShowObj.slideShow.alpha = 1;
    }];
}
// This method will determine whether the direction of the user's swipe

- (CameraMoveDirection)determineCameraDirectionIfNeeded:(CGPoint)translation
{
    
    // determine if horizontal swipe only if you meet some minimum velocity
    
    if (fabs(translation.x) > gestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        
        if (translation.y == 0.0)
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0);
        
        if (gestureHorizontal)
        {
            if (translation.x > 0.0)
                return kCameraMoveDirectionRight;
            else
                return kCameraMoveDirectionLeft;
        }
    }
    // determine if vertical swipe only if you meet some minimum velocity
    
    else if (fabs(translation.y) > gestureMinimumTranslation)
    {
        BOOL gestureVertical = NO;
        
        if (translation.x == 0.0)
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0);
        
        if (gestureVertical)
        {
            if (translation.y > 0.0)
                return kCameraMoveDirectionDown;
            else
                return kCameraMoveDirectionUp;
        }
    }
    
    return direction;
}
-(void)playAuto{
    if (self.isPlaying) {
        [self playBAckButtonTaped:nil];
        [self playBAckButtonTaped:nil];
    }else{
        [self playBAckButtonTaped:nil];
    }
}
#pragma mark - IBAction
- (IBAction)playNextTrack:(UIButton *)sender {
    [self.swipeDelegate nextTreck];

}

- (IBAction)playBAckButtonTaped:(UIButton *)sender {
    if (self.isPlaying) {
        [self.playBAckButton setImage:[UIImage imageNamed:@"playBtnIcon"] forState:UIControlStateNormal];
        [self.player pause];
        self.isPlaying = NO;
    }else{
        [self.playBAckButton setImage:[UIImage imageNamed:@"pauseBtnIcon"] forState:UIControlStateNormal];
        [self.player play];
        self.isPlaying = YES;
    }
}
- (IBAction)didChangeSlider:(UISlider *)sender {
    /*if (self.player.audioPlayer.duration == 0 || self.player.audioPlayer.duration == self.player.audioPlayer.currentTime) {
        self.player.audioPlayer = nil;
        [self setUpPlayback];
    }*/
//    [self.player.audioPlayer setCurrentTime:self.player.hysteriaPlayer.getPlayingItemDurationTime * self.horizonTalSlider.value];
    [self.player.hysteriaPlayer seekToTime:self.player.hysteriaPlayer.getPlayingItemDurationTime *self.horizonTalSlider.value];
    [self updateProgressLabelValue];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
        return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.sliderView]) {
        return NO;
    }
    return YES;
}

#pragma mark - AudioPlayerDelegate

-(void)loadAuido{
    [self setUpTimerForSlider];
    if ([self.model.audioName_Local isEqualToString:@""]) {
        __block typeof(self) blockSelf = self;
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [blockSelf.swipeDelegate loadAudio];
        });
    }
}
-(void)playerReachEnd{
    [self.swipeDelegate playerReachEnd];
}
-(void)errorLoadAudio{
    [self.swipeDelegate errorLoadAudio];
}
-(void)startPlay{
    if ([self.model.audioName_Local isEqualToString:@""]) {
        [self.swipeDelegate startPlay];
    }
}
#pragma mark - Player 
- (void)updateProgressLabelValue {
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    double currentTime = hysteriaPlayer.getPlayingItemCurrentTime;
    double durationTime = hysteriaPlayer.getPlayingItemDurationTime;
    self.durationLbl.text = [self timeIntervalToMMSSFormat:durationTime - currentTime];
}
- (NSString *)timeIntervalToMMSSFormat:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}
-(void) setUpTimerForSlider {
    _musicDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSliderValue:) userInfo:nil repeats:YES];
}
- (void)updateSliderValue:(id)timer {
    if (!self.isPlaying) {
        return;
    }
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    double durationTime = hysteriaPlayer.getPlayingItemDurationTime;
    double currentTime = hysteriaPlayer.getPlayingItemCurrentTime;
    if (durationTime == 0 || durationTime == currentTime) {
        [self.player.audioPlayer stop];
        self.isPlaying = NO;
        [self setStopPlayState];
        [self.horizonTalSlider setValue:0.0f animated:NO];
        [self updateProgressLabelValue];
        [self.player.audioPlayer setCurrentTime:0];
    }
    if (durationTime == 0.0) {
        [self.horizonTalSlider setValue:0.0f animated:NO];
    }
    else {
        if (currentTime >= durationTime) {
            self.player.audioPlayer.currentTime -= self.player.audioPlayer.duration;
        }
        [self.horizonTalSlider setValue:currentTime / durationTime animated:YES];
        [self updateProgressLabelValue];
    }
}
-(void) setStopPlayState {
    if (self.isPlaying) {
        [self.playBAckButton setImage:[UIImage imageNamed:@"pauseBtnIcon"] forState:UIControlStateNormal];
    } else {
        [self.playBAckButton setImage:[UIImage imageNamed:@"playBtnIcon"] forState:UIControlStateNormal];
    }
}
@end
