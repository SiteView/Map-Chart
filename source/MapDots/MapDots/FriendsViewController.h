//
//  FriendsViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPChatDelegate.h"
#import "LoginViewController.h"
#import "touchTableView.h"

@interface FriendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate,
    TouchTableViewDelegate,
    XMPPChatDelegate,
#ifdef GOOGLE_MAPS
GMSMapViewDelegate
#else
#ifdef BAIDU_MAPS
BMKMapViewDelegate
#else
MKMapViewDelegate,
CLLocationManagerDelegate
#endif
#endif
    >

@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomJid;
@property (nonatomic, strong) NSString *roomPassword;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *screenShotsList;

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color;

@end
