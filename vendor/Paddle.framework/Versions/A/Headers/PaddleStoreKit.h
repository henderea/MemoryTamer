//
//  PaddleStoreKit.h
//  PaddleIAPDemo
//
//  Created by Louis Harwood on 10/05/2014.
//  Copyright (c) 2014 Paddle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSKReceipt.h"

typedef enum productTypes
{
    PSKConsumableProduct,
    PSKNonConsumableProduct
} ProductType;

@protocol PaddleStoreKitDelegate <NSObject>

- (void)PSKProductPurchased:(PSKReceipt *)transactionReceipt;
- (void)PSKDidFailWithError:(NSError *)error;
- (void)PSKDidCancel;

@end

@class PSKPurchaseWindowController;
@class PSKStoreWindowController;
@class PSKProductWindowController;

@interface PaddleStoreKit : NSObject {
    id <PaddleStoreKitDelegate> delegate;
    PSKPurchaseWindowController *purchaseWindow;
    PSKStoreWindowController *storeWindow;
    PSKProductWindowController *productWindow;
}

@property (assign) id <PaddleStoreKitDelegate> delegate;
@property (nonatomic, retain) PSKPurchaseWindowController *purchaseWindow;
@property (nonatomic, retain) PSKStoreWindowController *storeWindow;
@property (nonatomic, retain) PSKProductWindowController *productWindow;

+ (PaddleStoreKit *)sharedInstance;

//Store View
- (void)showStoreView;
- (void)showStoreViewForProductType:(ProductType)productType;
- (void)showStoreViewForProductIds:(NSArray *)productIds;


//Product View
- (void)showProduct:(NSString *)productId;

//Purchase View
- (void)purchaseProduct:(NSString *)productId;

//Receipts
- (NSArray *)validReceipts;
- (PSKReceipt *)receiptForProductId:(NSString *)productId;



@end
