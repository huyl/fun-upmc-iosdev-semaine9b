//
//  HoodTableViewController.h
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoodViewController.h"

@interface HoodTableViewController : UITableViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    NSNetServiceBrowserDelegate,
    NSNetServiceDelegate
>

@property (nonatomic, weak) MoodViewController *moodVC;

@end
