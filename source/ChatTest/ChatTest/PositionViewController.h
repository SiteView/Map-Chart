//
//  PositionViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPChatDelegate.h"
#import "LoginViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface PositionViewController : UIViewController<XMPPChatDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) LoginViewController *loginViewController;


@end
