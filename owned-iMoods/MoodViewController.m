//
//  ViewController.m
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "MoodViewController.h"
#import "Moi.h"
#import "Masonry.h"

@interface MoodViewController ()

@property (nonatomic, weak) UIPickerView *picker;
@property (nonatomic, weak) NSString *currentMood;

@end

static NSArray *kMoods;
static NSArray *kMoodColors;

@implementation MoodViewController

+ (NSArray *)moods
{
    
    if (!kMoods) {
        kMoods = @[@"Happy", @"Sad", @"Moody", @"Insane"];
    }
    return kMoods;
}

+ (NSArray *)moodColors
{
    if (!kMoodColors) {
        kMoodColors = @[[UIColor colorWithRed:0.187 green:0.856 blue:0.220 alpha:1.000],
                        [UIColor colorWithRed:0.644 green:0.644 blue:0.000 alpha:1.000],
                        [UIColor colorWithRed:0.271 green:0.270 blue:0.500 alpha:1.000],
                        [UIColor colorWithRed:0.802 green:0.000 blue:0.000 alpha:1.000]];
    }
    return kMoodColors;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"My Mood";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"iMoods"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = leftButton;
    
	
    UIPickerView *picker = [[UIPickerView alloc] init];
    _picker = picker;
    picker.delegate = self;
    [self.view addSubview:picker];
    
    // Find the current selection
    NSString *mood = [Moi sharedMoi].mood;
    if (mood) {
        [picker selectRow:[kMoods indexOfObject:mood] inComponent:0 animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Handle when the back button is tapped
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSString *newMood = kMoods[[self.picker selectedRowInComponent:0]];
        [Moi sharedMoi].mood = newMood;
    }
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Update constraints on init and orientation changes
    [self updateViewConstraints];
}


- (void)updateViewConstraints
{
    UIView *superview = self.view;
    
    [self.picker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(superview);
    }];
    
    [super updateViewConstraints];
}
     
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return kMoods.count;
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return kMoods[row];
}

@end
