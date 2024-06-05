//
//  CryptoWrapper.h
//  HubLibrary
//
//  Created by Al on 06/06/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoWrapper : NSObject

+ (NSData*_Nonnull) hashBytesFromBytes:(NSData*_Nonnull)inputData ;

@end
