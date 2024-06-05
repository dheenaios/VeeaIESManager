//
//  CryptoWrapper.m
//  HubLibrary
//
//  Created by Al on 06/06/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

#import "CryptoWrapper.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation CryptoWrapper

+ (NSData*) hashBytesFromBytes:(NSData*)inputData {
    NSMutableData* digest;
    
    digest = [[NSMutableData alloc] initWithLength:CC_SHA1_DIGEST_LENGTH];
    (void) CC_SHA1(inputData.bytes, (CC_LONG)inputData.length, digest.mutableBytes);
    
    return digest;
}

@end
