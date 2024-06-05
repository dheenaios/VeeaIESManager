//
//  WiFiHelpers.m
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/12/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

#import "WiFiHelpers.h"

@implementation WiFiHelpers

+ (NSString *_Nullable)getDeviceSSID {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
            break;
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

@end
