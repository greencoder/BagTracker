//
//  SettingsViewController.h
//  BagTracker
//
//  Created by Scott Newman on 5/17/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsDelegate <NSObject>
- (void)didUpdateSettings;
@end

@interface SettingsViewController : UITableViewController

@property (nonatomic, assign) IBOutlet UITextField *UUIDField;
@property (nonatomic, assign) IBOutlet UITextField *majorField;
@property (nonatomic, assign) IBOutlet UITextField *minorField;
@property (nonatomic, assign) id<SettingsDelegate> delegate;

@end
