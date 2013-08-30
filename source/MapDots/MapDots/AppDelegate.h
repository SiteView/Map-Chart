//
//  AppDelegate.h
//  MapChart
//
//  Created by siteview_mac on 13-8-20.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "XMPPFramework.h"
#import "XMPPMessageDelegate.h"
#import "XMPPCreateRoomDelegate.h"
#import "XMPPRoomsDelegate.h"
#import "XMPPRoomMessageDelegate.h"
#import "XMPPAuthenticateDelegate.h"
#import "XMPPChatDelegate.h"

@class RoomModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;

//@property (nonatomic, strong, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong, readonly) XMPPRoomCoreDataStorage *xmppRoomStorage;
@property (nonatomic, strong, readonly) XMPPMUC *xmppMuc;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, strong) id<XMPPAuthenticateDelegate> authenticateDelegate;
@property (nonatomic, strong) id<XMPPChatDelegate> chatDelegate;
@property (nonatomic, strong) id<XMPPMessageDelegate> messageDelegate;
@property (nonatomic, strong) id<XMPPRoomsDelegate> roomsDelegate;
@property (nonatomic, strong) id<XMPPRoomMessageDelegate> roomMessageDelegate;
@property (nonatomic, strong) id<XMPPCreateRoomDelegate> createRoomDelegate;
//@property (nonatomic, strong) NSString *server_;

@property (nonatomic, strong, readonly) NSMutableDictionary *messageList; // 房间消息列表
@property (nonatomic, strong, readonly) NSMutableArray *groupChatMessage;   
@property (nonatomic, strong, readonly) NSMutableDictionary *friendsChatMessage;

@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic) BOOL isXMPPRegister;
@property (nonatomic) BOOL registerSuccess;
@property (nonatomic, readonly) NSMutableDictionary *roomModel_; // 房间列表
@property (nonatomic, readonly) NSMutableDictionary *roomJoinModel_; // 加入的房间列表
@property (nonatomic, readonly) NSMutableDictionary *xmppRoomList; // 加入的房间列表
@property (nonatomic, readonly) NSMutableDictionary *xmppRoomJoin; // 加入的房间列表

@property (nonatomic, strong) RoomModel *createRoomModel;
@property (nonatomic) CLLocationCoordinate2D myLocation;

- (NSString*)uuid;

- (NSManagedObjectContext *)managedObjectContext_room;
- (NSDictionary *)managedObjectContext_rooms;
- (NSArray *)managedObjectContext_roomMessage:(NSString *)roomName;

- (BOOL)connect:(NSString *)userId password:(NSString *)password;// serverName:(NSString *)serverName server:(NSString *)server;
- (void)disconnect;
- (void)querySupportMUC;
- (BOOL)registery:(NSString *)userId password:(NSString *)password;// serverName:(NSString *)serverName server:(NSString *)server;
- (void)createRoom:(RoomModel *)room;
- (void)joinRoom:(NSString *)roomjid password:(NSString *)password nickName:(NSString *)nickName;
- (void)leaveRoom:(NSString *)roomjid;
- (void)sendRoomMessage:(NSString *)roomName message:(NSString *)message;

- (void)changeNickName:(NSString *)newNickName;
- (void)changeUserSexual:(BOOL)sexual;

- (void)updateMyPosition;
- (void)updateMyPositionWithRoomName:(NSString *)roomName;
- (void)updateMyPositionWithRoom:(RoomModel *)room;

@end
