//
//  InAppPurchaseManager.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/27/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PurchaseDelagate <NSObject>

- (void)completedBuy:(NSString*)base64Recept;
- (void)faildBuy:(NSString*)error;
- (void)updatePrice:(NSDecimalNumber*)price;
- (void)updateSubscriberPrice:(NSDecimalNumber*)price;
@end

@interface InAppPurchaseManager : NSObject
@property (nonatomic, weak) id <PurchaseDelagate> delegate;
@property (nonatomic, assign) BOOL restorePurchaseMode;
@property BOOL buyTour;
- (void) getInAppDetails;
- (void)setProductIDStr:(NSString *)productID;
- (void) restorePurchase;
@end
