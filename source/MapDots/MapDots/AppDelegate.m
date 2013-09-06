//
//  AppDelegate.m
//  MapChat
//
//  Created by chenwei on 13-8-19.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//
#import "APIKey.h"
#import "AppDelegate.h"

#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "PositionViewController.h"
#import "PreferencesViewController.h"
#import "MessageViewController.h"
#import "EventsViewController.h"
#import "MemberProperty.h"
#import "RoomModel.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "UserProperty.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

enum XMPPStatus
{
    STATUS_LOGIN,
    STATUS_REGISTER,
    STATUS_LOGIN_SUCCESS,

    STATUS_GET_ROOMS,
    
    STATUS_CREATE_ROOM,
    STATUS_CHANGE_NICKNAME,
    
    STATUS_JOIN_ROOM,
    STATUS_LEAVE_ROOM,
};

typedef enum XMPPStatus XMPPStatus;

@implementation AppDelegate
{
    NSString *jabberID_;
    NSString *password_;
    BOOL isXMPPStreamOpen;
    BOOL isRoomInfo_;
    int rooms_;
    NSMutableDictionary *dictUser;
    XMPPStatus status_;
    
    BOOL isXmppConnected;

    MessageViewController *messageViewController;
    
    NSTimer *timer;
    
    BMKMapManager* _mapManager;
}

#define DISCO_INFO  @"http://jabber.org/protocol/disco#info"
#define PROTOCOL_MUC   @"http://jabber.org/protocol/muc"
#define PROTOCOL_MUC_PASSWORDPROTECTED       @"muc_passwordprotected"
#define DISCO_ITEMS     @"http://jabber.org/protocol/disco#items"
#define XMPP_PROPERTIES @"http://www.jivesoftware.com/xmlns/xmpp/properties"

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
//@synthesize xmppRoom;
@synthesize xmppRoomStorage;
@synthesize xmppMuc;
@synthesize xmppvCardStorage;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardTempModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize authenticateDelegate;
@synthesize chatDelegate;
@synthesize messageDelegate;
@synthesize roomsDelegate;
@synthesize roomMessageDelegate;
@synthesize groupChatMessage;
@synthesize friendsChatMessage;
@synthesize createRoomDelegate;

//@synthesize server_;
@synthesize isOnline;
@synthesize isXMPPRegister;
@synthesize registerSuccess;
//@synthesize roomModel_;
//@synthesize roomJoinModel_;
@synthesize messageList;
@synthesize createRoomModel;
//@synthesize xmppRoomJoin;
@synthesize xmppRoomList_;
@synthesize myLocation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef GOOGLE_MAPS

    if ([APIKey length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *reason =
        [NSString stringWithFormat:@"Configure APIKey inside APIKey.h for your "
         @"bundle `%@`, see README.GoogleMapsSDKDemos for more information",
         bundleId];
        @throw [NSException exceptionWithName:@"SDKDemosAppDelegate"
                                       reason:reason
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:(NSString *)APIKey];
#else
#ifdef BAIDU_MAPS
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:BaiduAPIKey  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
#endif
#endif
	// Configure logging framework
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    messageList = [NSMutableDictionary dictionary];
    
    // Setup the XMPP stream
    
	[self setupStream];
    
    // Setup the timer
    [self setupTimer];
    
    [WXApi registerApp:WXAPIKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
/*
    PositionViewController *positionViewController = [[PositionViewController alloc] init];
    positionViewController.title = @"Position";
    positionViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Position" image:nil tag:101];
    UINavigationController *positionNavigationController = [[UINavigationController alloc] initWithRootViewController:positionViewController];
*/
    EventsViewController *roomsViewController = [[EventsViewController alloc] init];
    roomsViewController.title = @"Events";
    roomsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Events" image:nil tag:102];
    UINavigationController *roomsNavigationController = [[UINavigationController alloc] initWithRootViewController:roomsViewController];
    
/*    messageViewController = [[MessageViewController alloc] init];
    messageViewController.title = @"Message";
    messageViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Message" image:nil tag:103];
    UINavigationController *messageNavigationController = [[UINavigationController alloc] initWithRootViewController:messageViewController];
*/    
    PreferencesViewController *preferencesViewController = [[PreferencesViewController alloc] init];
    preferencesViewController.title = @"Preferences";
    preferencesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Preferences" image:nil tag:104];
    UINavigationController *preferencesNavigationController = [[UINavigationController alloc] initWithRootViewController:preferencesViewController];
    
    UITabBarController *tabBarController;
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[roomsNavigationController, preferencesNavigationController];
    
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:positionViewController];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    NSString *str = @"test";
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma make WXApi

- (void) sendTextContent:(NSString*)nsText
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = nsText;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

#pragma make WXApiDelegate

/*
-(void) onShowMediaMessage:(WXMediaMessage *) message
{
    // 微信启动， 有消息内容。
    [self viewContent:message];
}

-(void) onRequestAppMessage
{
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    
    RespForWeChatViewController* controller = [[RespForWeChatViewController alloc]autorelease];
    controller.delegate = self;
    [self.viewController presentModalViewController:controller animated:YES];
    
}
*/

// onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
- (void)onReq:(BaseReq *)req
{
/*    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        [self onRequestAppMessage];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        [self onShowMediaMessage:temp.message];
    }
*/ 
}

// 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
- (void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}
#pragma make UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    switch (viewController.tabBarItem.tag) {
        case 101:
            //
            break;
        case 102:
            break;
        case 103:
            break;
        default:
            break;
    }
}
#pragma make -

- (void)dealloc
{
    [timer invalidate];
    [self teardownStream];
}

- (NSString*)uuid
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (__bridge NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

#pragma make -
#pragma make NSTimer
- (void)setupTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)timerFired:(NSTimer *)timer
{
    [self updateMyPosition];
}
#pragma make XMPPDelegate

- (void)setupStream {
    isOnline = NO;
    groupChatMessage = [[NSMutableArray alloc] init];
    
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
//    roomModel_ = [NSMutableDictionary dictionary];
//    roomJoinModel_ = [NSMutableDictionary dictionary];
    xmppRoomList_ = [NSMutableDictionary dictionary];
//    xmppRoomJoin = [NSMutableDictionary dictionary];
    createRoomModel = [[RoomModel alloc] init];
    
    #if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // The simulator doesn't support backgrouding yet.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
    #endif
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
    
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
    // Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

    // Setup MUC support
    xmppMuc = [[XMPPMUC alloc] init];
    
	xmppRoomStorage = [[XMPPRoomCoreDataStorage alloc] init];

    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
    [xmppMuc               activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];

//    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
    xmppRoomStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}

- (BOOL)registery:(NSString *)userId password:(NSString *)password //serverName:(NSString *)serverName server:(NSString *)server
{
    NSLog(@"%s", __FUNCTION__);
    status_ = STATUS_REGISTER;
    
//    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", userId, serverName];
    
    NSString *jabberID = userId;
    NSLog(@"jabberID: %@", jabberID);
	[xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];

    jabberID_ = jabberID;
    XMPPJID *xmppJid = [XMPPJID jidWithString:jabberID];
    [xmppStream setMyJID:xmppJid];
//    [xmppStream setHostName:server];
//    NSLog(@"server: %@", server);

//    [xmppStream setHostPort:DOMAIN_PORT];
    
    password_ = password;
//    server_ = serverName;
    
    NSError *error = nil;
    BOOL result = [xmppStream registerWithPassword:password error:&error];
    if (result == NO)
    {
        NSString *strMsg = [NSString stringWithFormat:@"Can't register to server %@", [error localizedDescription]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"%s", __FUNCTION__);
    registerSuccess = YES;
    isXMPPRegister = NO;
    
    [authenticateDelegate didRegister:sender];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    NSLog(@"%@:%@ %@", THIS_FILE, THIS_METHOD, [error description]);
    
    for (NSXMLElement* node in [error elementsForName:@"error"]) {
        if ([node attributeIntValueForName:@"code"] == 409)
        {
            registerSuccess = YES;
            isXMPPRegister = NO;

            [authenticateDelegate didRegister:sender];
        }
    }
}

- (BOOL)connect:(NSString *)userId password:(NSString *)password
{
    NSLog(@"%s", __FUNCTION__);

    status_ = STATUS_LOGIN;

    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || password == nil) {
        return NO;
    }
    
    jabberID_ = userId;
    XMPPJID *xmppJid = [XMPPJID jidWithString:userId];
    [xmppStream setMyJID:xmppJid];
//    [xmppStream setHostName:serverName];
    NSLog(@"serverName: %@", DOMAIN_NAME);
    
//    [xmppStream setHostPort:DOMAIN_PORT];
    
    password_ = password;
//    server_ = serverName;
    
    NSTimeInterval ti = 100;
    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:ti error:&error])
    {
    //    if (![xmppStream connectWithTimeout:ti error:&error]) {
//    if (![xmppStream connect:&error]) {
        //        NSLog(@"cann't connect %@", server);
        NSString *strMsg = [NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    [self goOffline];
    [xmppStream disconnect];
}

- (NSString *)getCurrentTime{
    
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}

#pragma make XMPPdelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender;
{
    NSLog(@"%s", __FUNCTION__);
}

//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"%s", __FUNCTION__);
	isXmppConnected = YES;
    isXMPPStreamOpen = YES;

    if (status_ == STATUS_REGISTER) {
        [authenticateDelegate didConnect:sender];
        return;
    }
    
    NSError *error = nil;
//    server_ = sender.hostName;
    
    //验证密码
    [sender authenticateWithPassword:password_ error:&error];
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

// 连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender;
{
    NSLog(@"%s", __FUNCTION__);
    NSString *strMsg = [NSString stringWithFormat:@"Can't connect to server %@", DOMAIN_NAME];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];

}
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    [self goOnline];
    isOnline = YES;
    [authenticateDelegate didAuthenticate:sender];
}

// 验证未通过
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)authResponse{
//    [self goOffline];
    NSLog(@"%@:%@ %@", THIS_FILE, THIS_METHOD, [authResponse description]);
    
    [authenticateDelegate didNotAuthenticate:authResponse];
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([message isErrorMessage]) {
        // process error
        NSXMLElement *node = [message elementForName:@"error"];
        if (node) {
            int32_t code = [node attributeInt32ValueForName:@"code"];
            NSString *type = [node attributeStringValueForName:@"type"];
            if ([type isEqualToString:@"modify"]) {
                switch (code) {
                    case 400:
                        [roomsDelegate didJoinRoomFailure:@"改变发送的数据后再试"];
                        break;
                    case 406:
                        [roomsDelegate didJoinRoomFailure:@"改变发送的数据后再试"];
                        break;
                    default:
                        break;
                }
            }
        }
        
        return;
    }
    
    if ([message isGroupChatMessage]) {
        [self processGroupChatMessage:message];

        return;
    }
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    if (msg == nil) {
        return;
    }
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];
    [dict setObject:from forKey:@"sender"];
    //消息接收到的时间
    [dict setObject:[self getCurrentTime] forKey:@"time"];
    
    if (friendsChatMessage == nil) {
        friendsChatMessage = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *friend = [friendsChatMessage objectForKey:from];
    if (friend == nil) {
        friend = [NSMutableArray array];
    }
    
    [friend addObject:dict];
    
//    [messageDelegate newMessageReceived:dict];
    
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"%@ %@ %@", THIS_FILE, THIS_METHOD, presence);
    /*
     <presence xmlns="jabber:client" to="57787d89@siteviewwzp/9b0ecfa2" from="ccc@conference.siteviewwzp/57787D89@siteviewwzp">
     <x xmlns="vcard-temp:x:update"><photo/></x>
     <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
     <x xmlns="http://jabber.org/protocol/muc#user">
        <item affiliation="none" role="participant"/>
     </x>
     </presence>
     
    <presence xmlns="jabber:client" id="UuKvk-124" type="unavailable" from="test1@siteviewwzp" to="fc6a3ed6@siteviewwzp/e6eef068">
        <x xmlns="vcard-temp:x:update">
        <photo>1531beb3a56bb3216a012bc3806522cc7c50782e</photo>
        </x>
        <x xmlns="jabber:x:avatar">
        <hash>1531beb3a56bb3216a012bc3806522cc7c50782e</hash>
        </x>
    </presence>
     
     <presence xmlns="jabber:client" id="l34Ic-6" from="test1@siteviewwzp/Spark 2.6.3" to="57787d89@siteviewwzp">
     <status>在线</status>
     <priority>1</priority>
     <x xmlns="vcard-temp:x:update"><photo>1531beb3a56bb3216a012bc3806522cc7c50782e</photo></x>
     <x xmlns="jabber:x:avatar"><hash>1531beb3a56bb3216a012bc3806522cc7c50782e</hash></x>
     </presence>
     
    // 出错
     <presence xmlns="jabber:client"
     to="fc6a3ed6@siteviewwzp/e18735a9"
     from="liu@conference.siteviewwzp/FC6A3ED6@siteviewwzp"
     type="error">
     <x xmlns="http://jabber.org/protocol/muc"/>
     <c xmlns="http://jabber.org/protocol/caps"
     hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
     <error code="401" type="auth">
     <not-authorized xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
     </error>
     </presence>
     
     <presence xmlns="jabber:client" 
     to="ff398ab1@siteviewwzp/2709ecb0" 
     from="a@conference.siteviewwzp/FF398AB1@siteviewwzp" 
     type="error">
     <x xmlns="http://jabber.org/protocol/muc"/>
     <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
     <error code="407" type="auth">
        <registration-required xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
     </error>
     </presence>
     
     <presence xmlns="jabber:client" from="ccc@conference.siteviewwzp" to="57787d89@siteviewwzp/5f0e5cf2" type="error">
     <x xmlns="http://jabber.org/protocol/muc"/>
     <x xmlns="vcard-temp:x:update"><photo/></x>
     <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
     <error code="400" type="modify">
        <bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
     </error>
     </presence>
    */
    
/*
    // 出席的房间成员
    <presence xmlns="jabber:client" to="57787d89@siteviewwzp/638581be" from="测试@conference.siteviewwzp/cw">
    <c xmlns="http://jabber.org/protocol/caps" node="http://pidgin.im/" hash="sha-1" ver="DdnydQG7RGhP9E3k9Sf+b+bF0zo="/>
    <x xmlns="vcard-temp:x:update"><photo>1531beb3a56bb3216a012bc3806522cc7c50782e</photo></x>
    <x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/></x></presence>
 
    <presence xmlns="jabber:client" to="57787d89@siteviewwzp/638581be" from="测试@conference.siteviewwzp/57787D89@siteviewwzp">
    <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
    <x xmlns="vcard-temp:x:update"><photo/></x>
    <x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/></x></presence>
 
    // 失败加入
    <presence xmlns="jabber:client" to="57787d89@siteviewwzp/638581be" from="test@conference.siteviewwzp/57787D89@siteviewwzp" type="error">
    <x xmlns="http://jabber.org/protocol/muc"/>
    <x xmlns="vcard-temp:x:update"><photo/></x>
    <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
    <error code="401" type="auth"><not-authorized xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></presence>
*/
    if (status_ == STATUS_CREATE_ROOM) {
        if ([presence isErrorPresence]) {
            /* 
             XEP-0045
             例子 142. 服务通知用户不能新建房间
             <presence
                from='darkcave@chat.shakespeare.lit/thirdwitch'
                to='hag66@shakespeare.lit/pda'
                type='error'>
                <x xmlns='http://jabber.org/protocol/muc'/>
                <error type='cancel'>
                    <not-allowed xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
                </error>
             </presence>
            */ 
        } else {
            // 服务承认房间新建成功
            /*
             <presence xmlns="jabber:client" to="57787d89@siteviewwzp/6dcfaded" from="def@conference.siteviewwzp/57787D89@siteviewwzp">
             <x xmlns="vcard-temp:x:update"><photo/></x><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
             <x xmlns="http://jabber.org/protocol/muc#user">
                <item jid="57787d89@siteviewwzp/6dcfaded" 
                    affiliation="owner" 
                    role="moderator"/>
                <status code="201"/>
             </x>
             </presence>
             */
            NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];
            if (x) {
                NSXMLElement *item = [presence elementForName:@"item"];
                [item attributeStringValueForName:@"affiliation"];
                [item attributeStringValueForName:@"role"];
                NSXMLElement *status = [presence elementForName:@"status"];
                if (status) {
                    //
                } else {
                    NSLog(@"New user: %@", [[presence to] user]);
                }
            }

        }
    } else
    if (status_ == STATUS_JOIN_ROOM) {
        if ([presence type]) {
            if ([presence isErrorPresence]) {
            // process error
            NSXMLElement *error = [presence elementForName:@"error"];
            if (error) {
                int32_t code = [error attributeInt32ValueForName:@"code"];
                NSString *type = [error attributeStringValueForName:@"type"];
                if ([type isEqualToString:@"auth"]) {
                    switch (code) {
                        case 401:
                            // 通知用户需要密码
                            [roomsDelegate didJoinRoomFailure:@"密码认证失败"];
                            break;
                        case 403:
                            // 通知用户他或她被房间禁止了
                            [roomsDelegate didJoinRoomFailure:@"被房间禁止"];
                            break;
                        case 404:
                            // 通知用户房间不存在
                            [roomsDelegate didJoinRoomFailure:@"房间不存在"];
                            break;
                        case 405:
                            // 通知用户限制创建房间
                            break;
                        case 406:
                            // 通知用户必须使用保留的房间昵称
                            break;
                        case 407:
                            // 通知用户他或她不在成员列表中
                            [roomsDelegate didJoinRoomFailure:@"密码认证失败"];
                            break;
                        case 409:
                            // 通知用户他或她的房间昵称正在使用或被别的用户注册了
                            break;
                        case 503:
                            // 通知用户已经达到最大用户数
                            break;
                        default:
                            break;
                    }
                } else if ([type isEqualToString:@"modify"]) {
                    switch (code) {
                        case 400:
                            break;
                        default:
                            break;
                    }
                }
            }
            }
            return;
        } else {
            // 成功加入
            
            /*
             <presence xmlns="jabber:client" to="57787d89@siteviewwzp/9b0ecfa2" from="ccc@conference.siteviewwzp/57787D89@siteviewwzp">
             <x xmlns="vcard-temp:x:update"><photo/></x>
             <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
             <x xmlns="http://jabber.org/protocol/muc#user">
             <item affiliation="none" role="participant"/>
             </x>
             </presence>
             
             <presence xmlns="jabber:client" to="57787d89@siteviewwzp/4b6326f1" from="ccc@conference.siteviewwzp/57787D89@siteviewwzp"><x xmlns="vcard-temp:x:update"><photo/></x><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/></x></presence>
             */
            
            NSString *presenceFromUser = [presence fromStr];
            NSString *roomJID = [[presenceFromUser componentsSeparatedByString:@"/"] objectAtIndex:0];

//            NSString *name = [[presence from] user];
            NSString *roomName = [[roomJID componentsSeparatedByString:@"@"] objectAtIndex:0];

            NSMutableArray *messageArray = [messageList objectForKey:roomJID];
            if (messageArray == nil) {
                messageArray = [NSMutableArray array];
                
                [messageList setObject:messageArray forKey:roomJID];
            }
            
            XMPPRoom *roomModel = [xmppRoomList_ objectForKey:roomJID];
            if (roomModel.isJoined)
            {
                roomModel.roomName = roomName;
                
                [roomsDelegate didJoinRoomSuccess:[roomModel.roomJID full]];
            }
            /*
             // 房间成员
             <presence xmlns="jabber:client" to="57787d89@siteviewwzp/4d5a1d92" from="&#x8FD8;&#x597D;&#x8FD8;&#x597D;@conference.siteviewwzp/cw">
             <c xmlns="http://jabber.org/protocol/caps" node="http://pidgin.im/" hash="sha-1" ver="DdnydQG7RGhP9E3k9Sf+b+bF0zo="/>
             <x xmlns="http://jabber.org/protocol/muc#user">
                <item jid="fc6a3ed6@siteviewwzp/siteview-mactekiMac-mini" affiliation="none" role="participant"/>
             </x>
             </presence>
             
             <presence xmlns="jabber:client" to="57787d89@siteviewwzp/4d5a1d92" from="&#x8FD8;&#x597D;&#x8FD8;&#x597D;@conference.siteviewwzp/57787D89@siteviewwzp">
             <x xmlns="vcard-temp:x:update"><photo/></x>
             <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://code.google.com/p/xmppframework" ver="k6gP4Ua5m4uu9YorAG0LRXM+kZY="/>
             <x xmlns="http://jabber.org/protocol/muc#user">
                <item jid="57787d89@siteviewwzp/4d5a1d92" affiliation="none" role="participant"/>
             </x>
             </presence>
             
             <presence xmlns="jabber:client" to="24cefc6c@siteviewwzp/854d10b" from="123@conference.siteviewwzp/cw">
             <c xmlns="http://jabber.org/protocol/caps" node="http://pidgin.im/" hash="sha-1" ver="DdnydQG7RGhP9E3k9Sf+b+bF0zo="/>
             <x xmlns="vcard-temp:x:update"><photo>1531beb3a56bb3216a012bc3806522cc7c50782e</photo></x>
             <x xmlns="http://jabber.org/protocol/muc#user">
                <item jid="fc6a3ed6@siteviewwzp/siteview-mactekiMac-mini" affiliation="none" role="participant"/>
             </x>
             </presence>
             */
//            for (NSXMLElement* element in [presence children]) {
                NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];
                if (x) {
                    NSXMLElement *item = [x elementForName:@"item"];
                    if (item) {
                        NSString *jid = [item attributeStringValueForName:@"jid"];
                        if (jid != nil) {
                            NSString *memberJid = [[jid componentsSeparatedByString:@"/"] objectAtIndex:0];
                            
                            if (roomModel.members == nil) {
                                roomModel.members = [NSDictionary dictionary];
                            }
                            MemberProperty *member = [roomModel.members objectForKey:memberJid];
                            if (member == nil) {
                                member = [[MemberProperty alloc] init];
                                [roomModel.members setObject:member forKey:memberJid];
                            }
                            member.jid = memberJid;
//                        member.coordinate = ;

                        }
                        
                    }
                }
            return;
        }
    } else
    if (status_ == STATUS_CHANGE_NICKNAME) {
        if ([presence isErrorPresence]) {
            NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];
            if (x) {
                // process error
                NSXMLElement *error = [presence elementForName:@"error"];
                if (error) {
                    NSString *type = [error attributeStringValueForName:@"type"];
                    if ([type isEqualToString:@"cancel"]) {
                        /*
                         服务拒绝昵称修改，因为昵称冲突
                         <presence
                         from='darkcave@chat.shakespeare.lit'
                         to='hag66@shakespeare.lit/pda'
                         type='error'>
                         <x xmlns='http://jabber.org/protocol/muc'/>
                         <error type='cancel'>
                         <conflict xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
                         </error>
                         </presence>
                         */
                        
                        /*
                         服务拒绝昵称变更，因为房间昵称被锁定
                         <presence
                         from='darkcave@chat.shakespeare.lit'
                         to='hag66@shakespeare.lit/pda'
                         type='error'>
                         <x xmlns='http://jabber.org/protocol/muc'/>
                         <error type='cancel'>
                         <not-acceptable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
                         </error>
                         </presence>
                         */
                    }
                }
            }
        }
    } else
    if ([presence isErrorPresence]) {
        // process error
        NSXMLElement *error = [presence elementForName:@"error"];
        if (error) {
            int32_t code = [error attributeInt32ValueForName:@"code"];
            NSString *type = [error attributeStringValueForName:@"type"];
            if ([type isEqualToString:@"auth"]) {
                switch (code) {
                    case 400:
                        break;
                    case 401:
                        // 密码认证失败
                        [roomsDelegate didJoinRoomFailure:@"密码认证失败"];
                        break;
                    case 404:
                        // 远程服务器未找到
                        [roomsDelegate didJoinRoomFailure:@"远程服务器未找到"];
                        break;
                    case 407:
                        // 需要注册
                        [roomsDelegate didJoinRoomFailure:@"密码认证失败"];
                        break;
                    default:
                        break;
                }
            } else if ([type isEqualToString:@"modify"]) {
                switch (code) {
                    case 400:
                        break;
                    default:
                        break;
                }
            }
        }
        return;
    }
    NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    if (x) {
        NSXMLElement *item = [presence elementForName:@"item"];
        [item attributeStringValueForName:@"affiliation"];
        [item attributeStringValueForName:@"role"];
        NSXMLElement *status = [presence elementForName:@"status"];
        if (status) {
            //
        } else {
            NSLog(@"New user: %@", [[presence to] user]);
        }
    }
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[sender myJID] user];
    
    /*
    <presence xmlns="jabber:client" to="24cefc6c@siteviewwzp/e16803ce" from="123@conference.siteviewwzp/cw">
    <c xmlns="http://jabber.org/protocol/caps" node="http://pidgin.im/" hash="sha-1" ver="DdnydQG7RGhP9E3k9Sf+b+bF0zo="/>
    <x xmlns="http://jabber.org/protocol/muc#user">
        <item jid="fc6a3ed6@siteviewwzp/siteview-mactekiMac-mini" affiliation="none" role="participant"/>
    </x>
    </presence>
    */
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
//            [chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, server_]];
            
        }else if ([presenceType isEqualToString:@"unavailable"]) {
//            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, server_]];
            [chatDelegate buddyWentOffline:presenceFromUser];
        }
        
    }
    
}

// 查询消息
- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"%@ %@", THIS_FILE, THIS_METHOD);
    
    if (status_ == STATUS_GET_ROOMS)
    {
        if ([iq isResultIQ])
        {
            /*
             <iq xmlns="jabber:client" type="result" from="conference.siteviewwzp" to="57787d89@siteviewwzp/f82aa773">
                <query xmlns="http://jabber.org/protocol/disco#items">
                    <item jid="&#x80D6;&#x80D6;&#x6015;@conference.siteviewwzp" name="&#x80D6;&#x80D6;&#x6015;"/>
                    <item jid="&#x8FD8;&#x597D;&#x8FD8;&#x597D;@conference.siteviewwzp" name="&#x8FD8;&#x597D;&#x8FD8;&#x597D;"/>
                    <item jid="aaa@conference.siteviewwzp" name="aaa"/>
                    <item jid="&#x597D;&#x9AD8;&#x521A;&#x521A;&#x597D;@conference.siteviewwzp" name="&#x597D;&#x9AD8;&#x521A;&#x521A;&#x597D;"/>
                     <item jid="test@conference.siteviewwzp" name="&#x5218;&#x4E66;&#x8BB0;"/>
                     <item jid="&#x623F;&#x95F4;1@conference.siteviewwzp" name="&#x623F;&#x95F4;1"/>
                     <item jid="abe@conference.siteviewwzp" name="abE"/>
                     <item jid="123@conference.siteviewwzp" name="123"/>
                     <item jid="ccc@conference.siteviewwzp" name="ccc"/>
                     <item jid="&#x6D4B;&#x8BD5;@conference.siteviewwzp" name="a"/>
                     <item jid="liu@conference.siteviewwzp" name="liu"/>
                 </query>
             </iq>
             */
            NSXMLElement *query = [iq childElement];
            if ([iq elementForName:@"query" xmlns:DISCO_ITEMS])
            {
                [self parseDiscoItems:query];
            } else if ([iq elementForName:@"query" xmlns:DISCO_INFO]) {
                /*
                 <iq xmlns="jabber:client" type="result" id="577AD30D-2453-4117-BA1E-4732DC4FF2F6" from="&#x80D6;&#x80D6;&#x6015;@conference.siteviewwzp" to="57787d89@siteviewwzp/ba2b3dda">
                 <query xmlns="http://jabber.org/protocol/disco#info">
                 <identity category="conference" name="&#x80D6;&#x80D6;&#x6015;" type="text"/>
                 <feature var="http://jabber.org/protocol/muc"/>
                 <feature var="muc_public"/><feature var="muc_open"/>
                 <feature var="muc_unmoderated"/>
                 <feature var="muc_nonanonymous"/>
                 <feature var="muc_passwordprotected"/>
                 <feature var="muc_persistent"/>
                 <feature var="http://jabber.org/protocol/disco#info"/>
                 <x xmlns="jabber:x:data" type="result"><field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roominfo</value></field><field var="muc#roominfo_description" label="&#x63CF;&#x8FF0;"><value>{location:[90.0,0.0];effectivetime:[1376356800810,1376360640840]}</value></field><field var="muc#roominfo_subject" label="&#x4E3B;&#x9898;"><value/></field><field var="muc#roominfo_occupants" label="&#x5360;&#x6709;&#x8005;&#x4EBA;&#x6570;"><value>0</value></field><field var="x-muc#roominfo_creationdate" label="&#x521B;&#x5EFA;&#x65E5;&#x671F;"><value>20130813T01:18:54</value></field></x></query></iq>
                 */
                NSXMLElement *identity = [query elementForName:@"identity"];
                if ([[identity attributeStringValueForName:@"category"] isEqualToString:@"conference"]) {
                    // 指定房间信息
                    [self parseDiscoInfoWithRoom:query roomid:[iq fromStr]];
                }
            }
        }
    } else
    if ([iq isResultIQ]) {
        NSXMLElement *query = [iq childElement];
        
        // TODO:
        if ([[iq fromStr] isEqualToString:DOMAIN_NAME]) {
            [self parseDiscoInfo:query];
        } else {
            // 指定房间信息
            [self parseDiscoInfoWithRoom:query roomid:[iq fromStr]];
        }
    }
/*
    NSString *type = [iq type];
    DDXMLNode *from = [iq attributeForName:@"from"];
    
    NSXMLElement *elements = [iq childElement];
    NSArray *childrens = [iq elementsForName:@"query"];
	for (NSXMLElement *child in childrens)
	{
        NSArray *names = [child namespaces];
        NSXMLNode *xmlns = [names objectAtIndex:0];
        if (xmlns != nil) {
//            NSLog([xmlns stringValue]);
            NSString *value = [xmlns stringValue];
            if ([value isEqualToString:DISCO_INFO]) {
                if ([[from stringValue] compare:server_] == NSOrderedSame) {
                    [self parseDiscoInfo:child];
                } else {
                    // 指定房间信息
                    [self parseDiscoInfoWithRoom:child roomid:from];
                }
            } else if ([value compare:DISCO_ITEMS] == NSOrderedSame) {
                [self parseDiscoItems:child];
            }
 
        }
    }
*/ 
}

#pragma mark DiscoInfo

- (void)querySupportMUC
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
    
    status_ = STATUS_GET_ROOMS;
    [self searchRoomWithConference];
    /*
     用户向服务器询问是否支持muc的协议
     iq get 协议 xmlns = "http://jabber.org/protocol/disco#info"
     <iq from='hag66@shakespeare.lit/pda' fuul jid
     id='disco1'
     to='chat.shakespeare.lit' 服务器
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#info'/>
     </iq>
     */
    /*
    //生成XML消息文档
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //由谁发送
    [iq addAttributeWithName:@"from" stringValue:jabberID_];
    //消息类型
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //发送给谁
    [iq addAttributeWithName:@"to" stringValue:server_];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    //查询类型
    [query addAttributeWithName:@"xmlns" stringValue:DISCO_INFO];
    
    //组合
    [iq addChild:query];
    
    //发送消息
    [[self xmppStream] sendElement:iq];
    [xmppCapabilities fetchCapabilitiesForJID:[XMPPJID jidWithString:server_]];
     */

}

- (void)xmppCapabilities:(XMPPCapabilities *)sender didDiscoverCapabilities:(NSXMLElement *)caps forJID:(XMPPJID *)jid
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);

    /*
     <iq xmlns="jabber:client" id="DB8874F8-250E-4837-A323-C2DB02F42F88" to="57787d89@siteviewwzp/9ec4ae7f" type="result" from="gt-i9308_df7f33@siteviewwzp/Smack">
     <query xmlns="http://jabber.org/protocol/disco#info" node="http://www.igniterealtime.org/projects/smack/#VJlhBimZwSFAXaqkz04jHcSCsqY=">
     <identity category="client" name="Smack" type="pc"/>
     <feature var="http://jabber.org/protocol/caps"/></query></iq>
     
    */
    // 服务器capabilities
    if ([[jid full] isEqualToString:DOMAIN_NAME]) {
        [self parseDiscoInfo:caps];
    } else {
        XMPPRoom *room = [xmppRoomList_ objectForKey:[jid description]];
        
        // 设置Room的属性
        [self parseDiscoInfoWithRoom:caps roomid:[room.roomJID full]];
        
        [roomsDelegate newRoomsReceived:room];
    }
     
}

- (void)parseDiscoInfo:(NSXMLElement *)query
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
    /*
     <iq xmlns="jabber:client"
     type="result"
     from="siteviewwzp"
     to="test2@siteviewwzp/b9fc0542">
        <query xmlns="http://jabber.org/protocol/disco#info">
            <identity category="server" name="Openfire Server" type="im"/>
             <identity category="pubsub" type="pep"/>
             <feature var="http://jabber.org/protocol/pubsub#manage-subscriptions"/>
             <feature var="http://jabber.org/protocol/pubsub#modify-affiliations"/>
             <feature var="http://jabber.org/protocol/pubsub#retrieve-default"/>
             <feature var="http://jabber.org/protocol/pubsub#collections"/>
             <feature var="jabber:iq:private"/>
             <feature var="http://jabber.org/protocol/disco#items"/>
             <feature var="vcard-temp"/>
             <feature var="http://jabber.org/protocol/pubsub#publish"/>
             <feature var="http://jabber.org/protocol/pubsub#subscribe"/>
             <feature var="http://jabber.org/protocol/pubsub#retract-items"/>
             <feature var="http://jabber.org/protocol/offline"/>
             <feature var="http://jabber.org/protocol/pubsub#meta-data"/>
             <feature var="jabber:iq:register"/>
             <feature var="http://jabber.org/protocol/pubsub#retrieve-subscriptions"/>
             <feature var="http://jabber.org/protocol/pubsub#default_access_model_open"/>
             <feature var="jabber:iq:roster"/>
             <feature var="http://jabber.org/protocol/pubsub#config-node"/>
             <feature var="http://jabber.org/protocol/address"/>
             <feature var="http://jabber.org/protocol/pubsub#publisher-affiliation"/>
             <feature var="http://jabber.org/protocol/pubsub#item-ids"/>
             <feature var="http://jabber.org/protocol/pubsub#instant-nodes"/>
             <feature var="http://jabber.org/protocol/commands"/>
             <feature var="http://jabber.org/protocol/pubsub#multi-subscribe"/>
             <feature var="http://jabber.org/protocol/pubsub#outcast-affiliation"/>
             <feature var="http://jabber.org/protocol/pubsub#get-pending"/>
             <feature var="jabber:iq:privacy"/>
             <feature var="http://jabber.org/protocol/pubsub#subscription-options"/>
             <feature var="jabber:iq:last"/>
             <feature var="http://jabber.org/protocol/pubsub#create-and-configure"/>
             <feature var="urn:xmpp:ping"/>
             <feature var="http://jabber.org/protocol/pubsub#retrieve-items"/>
             <feature var="jabber:iq:time"/>
             <feature var="http://jabber.org/protocol/pubsub#create-nodes"/>
             <feature var="http://jabber.org/protocol/pubsub#persistent-items"/>
             <feature var="jabber:iq:version"/>
             <feature var="http://jabber.org/protocol/pubsub#presence-notifications"/>
             <feature var="http://jabber.org/protocol/pubsub"/>
             <feature var="http://jabber.org/protocol/pubsub#retrieve-affiliations"/>
             <feature var="http://jabber.org/protocol/pubsub#delete-nodes"/>
             <feature var="http://jabber.org/protocol/pubsub#purge-nodes"/>
             <feature var="http://jabber.org/protocol/disco#info"/>
             <feature var="http://jabber.org/protocol/rsm"/>
        </query>
     </iq>
     
    NSArray *elemets = [query children];
    
    BOOL isSupportMUC = NO;
    for (NSXMLNode *node in elemets) {
        NSXMLElement *ele = [[NSXMLElement alloc] initWithXMLString:[node description] error:nil];
        NSXMLNode *href = [ele attributeForName:@"var"];
        if (href != nil) {
//            NSLog([href stringValue]);
            
            NSString *value = [href stringValue];
            if ([value compare:PROTOCOL_MUC] == NSOrderedSame) {
                //
                href = nil;
                ele = nil;
                
                isSupportMUC = YES;
                break;
            }
        }
        href = nil;
        ele = nil;
    }
    */
    // 搜索房间
    [self searchRoomWithConference];
    
}

#pragma mark DiscoItem

- (void)searchRooms
{
    /*
     <iq from='hag66@shakespeare.lit/pda' jid
     id='disco2'
     to='chat.shakespeare.lit' server
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
     </iq>
     */
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //由谁发送
    [iq addAttributeWithName:@"from" stringValue:jabberID_];
    //消息类型
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //发送给谁
    // TODO:
    [iq addAttributeWithName:@"to" stringValue:DOMAIN_NAME];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    //查询类型
    [query addAttributeWithName:@"xmlns" stringValue:DISCO_ITEMS];
    
    //组合
    [iq addChild:query];
    
    //发送消息
    [[self xmppStream] sendElement:iq];
    
}


- (void)searchRoomWithConference
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
    /*
     <iq from='hag66@shakespeare.lit/pda' jid
     id='disco2'
     to='chat.shakespeare.lit' server
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
     </iq>
     */
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //由谁发送
    [iq addAttributeWithName:@"from" stringValue:jabberID_];
    //消息类型
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //发送给谁
    NSString *strRoom = [NSString stringWithFormat:@"conference.%@", DOMAIN_NAME];
    [iq addAttributeWithName:@"to" stringValue:strRoom];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    //查询类型
    [query addAttributeWithName:@"xmlns" stringValue:DISCO_ITEMS];
    
    //组合
    [iq addChild:query];
    
    //发送消息
    [[self xmppStream] sendElement:iq];
    
}

- (void)parseDiscoItems:(NSXMLElement *)query
{
    /*
     <iq xmlns="jabber:client"
     type="result"
     from="siteviewwzp"
     to="test2@siteviewwzp/e02890d8">
     <query xmlns="http://jabber.org/protocol/disco#items">
     <item jid="pubsub.siteviewwzp" name="Publish-Subscribe service"/>
     <item jid="proxy.siteviewwzp" name="Socks 5 Bytestreams Proxy"/>
     <item jid="search.siteviewwzp" name="User Search"/>
     <item jid="conference.siteviewwzp" name="&#x516C;&#x5171;&#x623F;&#x95F4;"/>
     </query>
     </iq>
     */
    
    NSArray *items = [query children];
    
    for (NSXMLElement *node in items) {
        NSXMLNode *jid = [node attributeForName:@"jid"];
        NSXMLNode *name = [node attributeForName:@"name"];
        
        XMPPRoom *room = nil;
        room = [xmppRoomList_ objectForKey:[jid stringValue]];
        if (room == nil ) {
            // new room，加入CoreData中
            room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:[XMPPJID jidWithString:[jid stringValue]] dispatchQueue:dispatch_get_main_queue()];
            
            room.roomName = [name stringValue];
            
            XMPPStream *stream = [self xmppStream];
            [room activate:stream];
            [room addDelegate:self delegateQueue:dispatch_get_main_queue()];

            [xmppRoomList_ setObject:room forKey:[room.roomJID full]];
        }

        if ([[room.roomJID full] length] > 0) {
            [xmppCapabilities fetchCapabilitiesForJID:room.roomJID];
        }
    }
}

// 查询房间信息
- (void)queryRoomsInfo:(NSString *)room
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
    /*
     <iq from='hag66@shakespeare.lit/pda' jid
     id='disco3'
     to='darkcave@chat.shakespeare.lit' roomid
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#info'/>
     </iq>
     */
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    //由谁发送
    [iq addAttributeWithName:@"from" stringValue:jabberID_];
    //消息类型
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //发送给谁
    [iq addAttributeWithName:@"to" stringValue:room];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    //查询类型
    [query addAttributeWithName:@"xmlns" stringValue:DISCO_INFO];
    
    //组合
    [iq addChild:query];
    
    //发送消息
    [[self xmppStream] sendElement:iq];
    
}

// 获得指定房间的房间属性：是否加密房间
- (void)parseDiscoInfoWithRoom:(NSXMLElement *)query roomid:(NSString *)room
{
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
    /*
     <iq xmlns="jabber:client" type="result" id="3F60A4D6-8C20-4147-B8F9-CAF6D0F25834" from="test@conference.siteviewwzp" to="57787d89@siteviewwzp/172701e8">
         <query xmlns="http://jabber.org/protocol/disco#info">
             <identity category="conference" name="&#x5218;&#x4E66;&#x8BB0;" type="text"/>
             <feature var="http://jabber.org/protocol/muc"/>
             <feature var="muc_public"/>
             <feature var="muc_open"/>
             <feature var="muc_unmoderated"/>
             <feature var="muc_semianonymous"/>
             <feature var="muc_passwordprotected"/>
             <feature var="muc_persistent"/>
             <feature var="http://jabber.org/protocol/disco#info"/>
             <x xmlns="jabber:x:data" type="result">
                <field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roominfo</value></field>
                <field var="muc#roominfo_description" label="&#x63CF;&#x8FF0;">
                    <value>{location:[28.17806753017430,112.97742276057580]}</value>
                </field>
                <field var="muc#roominfo_subject" label="&#x4E3B;&#x9898;"><value>刘书记</value></field>
                <field var="muc#roominfo_occupants" label="&#x5360;&#x6709;&#x8005;&#x4EBA;&#x6570;"><value>0</value></field>
                <field var="x-muc#roominfo_creationdate" label="&#x521B;&#x5EFA;&#x65E5;&#x671F;"><value>20130718T08:52:29</value></field>
             </x>
         </query>
     </iq>
    */

    RoomModel *roomModel = nil;
    roomModel = [xmppRoomList_ objectForKey:room];
    if (roomModel == nil) {
        return;
    }
    NSArray *elemets = [query children];
    
    for (NSXMLElement *node in elemets) {
        if ([[node name] isEqualToString:@"feature"])
        {
            NSString *value = [node attributeStringValueForName:@"var"];
            if ([value isEqualToString:PROTOCOL_MUC_PASSWORDPROTECTED])
            {
                roomModel.muc_passwordprotected = YES;
            } else if ([value isEqualToString:@"muc_public"]) {
                roomModel.muc_public = YES;
            }
            
        } else if ([[node name] isEqualToString:@"x"]) {//[node elementForName:@"x" xmlns:@"jabber:x:data"]) {
            NSArray *fields = [node children];
            
            for (NSXMLElement *field in fields) {
                NSString *var = [field attributeStringValueForName:@"var"];
                if ([var isEqualToString:@"x-muc#roominfo_creationdate"]) {
                    NSXMLNode *creationdate = [field elementForName:@"value"];
                    roomModel.roominfo_creationdate = [creationdate stringValue];
                } else if ([var isEqualToString:@"muc#roominfo_description"])
                {
                    NSXMLNode *value = [field elementForName:@"value"];//[[field childAtIndex:0] description];
                    NSString *description = [value stringValue];
                    if ([description compare:@"{location"] == NSOrderedAscending) {
                        continue;
                    }
                    
                    NSArray *array = [description componentsSeparatedByString:@";"];
                    NSString *location = [array objectAtIndex:0];
                    CLLocationCoordinate2D coordinate;
                    sscanf([location UTF8String], "{location:[%lf,%lf]", &coordinate.latitude, &coordinate.longitude);
                    roomModel.coordinatePosition = coordinate;

                    NSTimeInterval effectivetimeStart, effectivetimeEnd;
                    effectivetimeStart = effectivetimeEnd = 0;
                    if ([array count] > 1) {
                        NSString *effectivetime = [array objectAtIndex:1];
                        
                        sscanf([effectivetime UTF8String], "effectivetime:[%lg,%lg]}", &effectivetimeStart, &effectivetimeEnd);
//                        NSDate *start = [[NSDate alloc] initWithTimeIntervalSince1970:effectivetimeStart];
//                        NSDate *end = [NSDate dateWithTimeIntervalSince1970:effectivetimeEnd];
                        
//                        NSLog([start description]);
//                        NSLog([end description]);
                        roomModel.effectivetimeStart = effectivetimeStart;
                        roomModel.effectivetimeEnd = effectivetimeEnd;
                    }

                }
            }
        }
    }
    
}

#pragma mark Room

- (void)createRoom:(RoomModel *)roomModel
{
    NSLog(@"%s", __FUNCTION__);
    status_ = STATUS_CREATE_ROOM;

    createRoomModel = roomModel;
    
    //创建一个新的群聊房间,roomName是房间名 fullName是房间里自己所用的昵称
    NSString *jidRoom = [NSString stringWithFormat:@"%@@conference.%@", roomModel.roomName, DOMAIN_NAME];
    XMPPJID *jid = [XMPPJID jidWithString:jidRoom];

    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:jid dispatchQueue:dispatch_get_main_queue()];
    
    XMPPStream *stream = [self xmppStream];
    [room activate:stream];
    [room joinRoomUsingNickname:jabberID_ history:nil password:roomModel.password];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoomList_ setObject:room forKey:jidRoom];

}

- (void)joinRoom:(NSString *)roomjid password:(NSString *)password nickName:(NSString *)nickName
{
    NSLog(@"%s", __FUNCTION__);
    status_ = STATUS_JOIN_ROOM;

//    XMPPRoom *xmppRoom = [xmppRoomJoin objectForKey:roomjid];
//    if (xmppRoom == nil) {
        XMPPRoom *xmppRoom = [xmppRoomList_ objectForKey:roomjid];
        [xmppRoom joinRoomUsingNickname:jabberID_ history:nil password:password];
//        [xmppRoomJoin setObject:xmppRoom forKey:roomjid];
//    }
}

- (void)leaveRoom:(NSString *)roomjid
{
    NSLog(@"%s", __FUNCTION__);
    status_ = STATUS_LEAVE_ROOM;

    /*
     <presence
     from='hag66@shakespeare.lit/pda'
     to='darkcave@chat.shakespeare.lit/thirdwitch'
     type='unavailable'/>
    */ 
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable" to:[XMPPJID jidWithString:roomjid]];
    [presence addAttributeWithName:@"from" stringValue:jabberID_];
    
    [xmppStream sendElement:presence];

}

// 查看加入的room，change nickname
- (void)changeNickName:(NSString *)newNickName
{
    status_ = STATUS_CHANGE_NICKNAME;
    
    [xmppRoomList_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *xmppRoom = obj;
        [xmppRoom changeNickname:newNickName];
    }];
}

- (void)changeUserSexual:(BOOL)sexual
{
    [xmppRoomList_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *room = obj;
        [self updateMyPositionWithRoom:room];
    }];
}

- (void)updateMyPosition
{
    NSLog(@"%s", __FUNCTION__);
    [xmppRoomList_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *room = obj;
        [self updateMyPositionWithRoom:room];
    }];
}

- (void)updateMyPositionWithRoomName:(NSString *)roomName
{
    [xmppRoomList_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *room = obj;
        if ([roomName isEqualToString:room.roomName]) {
            [self updateMyPositionWithRoom:room];
            *stop = YES;
        }
    }];
    
}

- (void)updateMyPositionWithRoom:(XMPPRoom *)room
{
    NSLog(@"%s", __FUNCTION__);
    /*
     <message xmlns="jabber:client" type="groupchat" id="purpleffd8e6a0" to="24cefc6c@siteviewwzp/7793ccf6" from="123@conference.siteviewwzp/cw">
     <body>location:[28.17523,112.9803]</body>
     </message>
     
     <message xmlns="jabber:client" id="KDXqd-101" to="24cefc6c@siteviewwzp/c18b5d98" type="groupchat" from="123@conference.siteviewwzp/nexus10_03vn9l">
     <body>location:[28.1767119,112.977853]</body>
     <properties xmlns="http://www.jivesoftware.com/xmlns/xmpp/properties">
     <property><name>SendTime</name><value type="string">2013-08-21 18:25:58</value></property>
     <property><name>SendLocation</name><value type="string">{location:[28.1767119,112.977853]}</value></property>
     <property><name>SendUser</name><value type="string">nexus10_03vn9l@siteviewwzp/Smack</value></property>
     <property><name>UserGender</name><value type="integer">0</value></property>
     </properties>
     <delay xmlns="urn:xmpp:delay" stamp="2013-08-21T10:26:55.035Z" from="nexus10_03vn9l@siteviewwzp/Smack"/>
     <x xmlns="jabber:x:delay" stamp="20130821T10:26:55" from="nexus10_03vn9l@siteviewwzp/Smack"/>
     </message>
     

     */
    XMPPMessage *mes = [XMPPMessage messageWithType:@"groupchat" to:room.roomJID];
    
    [mes addAttributeWithName:@"from" stringValue:jabberID_];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    NSString *stringValue = [NSString stringWithFormat:@"location:[%lf,%lf]", myLocation.latitude, myLocation.longitude];
    [body setStringValue:stringValue];
//    [mes addChild:body];
    
    NSXMLElement *properties = [NSXMLElement elementWithName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
/*    {
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:@"SendTime"];
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:@"SendTime"];
        [value addAttributeWithName:@"type" stringValue:@"string"];

        [property addChild:name];
        [property addChild:value];
        [properties addChild:property];
    }
*/
    // SendLocation
    {
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:@"SendLocation"];
        
        NSString *SendLocation = [NSString stringWithFormat:@"{location:[%lf,%lf]}", myLocation.latitude, myLocation.longitude];
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:SendLocation];
        [value addAttributeWithName:@"type" stringValue:@"string"];
        
        [property addChild:name];
        [property addChild:value];
        [properties addChild:property];
    }
    
    // UserGender
    {
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:@"UserGender"];
        
        NSString *UserGender = [NSString stringWithFormat:@"%d", [UserProperty sharedInstance].UserGender];
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:UserGender];
        [value addAttributeWithName:@"type" stringValue:@"integer"];
        
        [property addChild:name];
        [property addChild:value];
        [properties addChild:property];
    }
    [mes addChild:properties];

    //发送消息
    [xmppStream sendElement:mes];
}

- (void)sendRoomMessage:(NSString *)roomName message:(NSString *)message
{
    /*
     <message
     from='hag66@shakespeare.lit/pda'
     id='hysf1v37'
     to='coven@chat.shakespeare.lit'
     type='groupchat'>
     <body>Harpier cries: 'tis time, 'tis time.</body>
     </message>
     
     <message type="groupchat" to="&#x6D4B;&#x8BD5;@conference.siteviewwzp/cw" from="d2ecf8dd@siteviewwzp/1e960fb5"><body>aaaaaa</body></message>
     <message type="groupchat" to="&#x6D4B;&#x8BD5;@conference.siteviewwzp/cw" from="af7c55a7@siteviewwzp/a6c19564"><body>eeee</body></message>
     */
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    //生成XML消息文档
    XMPPMessage *mes = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomName]];
    //消息类型
//    [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
    //发送给谁
//    [mes addAttributeWithName:@"to" stringValue:roomName];
    //由谁发送
//    NSString *from = [NSString stringWithFormat:@"%@/%@", roomName, jabberID_];
    [mes addAttributeWithName:@"from" stringValue:jabberID_];
    //组合
    [mes addChild:body];
    
    //发送消息
    [[self xmppStream] sendElement:mes];

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSDictionary *)managedObjectContext_rooms
{
    return [xmppRoomList_ copy];
}

- (NSArray *)managedObjectContext_roomMessage:(NSString *)roomName
{
    NSMutableArray *messageArray = [messageList objectForKey:roomName];
    if (messageArray == nil) {
        messageArray = [NSMutableArray array];
        
        [messageList setObject:messageArray forKey:roomName];
    }
    
    return [messageArray copy];
}

- (NSManagedObjectContext *)managedObjectContext_room
{
	return [xmppRoomStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoom Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // create room success
    [createRoomDelegate didCreateRoomSuccess];
    
    [sender fetchConfigurationForm];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    /*
     <x xmlns="jabber:x:data" type="form">
        <title>房间配置</title>
        <instructions>已创建房间“efa”。要接受缺省配置，请单击“确定”按钮。或填写以下表单以完成设置：</instructions>
        <field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roomconfig</value></field>
        <field var="muc#roomconfig_roomname" type="text-single" label="房间名称"><value>efa</value></field>
     <field var="muc#roomconfig_roomdesc" type="text-single" label="描述"><value>efa</value></field>
     <field var="muc#roomconfig_changesubject" type="boolean" label="允许占有者更改主题"><value>0</value></field>
     <field var="muc#roomconfig_maxusers" type="list-single" label="最大房间占有者人数"><option label="10"><value>10</value></option><option label="20"><value>20</value></option><option label="30"><value>30</value></option><option label="40"><value>40</value></option><option label="50"><value>50</value></option><option label="无"><value>0</value></option><value>30</value></field>
     <field var="muc#roomconfig_presencebroadcast" type="list-multi" label="其 Presence 是 Broadcast 的角色"><option label="主持者"><value>moderator</value></option><option label="参与者"><value>participant</value></option><option label="访客"><value>visitor</value></option><value>moderator</value><value>2013-08-12 15:30:15.123 ChatTest[3132:c07] <message xmlns="jabber:client" type="groupchat" from="efa@conference.siteviewwzp" to="57787d89@siteviewwzp/a6f7f906"><body>确认配置之前已锁住该房间，禁止进入。</body></message>
     participant</value><value>visitor</value></field>
     <field var="muc#roomconfig_publicroom" type="boolean" label="列出目录中的房间"><value>1</value></field>
     <field var="muc#roomconfig_persistentroom" type="boolean" label="房间是持久的"><value>0</value></field>
     <field var="muc#roomconfig_moderatedroom" type="boolean" label="房间是适度的"><value>0</value></field>
     <field var="muc#roomconfig_membersonly" type="boolean" label="房间仅对成员开放"><value>0</value></field>
     <field type="fixed"><value>注意：缺省情况下，只有管理员才可以在仅用于邀请的房间中发送邀请。</value></field>
     <field var="muc#roomconfig_passwordprotectedroom" type="boolean" label="需要密码才能进入房间"><value>0</value></field>
     <field type="fixed"><value>如果需要密码才能进入房间，则您必须在下面指定密码。</value></field>
     <field var="muc#roomconfig_roomsecret" type="text-private" label="密码"/>
     <field var="muc#roomconfig_whois" type="list-single" label="能够发现占有者真实 JID 的角色"><option label="主持者"><value>moderators</value></option><option label="任何人"><value>anyone</value></option><value>anyone</value></field>
     <field var="muc#roomconfig_enablelogging" type="boolean" label="登录房间对话"><value>0</value></field>
     <field var="x-muc#roomconfig_reservednick" type="boolean" label="仅允许注册的昵称登录"><value>0</value></field>
     <field var="x-muc#roomconfig_canchangenick" type="boolean" label="允许使用者修改昵称"><value>1</value></field>
     <field type="fixed"><value>允许用户注册房间</value></field>
     <field var="x-muc#roomconfig_registration" type="boolean" label="允许用户注册房间"><value>1</value></field>
     <field type="fixed"><value>您可以指定该房间的管理员。请在每行提供一个 JID。</value></field>
     <field var="muc#roomconfig_roomadmins" type="jid-multi" label="房间管理员"/>
     <field type="fixed"><value>您可以指定该房间的其他拥有者。请在每行提供一个 JID。</value></field>
     <field var="muc#roomconfig_roomowners" type="jid-multi" label="房间拥有者"><value>57787d89@siteviewwzp</value></field>
     </x>
     */
    for (NSXMLElement *element in [configForm children]) {
        if ([[element name] isEqualToString:@"field"]) {
            NSString *var = [element attributeStringValueForName:@"var"];
            if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
                // 描述
                // <field var="muc#roomconfig_roomdesc" type="text-single" label="描述"><value>efa</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        NSString *roomdesc = [NSString stringWithFormat:@"{location:[%lf,%lf];effectivetime:[%.lf,%.lf]}", createRoomModel.coordinatePosition.latitude, createRoomModel.coordinatePosition.longitude, createRoomModel.effectivetimeStart, createRoomModel.effectivetimeEnd];
                        [value setStringValue:roomdesc];
                    }
                }
            } else if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
                // 设置聊天室是持久聊天室，即将要被保存下来
                // <field var="muc#roomconfig_persistentroom" type="boolean" label="房间是持久的"><value>0</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"1"];
                    }
                }
            } else if ([var isEqualToString:@"muc#roomconfig_membersonly"]) {
                // 房间对所有人开放
                // <field var="muc#roomconfig_membersonly" type="boolean" label="房间仅对成员开放"><value>0</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"0"];
                    }
                }
            } else if ([var isEqualToString:@"muc#roomconfig_allowinvites"]) {
                // 允许占有者邀请其他人
                // <field var="muc#roomconfig_allowinvites" type="boolean" label="允许占有者邀请其他人"><value>0</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"1"];
                    }
                }
            } else if ([var isEqualToString:@"muc#roomconfig_enablelogging"]) {
                // 登录房间对话
                // <field var="muc#roomconfig_enablelogging" type="boolean" label="登录房间对话"><value>0</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"0"];
                    }
                }
            } else if ([var isEqualToString:@"x-muc#roomconfig_reservednick"]) {
                // 仅允许注册的昵称登录
                // <field var="x-muc#roomconfig_reservednick" type="boolean" label="仅允许注册的昵称登录"><value>0</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"0"];
                    }
                }
            } else if ([var isEqualToString:@"x-muc#roomconfig_canchangenick"]) {
                // 允许使用者修改昵称
                // <field var="x-muc#roomconfig_canchangenick" type="boolean" label="允许使用者修改昵称"><value>1</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"0"];
                    }
                }
            } else if ([var isEqualToString:@"x-muc#roomconfig_registration"]) {
                // 允许用户注册房间
                // <field var="x-muc#roomconfig_registration" type="boolean" label="允许用户注册房间"><value>1</value></field>
                for (NSXMLElement *value in [element children]) {
                    if ([[value name] isEqualToString:@"value"]) {
                        [value setStringValue:@"0"];
                    }
                }
            }

        }
    }
    
//    NSLog([configForm description]);
    
    // 提交配置
    [sender configureRoomUsingOptions:configForm];
}



- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
	NSLog(@"%s", __FUNCTION__);
    [sender fetchMembersList];
    
    [roomsDelegate didJoinRoomSuccess:[sender.roomJID full]];
//    [sender fetchModeratorsList];
    /*
     <iq to='staff158@chat.fayfox'
     type='get'
     id='userlist' xmlns='jabber:client'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
     </iq>

    NSString *fetchID = [xmppStream generateUUID];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:DISCO_ITEMS];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[sender roomJID] elementID:fetchID child:query];
    
    [xmppStream sendElement:iq];
     */

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    /*
    <iq xmlns="jabber:client" type="error" id="F683DD2A-30D2-4308-8956-68EED29E8359" from="&#x6D4B;&#x8BD5;@conference.siteviewwzp" to="ff398ab1@siteviewwzp/ff2d8f53">
    <query xmlns="http://jabber.org/protocol/muc#admin">
    <item affiliation="member"/>
    </query>
    <error code="403" type="auth">
    <forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
    </error>
    </iq>
    */
    if ([iqError isErrorIQ]) {
        // 
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}


//是否已经加入房间
-(void)xmppRoom:(XMPPRoom*)room didEnter:(BOOL)enter{
	NSLog(@"%@:%@", [[self class] description], @"didEnter");
}
//是否已经离开
-(void)xmppRoom:(XMPPRoom*)room didLeave:(BOOL)leave{
	NSLog(@"%@",@"didLeave");
}

//收到群聊消息
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self processGroupChatMessage:message];
/*
	NSLog(@"%@", message);
    
//    NSString *type = [message isChatMessage];
    
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    // from="&#x6D4B;&#x8BD5;@conference.siteviewwzp/352DF48F@siteviewwzp">
    NSArray *array = [from componentsSeparatedByString:@"/"];
    
    // room name
    NSString *roomName = [array objectAtIndex:0];
    NSString *senderName = [array lastObject];
    if ([senderName length] == 0) {
        senderName = roomName;
    }
    
    NSString *to = [[message attributeForName:@"to"] stringValue];
    

    
    if ([message isGroupChatMessage]) {
        [self processGroupChatMessage:message];
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:body forKey:@"msg"];
        [dict setObject:from forKey:@"sender"];
        //消息接收到的时间
        [dict setObject:[self getCurrentTime] forKey:@"time"];
        
        //        [messageDelegate newMessageReceived:dict];
    }
*/ 
}

- (void)processGroupChatMessage:(XMPPMessage *)message
{
    /*
     <message xmlns="jabber:client" id="KDXqd-101" to="24cefc6c@siteviewwzp/c18b5d98" type="groupchat" from="123@conference.siteviewwzp/nexus10_03vn9l">
     <body>location:[28.1767119,112.977853]</body>
     <properties xmlns="http://www.jivesoftware.com/xmlns/xmpp/properties">
        <property>
            <name>SendTime</name>
            <value type="string">2013-08-21 18:25:58</value></property>
        <property><name>SendLocation</name><value type="string">{location:[28.1767119,112.977853]}</value></property>
        <property><name>SendUser</name><value type="string">nexus10_03vn9l@siteviewwzp/Smack</value></property>
        <property><name>UserGender</name><value type="integer">0</value></property>
     </properties>
     <delay xmlns="urn:xmpp:delay" stamp="2013-08-21T10:26:55.035Z" from="nexus10_03vn9l@siteviewwzp/Smack"/>
     <x xmlns="jabber:x:delay" stamp="20130821T10:26:55" from="nexus10_03vn9l@siteviewwzp/Smack"/>
     </message>

     */
    NSString *from = [[message attributeForName:@"from"] stringValue];
    // from="&#x6D4B;&#x8BD5;@conference.siteviewwzp/352DF48F@siteviewwzp">
    NSArray *array = [from componentsSeparatedByString:@"/"];
    
    // room name
    NSString *roomJid = [array objectAtIndex:0];
    NSString *senderName = [array lastObject];
    if ([senderName length] == 0) {
        senderName = roomJid;
    }

    RoomModel *room = [xmppRoomList_ objectForKey:roomJid];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // room messages
    NSMutableArray *messageArray = [messageList objectForKey:roomJid];
    if (messageArray == nil) {
        messageArray = [NSMutableArray array];
        
        [messageList setObject:messageArray forKey:from];
    }
    
    NSString *to = [[message attributeForName:@"to"] stringValue];

    // message attribute
    [dict setObject:senderName forKey:@"sender"];

    NSString *body = [[message elementForName:@"body"] stringValue];
    if (body != nil) {
        // location:[28.1767081,112.9779156]
        if ([body hasPrefix:@"location"]) {
            CLLocationCoordinate2D location;
            
            sscanf([body UTF8String], "location:[%lf,%lf]", &location.latitude, &location.longitude);
            
            //        NSString *log = [NSString stringWithFormat:@"%lf, %lf", location.latitude, location.longitude];
            //        NSLog(log);
            
            // update member position
            RoomModel *room = [xmppRoomList_ objectForKey:roomJid];

            // 24cefc6c@siteviewwzp/2080b101
            NSArray *arrayTo = [to componentsSeparatedByString:@"/"];
            
            // nick name
            NSString *toName = [arrayTo objectAtIndex:0];
            NSArray *arrayToName = [toName componentsSeparatedByString:@"@"];
            NSString *toNickName = [arrayToName objectAtIndex:0];
            
            if (room.members == nil) {
                room.members = [NSMutableDictionary dictionary];
            }
            
            MemberProperty *member = [room.members objectForKey:toNickName];
            if (member == nil) {
                member = [[MemberProperty alloc] init];
                member.name = toNickName;
                [room.members setObject:member forKey:toNickName];
            }
            if ([[toNickName uppercaseString] isEqualToString:[UserProperty sharedInstance].nickName] ) {
                member.sexual = [UserProperty sharedInstance].sex;
            }

            member.coordinatePosition = location;
            [chatDelegate updateBuddyOnline:member.name coordinate:location color:member.color];
            
            return;
        } else {
            
            [dict setObject:body forKey:@"msg"];
            
            [messageArray addObject:dict];
        }
    }

    // Smack指定的属性
    // 获取属性
    NSXMLElement *properties = [message elementForName:@"properties" xmlns:XMPP_PROPERTIES];
    if (properties) {
        for (NSXMLElement *node in [properties children]) {
            
            NSString *name;
            NSString *value;
            for (NSXMLElement *node2 in [node children]) {
                
                if ([[node2 name] isEqualToString:@"name"]) {
                    name = [node2 stringValue];
                } else if ([[node2 name] isEqualToString:@"value"]) {
                    value = [node2 stringValue];
                }
            }
            [dict setObject:value forKey:name];
        }
    }
/*
    if ([dict objectForKey:@"SendTime"] == nil) {
        //消息接收到的时间
        [dict setObject:[self getCurrentTime] forKey:@"SendTime"];
    }
*/ 
    if ([dict objectForKey:@"SendUser"] == nil) {
        [dict setObject:senderName forKey:@"SendUser"];
    }
    
    // 24cefc6c@siteviewwzp/2080b101
    NSArray *arrayTo = [to componentsSeparatedByString:@"/"];
    
    // nick name
    NSString *toName = [arrayTo objectAtIndex:0];
    NSArray *arrayToName = [toName componentsSeparatedByString:@"@"];
    NSString *toNickName = [arrayToName objectAtIndex:0];
    if (room.members == nil) {
        room.members = [NSMutableDictionary dictionary];
    }
    
    MemberProperty *member = [room.members objectForKey:toNickName];
    if (member == nil) {
        member = [[MemberProperty alloc] init];
        member.name = toNickName;
        [room.members setObject:member forKey:toNickName];
    }
    
    BOOL isMemberInfoCHange = NO;
    NSString *UserGender = [dict objectForKey:@"UserGender"];
    if ([UserGender length] > 0) {
        if ([UserGender isEqualToString:@"0"]) {
            //
            if ([member.sexual isEqualToString:@"Female"]) {
                member.sexual = @"Male";
                isMemberInfoCHange = YES;
            }
        } else {
            if ([member.sexual isEqualToString:@"Male"]) {
                member.sexual = @"Female";
                isMemberInfoCHange = YES;
            }
        }
    }
    if ([toNickName isEqualToString:[UserProperty sharedInstance].nickName]) {
        member.sexual = [UserProperty sharedInstance].sex;
        isMemberInfoCHange = YES;
    }
    
    NSString *SendLocation = [dict objectForKey:@"SendLocation"];
    if ( SendLocation != nil) {
        // {location:[28.1767439,112.9779327]}
        CLLocationCoordinate2D location;
        
        sscanf([SendLocation UTF8String], "{location:[%lf,%lf]}", &location.latitude, &location.longitude);

        member.coordinatePosition = location;
        isMemberInfoCHange = YES;

    }
    
    if (isMemberInfoCHange) {
        [chatDelegate newBuddyOnline:member.name coordinate:member.coordinatePosition color:member.color];
    } else {
        [roomMessageDelegate newMessageReceived:[messageArray copy] from:senderName to:to];
    }
//    [chatDelegate]
}

- (void)xmppRoom:(XMPPRoom *)room didReceiveMessage:(NSString*)message fromNick:(NSString*)nick
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSLog(@"xmppRoom:didReceiveMessage:%@",message);
}
//房间人员列表发生变化
-(void)xmppRoom:(XMPPRoom*)room didChangeOccupants:(NSDictionary*)occupants
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSLog(@"%@",@"didChangeOccupants");
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoomStorage Protocol
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue
{
	return YES;
}

@end
