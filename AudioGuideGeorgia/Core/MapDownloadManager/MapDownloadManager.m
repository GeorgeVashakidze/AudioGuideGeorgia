//
//  MapDownloadManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "MapDownloadManager.h"
#import "SharedPreferenceManager.h"
@implementation MapDownloadManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.boundsOfTbilisi = MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(41.67968479690831, 44.72889400303364), CLLocationCoordinate2DMake(41.78746883330748, 44.83136498808861));
        [self registerNotifications];
    }
    return self;
}



-(void)registerNotifications{
    // Setup offline pack notification handlers.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackProgressDidChange:) name:MGLOfflinePackProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveError:) name:MGLOfflinePackErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveMaximumAllowedMapboxTiles:) name:MGLOfflinePackMaximumMapboxTilesReachedNotification object:nil];
}
- (void)dealloc {
    // Remove offline pack observers.
    NSLog(@"Dealloc MapDownloadManager");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)startDownload{
    [self startOfflinePackDownload];
}
- (void)startOfflinePackDownload {
    NSURL *stileURl = [NSURL URLWithString:@"mapbox://styles/getso1985/cizkbn8ow000e2spoanibbuvw"];
    id <MGLOfflineRegion> regionTbilisi = [[MGLTilePyramidOfflineRegion alloc] initWithStyleURL:stileURl bounds:self.boundsOfTbilisi fromZoomLevel:7 toZoomLevel:16];
    
    // Store some data for identification purposes alongside the downloaded resources.
    NSDictionary *userInfo = @{ @"name": @"Tbilisi Offline pack" };
    NSData *context = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    // Create and register an offline pack with the shared offline storage object.
    NSArray<MGLOfflinePack*>*pack =  [[MGLOfflineStorage sharedOfflineStorage] packs];
    if (pack.count == 0) {
        [self downloadPack:regionTbilisi andCOntext:context];
    }else{
        MGLOfflinePack *offlinepack = pack[0];
        [offlinepack requestProgress];
    }

}
-(void)downloadPack:(id <MGLOfflineRegion>)region andCOntext:(NSData*)context{
    [[MGLOfflineStorage sharedOfflineStorage] addPackForRegion:region withContext:context completionHandler:^(MGLOfflinePack *pack, NSError *error) {
        if (error != nil) {
            // The pack couldn’t be created for some reason.
            NSLog(@"Error: %@", error.localizedFailureReason);
        } else {
            // Start downloading.
            [pack resume];
        }
    }];
}
#pragma mark - MGLOfflinePack notification handlers

- (void)offlinePackProgressDidChange:(NSNotification *)notification {
    MGLOfflinePack *pack = notification.object;
    
    // Get the associated user info for the pack; in this case, `name = My Offline Pack`
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    
    MGLOfflinePackProgress progress = pack.progress;
    // or [notification.userInfo[MGLOfflinePackProgressUserInfoKey] MGLOfflinePackProgressValue]
    uint64_t completedResources = progress.countOfResourcesCompleted;
    uint64_t expectedResources = progress.countOfResourcesExpected;
    
    // Calculate current progress percentage.
    float progressPercentage = (float)completedResources / expectedResources;
    [self.downloadDelegate progressDownload:progressPercentage];
    
    // If this pack has finished, print its size and resource count.
    if (completedResources == expectedResources) {
//        NSString *byteCount = [NSByteCountFormatter stringFromByteCount:progress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
        [self.downloadDelegate finishedDownload];
        [SharedPreferenceManager saveDownloadPack:[NSNumber numberWithBool:YES]];
    } else {
        // Otherwise, print download/verification progress.
//        NSLog(@"Offline pack “%@” has %llu of %llu resources — %.2f%%.", userInfo[@"name"], completedResources, expectedResources, progressPercentage * 100);
    }
}

- (void)offlinePackDidReceiveError:(NSNotification *)notification {
   
}

- (void)offlinePackDidReceiveMaximumAllowedMapboxTiles:(NSNotification *)notification {

}

@end
