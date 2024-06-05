//
//  WiFiHelpers.h
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/12/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface WiFiHelpers : NSObject

+ (NSString *_Nullable)getDeviceSSID;

@end



NS_ASSUME_NONNULL_END
