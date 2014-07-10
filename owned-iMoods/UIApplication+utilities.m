//
//  UIApplication+utilities.m
//  owned-iMoods
//
//  Created by Huy on 7/9/14.
//  Copyright (c) 2014 huy. All rights reserved.
//
// From http://stackoverflow.com/a/15835190/161972

#import "UIApplication+utilities.h"

@implementation UIApplication (utilities)

+ (NSString *)UUID {
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}


- (NSString *)applicationUUID
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    static NSString *uuid = nil;
    
    // try to get the NSUserDefault identifier if exist
    if (uuid == nil) {
        uuid = [standardUserDefaults objectForKey:kIdKey];
    }
    
    // if there is not NSUserDefault identifier generate one and store it
    if (uuid == nil) {
        uuid = [UIApplication UUID];
        [standardUserDefaults setObject:uuid forKey:kIdKey];
        [standardUserDefaults synchronize];
    }
    
    return uuid;
}

@end