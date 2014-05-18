//
//  ViewController.m
//  BagTracker
//
//  Created by Scott Newman on 5/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // Make sure that default settings are created if needed
    [self retrieveSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Interface Methods

- (IBAction)toggleSwitch:(id)sender
{
    UISwitch *mySwitch = sender;

    if (mySwitch.isOn) {
        NSLog(@"Start Monitoring");
        
        // Load the beacon region
        self.beaconRegion = [self beaconRegionForSettings];
        
        // Ask for the state
        [self.locationManager requestStateForRegion:self.beaconRegion];
        
        // Start the region monitoring
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        
    }
    else {
        NSLog(@"Stop Monitoring");

        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];

        self.distanceLabel.text = @"--";
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region");
    [self createNotification:@"Your Bag is Nearby"];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Left region");
    [self createNotification:@"Your Bag is Gone"];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.distanceLabel.text = @"--";
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // We have to use this delegate method in the case that region monitoring start but
    // core location thinks we are already inside a region
    
    switch(state) {
        case CLRegionStateInside:
            NSLog(@"CLRegionStateInside");
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            break;
        case CLRegionStateOutside:
            [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
            NSLog(@"CLRegionStateOutside");
            break;
        case CLRegionStateUnknown:
            NSLog(@"CLRegionStateUnknown");
            break;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons lastObject];
    CGFloat accuracy = beacon.accuracy;
    
    if (accuracy > 0)
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f", beacon.accuracy];
    else
        self.distanceLabel.text = @"--";

}

#pragma mark - Local Notifications

- (void)createNotification:(NSString *)message
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = message;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

#pragma mark - Settings Methods

- (CLBeaconRegion *)beaconRegionForSettings
{
    NSDictionary *settings = [self retrieveSettings];
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:settings[@"uuid"]];
    NSInteger major = [settings[@"major"] integerValue];
    NSInteger minor = [settings[@"minor"] integerValue];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                     major:major
                                                                     minor:minor
                                                                identifier:@"com.getnewman.BagTracker"];
    
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;
    
    return region;
}

- (NSDictionary *)retrieveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If our values are not in NSUserDefaults, register the default values
    if (![defaults stringForKey:@"uuid"]) {
    
        NSLog(@"Setting Default Values");
        
        NSDictionary *defaultPreferences = @{
            @"uuid": @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6",
            @"major": @(1),
            @"minor": @(1),
        };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
    // Return the settings
    NSDictionary *settingsDict = [defaults dictionaryWithValuesForKeys:@[@"uuid", @"major", @"minor"]];
    return settingsDict;
    
}

#pragma mark - Storyboard Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SettingsSegue"])
    {
        UINavigationController *nav = [segue destinationViewController];
        SettingsViewController *vc = [[nav childViewControllers] firstObject];
        vc.delegate = self;
    }
}

#pragma mark - SettingsDelegate methods

- (void)didUpdateSettings
{
    // If the switch is on, that means that it's monitoring with the settings
    // that were in place before the user updated. We need to stop monitoring,
    // reload the settings, and start monitoring again.
    
    if (self.trackingSwitch.isOn) {

        NSLog(@"Restarting region monitoring with new settings.");
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];

        // Reload the beacon region
        self.beaconRegion = [self beaconRegionForSettings];

        // Restart the beacon ranging
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager requestStateForRegion:self.beaconRegion];
    }
    
}

@end
