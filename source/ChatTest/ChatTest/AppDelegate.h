//
//  AppDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPRoomCoreDataStorage *rosterstorage;
@property (nonatomic, strong, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong, readonly) XMPPMUC *xmppMuc;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, assign) id authenticateDelegate;
@property (nonatomic, assign) id chatDelegate;
@property (nonatomic, assign) id messageDelegate;
@property (nonatomic, strong) id roomsDelegate;
@property (nonatomic, strong) id roomMessageDelegate;
@property (nonatomic, strong) NSString *server_;
@property (nonatomic, strong, readonly) NSMutableArray *groupChatMessage;

@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic) BOOL isXMPPRegister;
@property (nonatomic) BOOL registerSuccess;

- (NSString*)uuid;

- (BOOL)connect:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server;
- (void)disconnect;
- (BOOL)querySupportMUC;
- (BOOL)registery:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server;
- (void)joinRoom:(NSString *)roomjid password:(NSString *)password;

@end
