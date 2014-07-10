//
//  HoodTableViewController.m
//  owned-iMoods
//
//  Created by Huy on 7/8/14.
//  Copyright (c) 2014 huy. All rights reserved.
//

#import "HoodTableViewController.h"
#import "MoodViewController.h"
#import "Hood.h"
#import "Neighbor.h"
#import "UIApplication+utilities.h"
#import "Moi.h"

@interface HoodTableViewController ()

@property (nonatomic, strong) NSNetServiceBrowser *moodBrowser;

@end

@implementation HoodTableViewController 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"iMoods";
        self.tableView.allowsSelection = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"My Mood"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self setupRAC];
    
    // Pause service when in background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    // Publish service
    NSNetService *moodService = [[NSNetService alloc] initWithDomain:@"local"
                                                                type:kServiceType
                                                                name:[[UIDevice currentDevice] name]
                                                                port:9090];
    [Hood sharedHood].moodService = moodService;
    moodService.delegate = self;
    // Enable Bonjour through Bluetooth
    moodService.includesPeerToPeer = YES;
    [moodService publish];
    
    // Search for service
    NSNetServiceBrowser *moodBrowser = [[NSNetServiceBrowser alloc] init];
    self.moodBrowser = moodBrowser;
    moodBrowser.delegate = self;
    moodBrowser.includesPeerToPeer = YES;
    [moodBrowser searchForServicesOfType:kServiceType inDomain:@"local"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RAC

- (void)setupRAC
{
    @weakify(self);
    
    // React to MyMood button click
    self.navigationItem.rightBarButtonItem.rac_action = [[RACSignal create:^(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        [self.navigationController pushViewController:self.moodVC animated:YES];
        
        [subscriber sendCompleted];
    }] action];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == 0 ? [Hood sharedHood].neighbors.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"any";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    NSArray *neighbors = [Hood sharedHood].neighbors;
    Neighbor *neighbor = neighbors[indexPath.row];
    
    // Check if this is me.  TODO: Is this the best that can be done?
    if ([neighbor.applicationId isEqualToString:[[UIApplication sharedApplication] applicationUUID]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (moi)", neighbor.name];
    } else {
        cell.textLabel.text = neighbor.name;
    }
    
    cell.detailTextLabel.text = neighbor.mood;
    NSUInteger moodIndex = [[MoodViewController moods] indexOfObject:neighbor.mood];
    if (moodIndex != NSNotFound) {
        cell.detailTextLabel.textColor = [MoodViewController moodColors][moodIndex];
    } else {
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    NSLog(@"Service found: %@", cell.textLabel.text);
    
    
    return cell;
}

#pragma mark - NetServiceDelegate

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    if (data) {
        // Refresh since the TXT was updated in one of the services
        [self.tableView reloadData];
    }
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
          [service domain], [service type], [service name], (int)[service port]);
}


- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
         [service domain], [service type], [service name], errorDict);
}

#pragma mark - NetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [[Hood sharedHood] addNeighborFromService:aNetService];
    aNetService.delegate = self;
    [aNetService startMonitoring];
    
    if (!moreComing) {
        // Sort Services
        [[Hood sharedHood] sortNeighbors];
        
        // Update Table View
        [self.tableView reloadData];
    }

}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [aNetService stopMonitoring];
    [[Hood sharedHood] removeNeighborForService:aNetService];
    
    if (!moreComing) {
        // Update Table View
        [self.tableView reloadData];
    }
}

#pragma mark - UIApplicationDidEnterBackgroundNotification

- (void)appDidEnterBackgroundNotification:(NSNotification *)notification
{
    // This may be unnecessary as the default is that the service is stopped
    [[Hood sharedHood].moodService stop];
    [self.moodBrowser stop];
}

// FIXME: when returning to foreground we seem to be publishing with our default name and then our preferred name.
// It's even worse when we change the name in the Settings: we publish with default name, then old preferred name,
// then new preferred name.
- (void)appWillEnterForegroundNotification:(NSNotification *)notification
{
    // Restart services and search
    [[Moi sharedMoi] refreshTXT];
    [[Hood sharedHood].moodService publish];
    
    // We have to remove all services because they're going to be all different
    [[Hood sharedHood].neighbors removeAllObjects];
    
    [self.moodBrowser searchForServicesOfType:kServiceType inDomain:@"local"];
}


@end
