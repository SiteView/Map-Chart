//
//  MasterViewController.h
//  MapDots
//
//  Created by siteview_mac on 13-9-24.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MasterViewController : UITableViewController <
UISplitViewControllerDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, assign) AppDelegate *appDelegate;

@end
