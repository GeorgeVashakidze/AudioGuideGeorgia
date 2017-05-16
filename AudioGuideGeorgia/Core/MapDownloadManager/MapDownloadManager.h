//
//  MapDownloadManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 4/18/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Mapbox;


@protocol MapDownloadDelegate <NSObject>

-(void)progressDownload:(float)progress;
-(void)finishedDownload;
@end

@interface MapDownloadManager : NSObject
@property MGLCoordinateBounds boundsOfTbilisi;
@property (weak,nonatomic) id<MapDownloadDelegate> downloadDelegate;
-(void)startDownload;
@end
