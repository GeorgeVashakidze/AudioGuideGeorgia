//
//  AudioPlayer.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/26/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "AudioPlayer.h"
#import "SharedPreferenceManager.h"

@implementation AudioPlayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hysteriaPlayer = [HysteriaPlayer sharedInstance];
        self.hysteriaPlayer.delegate = self;
        self.hysteriaPlayer.datasource = self;
        [self.hysteriaPlayer setPlayerRepeatMode:HysteriaPlayerRepeatModeOff];
    }
    return self;
}
-(void)play{
    double currentTime = self.hysteriaPlayer.getPlayingItemCurrentTime;
    if(currentTime > 0){
        [self.hysteriaPlayer play];
    }else{
        [self.audioDelegate startPlay];
        [self.hysteriaPlayer fetchAndPlayPlayerItem:0];
    }
}
-(void)pause{
    [self.hysteriaPlayer pause];
}
#pragma mark - HysteriaPlayer
-(NSInteger)hysteriaPlayerNumberOfItems{
    return self.audioStr.count;
}

- (NSURL *)hysteriaPlayerURLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer
{
    NSString *strURL = self.audioStr[index];
    if (self.isLocalFile) {
        NSString *suportFileUrl = [[[self applicationDirectory] stringByAppendingString:@"/"] stringByAppendingString:strURL];
        NSURL *urlLocalFile = [[NSURL alloc] initFileURLWithPath:suportFileUrl];
        return urlLocalFile;
    }else{
        NSString *token = [SharedPreferenceManager getUserToken];
        NSString *urlRemote = strURL;
        if (token) {
            urlRemote = [[strURL stringByAppendingString:@"?token="] stringByAppendingString:token];
            return [NSURL URLWithString:urlRemote];
        }
        if (self.baseReceptStr) {
            if (![self.baseReceptStr isEqualToString:@""]) {
                urlRemote = [[strURL stringByAppendingString:@"?receipt="] stringByAppendingString:self.baseReceptStr];
            }else{
                NSString *subscriberStr = [SharedPreferenceManager getSubscriber];
                if (subscriberStr) {
                    urlRemote = [[strURL stringByAppendingString:@"?receipt="] stringByAppendingString:subscriberStr];
                }
            }
        }
        return [NSURL URLWithString:urlRemote];
    }
}
- (NSString*)applicationDirectory
{
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager*fm = [NSFileManager defaultManager];
    NSString *dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    if ([appSupportDir count] > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] stringByAppendingPathComponent:bundleID] ;
        
        
        
        // If the directory does not exist, this method creates it.
        NSError* theError = nil;
        if(![fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&theError]){
            //NSlog(@"error");
        }
    }
    
    return dirPath;
}

-(void)hysteriaPlayerDidReachEnd{
    //End play
    [self.audioDelegate playerReachEnd];
}

-(void)hysteriaPlayerWillChangedAtIndex:(NSInteger)index{
    //Change player
}
-(void)hysteriaPlayerCurrentItemPreloaded:(CMTime)time{
    
}
-(void)hysteriaPlayerDidFailed:(HysteriaPlayerFailed)identifier error:(NSError *)error{
    [self.audioDelegate errorLoadAudio];
}
-(void)hysteriaPlayerReadyToPlay:(HysteriaPlayerReadyToPlay)identifier{
    NSLog(@"ready");
    if (identifier == HysteriaPlayerReadyToPlayCurrentItem) {
        [self.audioDelegate loadAuido];
    }
}

@end
