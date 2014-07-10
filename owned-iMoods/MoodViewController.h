//
//  ViewController.h
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodViewController : UIViewController <UIPickerViewDelegate>

+ (NSArray *)moods;
+ (NSArray *)moodColors;

@end
