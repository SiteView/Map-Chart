//
//  AppDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, assign) id authenticateDelegate;
@property (nonatomic, assign) id chatDelegate;
@property (nonatomic, assign) id messageDelegate;
@property (nonatomic, strong) NSString *server_;

@property (nonatomic, readonly) BOOL isOnline;

- (BOOL)connect:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server;
- (void)disconnect;

@end
