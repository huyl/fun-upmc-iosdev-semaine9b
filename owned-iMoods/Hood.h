//
//  Hood.h
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Neighbor.h"

@interface Hood : NSObject

+ (instancetype)sharedHood;

- (void)addNeighborFromService:(NSNetService *)service;
- (void)removeNeighborForService:(NSNetService *)service;
- (void)sortNeighbors;

@property (nonatomic, strong) NSMutableArray *neighbors;
@property (nonatomic, strong) NSNetService *moodService;

@end
