//
//  Moi.m
//  owned-iMoods
//
//  Created by Huy on 7/9/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "Moi.h"
#import "Hood.h"
#import "UIApplication+utilities.h"

@interface Moi ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation Moi

+ (instancetype)sharedMoi
{
    static Moi *_sharedMoi = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMoi = [[Moi alloc] init];
    });
    
    return _sharedMoi;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Generate a unique ID so that we recognize ourselves
        NSString *uuid = [[UIApplication sharedApplication] applicationUUID];
        NSData *data = [uuid dataUsingEncoding:NSUTF8StringEncoding];
        _dict = [NSMutableDictionary dictionaryWithObject:data forKey:kIdKey];
        
        // Subscribe to changes in defaults
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadDefaults)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        // Make sure the TXT has at least the ID
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:self.dict];
        [[Hood sharedHood].moodService setTXTRecordData:txtData];
    }
    return self;
}

// Before (re-)publishing, the TXT needs to be refreshed
- (void)refreshTXT
{
    // Force refresh of TXT by nilling the name and mood before reloading
    _name = nil;
    _mood = nil;
    [self reloadDefaults];
}

- (void)reloadDefaults
{
    // Get the name & mood from settings
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mood = [standardUserDefaults objectForKey:kMoodKey];
    if (mood) {
        self.mood = mood;
    }
    NSString *name = [standardUserDefaults objectForKey:kNameKey];
    if (name) {
        self.name = name;
    }
}

- (void)setName:(NSString *)name
{
    if (![_name isEqualToString:name]) {
        _name = name;
        
        // Update the TXT
        NSData *data = [name dataUsingEncoding:NSUTF8StringEncoding];
        [self.dict setValue:data forKey:kNameKey];
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:self.dict];
        [[Hood sharedHood].moodService setTXTRecordData:txtData];
        NSLog(@"updating TXT for name");
        
        // Save the preference
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:name forKey:kNameKey];
        [standardUserDefaults synchronize];
    }
}

- (void)setMood:(NSString *)mood
{
    if (![_mood isEqualToString:mood]) {
        _mood = mood;
        
        // Update the TXT
        NSData *data = [mood dataUsingEncoding:NSUTF8StringEncoding];
        [self.dict setValue:data forKey:kMoodKey];
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:self.dict];
        [[Hood sharedHood].moodService setTXTRecordData:txtData];
        NSLog(@"updating TXT for mood");
        
        // Save the preference
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:mood forKey:kMoodKey];
        [standardUserDefaults synchronize];
    }
}

@end
