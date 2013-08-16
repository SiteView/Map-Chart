//
//  AppDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import <CoreLocation/CoreLocation.h>

@class RoomModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterstorage;

@property (nonatomic, strong, readonly) XMPPRoomCoreDataStorage *roomstorage;
//@property (nonatomic, strong, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong, readonly) XMPPMUC *xmppMuc;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, assign) id authenticateDelegate;
@property (nonatomic, assign) id chatDelegate;
@property (nonatomic, assign) id messageDelegate;
@property (nonatomic, strong) id roomsDelegate;
@property (nonatomic, strong) id roomMessageDelegate;
@property (nonatomic, strong) id createRoomDelegate;
@property (nonatomic, strong) NSString *server_;

@property (nonatomic, strong, readonly) NSMutableDictionary *messageList; // 房间消息列表
@property (nonatomic, strong, readonly) NSMutableArray *groupChatMessage;   
@property (nonatomic, strong, readonly) NSMutableDictionary *friendsChatMessage;

@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic) BOOL isXMPPRegister;
@property (nonatomic) BOOL registerSuccess;
@property (nonatomic, readonly) NSMutableDictionary *roomModel_; // 房间列表
@property (nonatomic, readonly) NSMutableDictionary *roomJoinModel_; // 加入的房间列表
@property (nonatomic, strong) RoomModel *createRoomModel;
@property (nonatomic) CLLocationCoordinate2D myLocation;

- (NSString*)uuid;

- (NSManagedObjectContext *)managedObjectContext_room;
- (NSDictionary *)managedObjectContext_rooms;
- (NSArray *)managedObjectContext_roomMessage:(NSString *)roomName;

- (BOOL)connect:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server;
- (void)disconnect;
- (void)querySupportMUC;
- (BOOL)registery:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server;
- (void)createRoom:(RoomModel *)room;
- (void)joinRoom:(NSString *)roomjid password:(NSString *)password nickName:(NSString *)nickName;

@end
