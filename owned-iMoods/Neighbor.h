//
//  Neighbor.h
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Neighbor : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *mood;
@property (nonatomic, readonly) NSString *applicationId;
@property (nonatomic, strong) NSNetService *service;

- (instancetype)initFromService:(NSNetService *)service;

@end
