//
//  Moi.h
//  owned-iMoods
//
//  Created by Huy on 7/9/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Moi : NSObject

+ (instancetype)sharedMoi;
- (void)refreshTXT;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mood;

@end
