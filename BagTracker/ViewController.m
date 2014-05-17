//
//  ViewController.m
//  BagTracker
//
//  Created by Scott Newman on 5/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure we have configuration values set
    NSDictionary *settings = [self retrieveSettings];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:settings[@"uuid"]];
    NSUInteger major = [settings[@"major"] integerValue];
    NSUInteger minor = [settings[@"minor"] integerValue];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:major
                                                                minor:minor
                                                           identifier:@"com.example.bagtracker"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)toggleSwitch:(id)sender
{
    UISwitch *mySwitch = sender;
    if (mySwitch.on) {
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
    else {
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
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
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
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

- (NSDictionary *)retrieveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If no value is set, put default values in
    if (![defaults stringForKey:@"uuid"]) {
    
        NSLog(@"Setting Default Values");
        
        NSDictionary *defaultPreferences = @{
            @"uuid": @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA7",
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

@end
