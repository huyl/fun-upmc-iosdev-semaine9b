//
//  Neighbor.m
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "Neighbor.h"

@implementation Neighbor

- (instancetype)initFromService:(NSNetService *)service;
{
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (NSString *)name
{
    NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]];
    NSData *nameData = [dict objectForKey:kNameKey];
    if (nameData) {
        NSString *name = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
        // Check that name is more than just whitespace
        if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            return name;
        }
    }
    return self.service.name;
}

- (NSString *)mood
{
    NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]];
    NSData *moodData = [dict objectForKey:kMoodKey];
    if (moodData) {
        return [[NSString alloc] initWithData:moodData encoding:NSUTF8StringEncoding];
    } else {
        return @"...";
    }
}

- (NSString *)applicationId
{
    NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]];
    NSData *idData = [dict objectForKey:kIdKey];
    if (idData) {
        return [[NSString alloc] initWithData:idData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

@end
