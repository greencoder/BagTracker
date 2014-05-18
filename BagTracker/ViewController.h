//
//  ViewController.h
//  BagTracker
//
//  Created by Scott Newman on 5/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "SettingsViewController.h"

@interface ViewController : UIViewController  <CLLocationManagerDelegate, SettingsDelegate>

@property (nonatomic, assign) IBOutlet UISwitch *trackingSwitch;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

- (IBAction)toggleSwitch:(id)sender;

@end
