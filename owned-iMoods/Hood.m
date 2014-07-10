//
//  Hood.m
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "Hood.h"
#import "Neighbor.h"
#import "Moi.h"

@implementation Hood

+ (instancetype)sharedHood
{
    static Hood *_sharedHood = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHood = [[Hood alloc] init];
    });
    
    return _sharedHood;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _neighbors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setMoodService:(NSNetService *)moodService
{
    _moodService = moodService;
    // Make sure that TXT is set properly
    [[Moi sharedMoi] refreshTXT];
}

- (void)addNeighborFromService:(NSNetService *)service
{
    [self.neighbors addObject:[[Neighbor alloc] initFromService:service]];
}

- (void)removeNeighborForService:(NSNetService *)service
{
    NSUInteger index = [self.neighbors indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Neighbor *neighbor = (Neighbor *)obj;
        return [neighbor.service isEqual:service];
    }];
    
    if (index != NSNotFound) {
        [self.neighbors removeObjectAtIndex:index];
    }
}

- (void)sortNeighbors
{
    [self.neighbors sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

@end
