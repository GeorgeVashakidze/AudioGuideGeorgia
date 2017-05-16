//
//  InAppPurchaseManager.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 3/27/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

@import StoreKit;

#import "InAppPurchaseManager.h"
#import "ServiceManager.h"
#import "SharedPreferenceManager.h"

@interface InAppPurchaseManager()<SKPaymentTransactionObserver, SKProductsRequestDelegate,ServicesManagerDelegate>{
    SKProductsRequest * productRequest;
    SKProduct         * proUserProduct;
    SKProduct         * subscriberProduct;

    NSString          * proUserInappKey;
    NSString          * subscriberInappKey;

    BOOL transactionObserverAdded;
    BOOL complitedTransaction;
    ServiceManager *manager;
    
    int restoreCount;
    int restoreProductCount;
}

@property NSMutableArray *restoreProductsID;
@end

@implementation InAppPurchaseManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        transactionObserverAdded = NO;
        manager = [[ServiceManager alloc] init];
        manager.delegate = self;
        restoreCount = 0;
        restoreProductCount = 0;
        _restoreProductsID = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)setProductIDStr:(NSString *)productID{
    proUserInappKey = [@"audio.guide.georgia.AudioGuideGeorgia." stringByAppendingString:productID];
    subscriberInappKey = @"audio.guide.georgia.AudioGuideGeorgia.subscriber";
}
- (void)dealloc
{
    if ( transactionObserverAdded )
    {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
    
    if (    productRequest
        && productRequest.delegate
        )
    {
        productRequest.delegate = nil;
        [productRequest cancel];
    }
}
//------------------------------------------------------/ getInAppDetails /-----
- (void) getInAppDetails
{
    if ( [SKPaymentQueue canMakePayments] )
    {
        NSMutableSet * productIdSet = [[NSMutableSet alloc] init];
        [productIdSet addObject:proUserInappKey];
        [productIdSet addObject:subscriberInappKey];
        productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
        productRequest.delegate = self;
        [productRequest start];
        NSLog(@"can make payments");
    }
    else
    {
        
    }
}
//-----------------------------------------------/ addTransactionObserver /-----
- (void) addTransactionObserver
{
    if ( ! transactionObserverAdded )
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        transactionObserverAdded = YES;
    }
}
//---------------------------------------------------------/ upgradeToPro /-----
- (void) upgradeToPro
{
    if (proUserProduct) {
        SKPayment * payment = [SKPayment paymentWithProduct:proUserProduct];
        if (!_buyTour) {
            payment = [SKPayment paymentWithProduct:subscriberProduct];
        }
        [self addTransactionObserver];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
        [_delegate faildBuy:@"This product dont exist"];
    }
    

}
//------------------------------------------------------/ restorePurchase /-----
- (void) restorePurchase
{
    if ( ! [SKPaymentQueue canMakePayments] )
    {
        
    }
    else
    {
        [self addTransactionObserver];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if (response.products.count == 0) {
        [self.delegate faildBuy:@""];
    }
    for ( SKProduct * product in response.products )
    {
        if ( [product.productIdentifier isEqualToString:proUserInappKey] )
        {
            proUserProduct = product;
            NSLog(@"Product Request");
//            [self upgradeToPro];
            [self.delegate updatePrice:proUserProduct.price];
        }
        if ([product.productIdentifier isEqualToString:subscriberInappKey]) {
            subscriberProduct = product;
            [self.delegate updateSubscriberPrice:subscriberProduct.price];
        }
    }
}

#pragma mark - Restore Purchase Delegates
//For restore if faild need buy transaction
-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(nonnull NSError *)error{
    if (error) {
        [self upgradeToPro];
    }
}
-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for ( SKPaymentTransaction * transaction in transactions )
    {
        if ( ! [transaction.payment.productIdentifier isEqualToString:proUserInappKey] && _buyTour)
        {
            continue;
        }else if(! [transaction.payment.productIdentifier isEqualToString:subscriberInappKey] && !_buyTour){
            continue;
        }
        
        switch ( transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStatePurchased:{
                //Finished payment
                NSData *transactionRecept = transaction.transactionReceipt;
                [self setReceptToserver:transactionRecept withTourID:0];

                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
                //Error transaction
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self.delegate faildBuy:transaction.error.localizedDescription];
                break;
                
            case SKPaymentTransactionStateRestored:{
                //Purchase compledted but not pay restore
                NSData *transactionRecept = transaction.transactionReceipt;
                [self setReceptToserver:transactionRecept withTourID:0];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateDeferred:
                //Error Parental controll not impement
                [self.delegate faildBuy:@""];
                break;
                
            default:
                break;
        }
    }

}
-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
    if (_restorePurchaseMode) {
        for ( SKPaymentTransaction * transaction in queue.transactions )
        {
            if ( [transaction.payment.productIdentifier isEqualToString:@"audio.guide.georgia.AudioGuideGeorgia.subscriber"] )
            {
                if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                    //Restore Subscriber user
                    _buyTour = NO;
                    restoreProductCount = 1;
                    NSData *transactionRecept = transaction.transactionReceipt;
                    [self setReceptToserver:transactionRecept withTourID:0];
                    return;
                }
            }
        }
        restoreProductCount = 0;
        for ( SKPaymentTransaction * transaction in queue.transactions )
        {
            if (transaction.originalTransaction.transactionState == SKPaymentTransactionStateRestored) {
                //Restore Subscriber user
                NSString *tourID = [transaction.payment.productIdentifier substringFromIndex:38];
                int intTourID = [tourID intValue];
                if (intTourID != 0 && ![_restoreProductsID containsObject:[NSNumber numberWithInt:intTourID]]) {
                    [_restoreProductsID addObject:[NSNumber numberWithInt:intTourID]];
                    restoreProductCount += 1;
                }
                
            }
        }
        [_restoreProductsID removeAllObjects];
        for ( SKPaymentTransaction * transaction in queue.transactions )
        {
                if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                    //Restore Subscriber user
                    NSString *tourID = [transaction.payment.productIdentifier substringFromIndex:38];
                    int intTourID = [tourID intValue];
                    NSData *transactionRecept = transaction.transactionReceipt;
                    if (intTourID != 0 && ![_restoreProductsID containsObject:[NSNumber numberWithInt:intTourID]]) {
                        [_restoreProductsID addObject:[NSNumber numberWithInt:intTourID]];
                        [self setReceptToserver:transactionRecept withTourID:intTourID];
                    }
                    NSLog(@"%d",intTourID);
                    
                }
        }
        return;
    }
    
    if (!_buyTour) {
        for ( SKPaymentTransaction * transaction in queue.transactions )
        {
            if ( [transaction.payment.productIdentifier isEqualToString:subscriberInappKey] )
            {
                if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                    NSData *transactionRecept = transaction.transactionReceipt;
                    if (transactionRecept) {
                        [self setReceptToserver:transactionRecept withTourID:0];
                        return;
                    }
                }
            }
        }
    }
    

    if (_buyTour) {
        for ( SKPaymentTransaction * transaction in queue.transactions )
        {
            if ( [transaction.payment.productIdentifier isEqualToString:proUserInappKey] )
            {
                if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                    NSData *transactionRecept = transaction.transactionReceipt;
                    if (transactionRecept) {
                        [self setReceptToserver:transactionRecept withTourID:0];
                        return;
                    }
                }
                
            }
            
        }
    }
    [self upgradeToPro];
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads{
    
}
#pragma mark - ServiceManager 
-(void)setReceptToserver:(NSData*)dataReceept withTourID:(int)tourID{
    if (_restorePurchaseMode) {
        [manager setReceptToServer:dataReceept withToken:@"" withTourID:tourID];
    }
    if (!complitedTransaction && !_restorePurchaseMode) {
        complitedTransaction = YES;
        [manager setReceptToServer:dataReceept withToken:@"" withTourID:tourID];
        if (!_buyTour) {
            [SharedPreferenceManager saveSubscriber:[dataReceept base64EncodedStringWithOptions:0]];            
        }
    }
}
-(void)setRecept:(NSDictionary *)recept withBase64:(NSString *)base64REcept withTourID:(int)tourID{
    if (self.restorePurchaseMode) {
        [manager updateTourToRestore:tourID withTourRecept:base64REcept];
        restoreCount += 1;
        if (restoreCount == restoreProductCount) {
            [self.delegate completedBuy:@""];
        }
    }else{
        [self.delegate completedBuy:base64REcept];
    }
    if (!_buyTour) {
        [manager updateAllTourToDelete];
    }
}
-(void)errorSetRecept:(NSError *)error{
    [self.delegate faildBuy:@""];
}
@end
