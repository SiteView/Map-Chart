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
#import "MessageContextViewController.h"
#import "XMPPRoomsDelegate.h"

@interface PositionViewController : UIViewController<XMPPAuthenticateDelegate, XMPPChatDelegate, XMPPRoomsDelegate
    , GMSMapViewDelegate>
    //, CLLocationManagerDelegate>

@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) MessageContextViewController *roomsViewController;
@property (strong, nonatomic) MessageContextViewController *roomMessageViewController;
@end
