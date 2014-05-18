//
//  SettingsViewController.m
//  BagTracker
//
//  Created by Scott Newman on 5/17/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load the values from defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults stringForKey:@"uuid"];
    NSNumber *major = [defaults valueForKey:@"major"];
    NSNumber *minor = [defaults valueForKey:@"minor"];
    
    // Set the text field values
    self.UUIDField.text = uuid;
    self.majorField.text = major.stringValue;
    self.minorField.text = minor.stringValue;
    
}

- (IBAction)didPressCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressDone:(id)sender
{
    [self saveSettings];
    
    // We call the delegate method so the presenting view controller
    // can restart any montioring with the new settings
    [self.delegate didUpdateSettings];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)saveSettings
{
    NSString *uuid = self.UUIDField.text;
    NSNumber *major = @(self.majorField.text.integerValue);
    NSNumber *minor = @(self.minorField.text.integerValue);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uuid forKey:@"uuid"];
    [defaults setObject:major forKey:@"major"];
    [defaults setObject:minor forKey:@"minor"];
    [defaults synchronize];
    
}

@end
