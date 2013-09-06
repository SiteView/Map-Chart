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

@interface FriendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate,
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

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color;

@end
