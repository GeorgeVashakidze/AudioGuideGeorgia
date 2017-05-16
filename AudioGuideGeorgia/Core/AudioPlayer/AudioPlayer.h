//
//  AudioPlayer.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/26/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <HysteriaPlayer/HysteriaPlayer.h>

@protocol AudioPlayerDelegate <NSObject>
-(void)errorLoadAudio;
-(void)loadAuido;
-(void)startPlay;
-(void)playerReachEnd;
@end

@interface AudioPlayer : NSObject<HysteriaPlayerDelegate, HysteriaPlayerDataSource>
@property AVAudioPlayer *audioPlayer;
@property (weak,nonatomic) id<AudioPlayerDelegate> audioDelegate;
@property NSArray<NSString*>* audioStr;
@property HysteriaPlayer *hysteriaPlayer;
@property BOOL isLocalFile;
@property NSString *baseReceptStr;
- (void) play;
- (void) pause;
@end
