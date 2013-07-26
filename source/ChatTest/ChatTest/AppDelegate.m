//
//  AppDelegate.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//
#import "APIKey.h"
#import "AppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "PositionViewController.h"
#import "XMPPAuthenticateDelegate.h"
#import "XMPPMessageDelegate.h"
#import "XMPPChatDelegate.h"
#import "XMPPRoomsDelegate.h"
#import "RoomModel.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation AppDelegate {
    NSString *jabberID_;
    NSString *password_;
    BOOL isXMPPStreamOpen;
    NSMutableArray *roomModel_;
    BOOL isRoomInfo_;
    int rooms_;
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
@synthesize rosterstorage;
@synthesize xmppRoom;
@synthesize xmppMuc;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize authenticateDelegate;
@synthesize chatDelegate;
@synthesize messageDelegate;
@synthesize roomsDelegate;
@synthesize roomMessageDelegate;
@synthesize groupChatMessage;

@synthesize server_;
@synthesize isOnline;
@synthesize isXMPPRegister;
@synthesize registerSuccess;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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

	// Configure logging framework
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup the XMPP stream
    
	[self setupStream];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    FriendsViewController *friendsViewController = [[FriendsViewController alloc] init];
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:friendsViewController];
    PositionViewController *positionViewController = [[PositionViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:positionViewController];
    self.window.rootViewController = self.navigationController;
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

#pragma make -

- (void)dealloc
{
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
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
//	xmppReconnect = [[XMPPReconnect alloc] init];
	
    xmppMuc = [[XMPPMUC alloc] init];

    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
//	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
    [xmppMuc               activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];

    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
//	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
    [xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
//	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
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

- (BOOL)registery:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server
{
    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", userId, serverName];
    
    jabberID_ = jabberID;
    XMPPJID *xmppJid = [XMPPJID jidWithString:jabberID];
    [xmppStream setMyJID:xmppJid];
    password_ = password;
    server_ = serverName;
    
    NSTimeInterval ti = 50 * 1000;
    NSError *error = nil;
    
    if (![xmppStream registerWithPassword:password error:&error])
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
    registerSuccess = YES;
    isXMPPRegister = NO;
    NSLog(@"%@:%@", @"AppDelegate", @"xmppStreamDidRegister");
    
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

- (BOOL)connect:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server {
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || password == nil) {
        return NO;
    }
    
    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", userId, serverName];
    
    jabberID_ = jabberID;
    XMPPJID *xmppJid = [XMPPJID jidWithString:jabberID];
    [xmppStream setMyJID:xmppJid];
    password_ = password;
    server_ = serverName;
    
    NSTimeInterval ti = 50 * 1000;
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

//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    isXMPPStreamOpen = YES;

    if (isXMPPRegister) {
        [authenticateDelegate didConnect:sender];
        return;
    }
    
    NSError *error = nil;
//    server_ = sender.hostName;
    
    //验证密码
    [[self xmppStream] authenticateWithPassword:password_ error:&error];
    
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
    NSLog(@"%@:%@ %@", THIS_FILE, THIS_METHOD, message);
    
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
                        
                    default:
                        break;
                }
            }
        }
        
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
    
    [messageDelegate newMessageReceived:dict];
    
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"%@:%@ %@", THIS_FILE, THIS_METHOD, presence);
    /*
    <presence xmlns="jabber:client" id="UuKvk-124" type="unavailable" from="test1@siteviewwzp" to="fc6a3ed6@siteviewwzp/e6eef068">
        <x xmlns="vcard-temp:x:update">
        <photo>1531beb3a56bb3216a012bc3806522cc7c50782e</photo>
        </x>
        <x xmlns="jabber:x:avatar">
        <hash>1531beb3a56bb3216a012bc3806522cc7c50782e</hash>
        </x>
    </presence>
    // 出错
    /*
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
    */
    if ([presence isErrorPresence]) {
        NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCNamespace];
        // process error
        NSXMLElement *node = [presence elementForName:@"error"];
        if (node) {
            int32_t code = [node attributeInt32ValueForName:@"code"];
            NSString *type = [node attributeStringValueForName:@"type"];
            if ([type isEqualToString:@"auth"]) {
                switch (code) {
                    case 401:
                        // 密码认证失败
                        [roomsDelegate didJoinRoomFailure:@"密码认证失败"];
                        break;
                        
                    default:
                        break;
                }
            }
        }
        return;
    }
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            
            //用户列表委托
            [chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, server_]];
            
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            //用户列表委托
            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, server_]];
        }
        
    }
    
}

// 查询消息
- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if ([iq isResultIQ]) {
        NSXMLElement *query = [iq childElement];
        if ([iq elementForName:@"query" xmlns:DISCO_ITEMS]) {
            NSLog(@"Jabber Server's Capabilities: %@", [iq XMLString]);
            [self parseDiscoItems:query];
        } else if ([iq elementForName:@"query" xmlns:DISCO_INFO]) {
            NSXMLElement *identity = [query elementForName:@"identity"];
            if ([[identity attributeStringValueForName:@"category"] isEqualToString:@"conference"]) {
                NSString *groupChatDomain;
                groupChatDomain = [identity attributeStringValueForName:@"category"];
                NSLog(groupChatDomain);
            }
            if ([[iq fromStr] isEqualToString:server_]) {
                [self parseDiscoInfo:query];
            } else {
                // 指定房间信息
                [self parseDiscoInfoWithRoom:query roomid:[iq fromStr]];
            }
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

- (BOOL)querySupportMUC
{
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
    */
    [xmppCapabilities fetchCapabilitiesForJID:[XMPPJID jidWithString:server_]];
    
}
- (void)xmppCapabilities:(XMPPCapabilities *)sender didDiscoverCapabilities:(NSXMLElement *)caps forJID:(XMPPJID *)jid
{
//    NSLog([caps description]);
//    [self parseDiscoInfo:caps];

    if (isRoomInfo_ && rooms_ > 0) {
        for (RoomModel *room in roomModel_) {
            if ([room.jid isEqualToString:[jid description]]) {
                // 设置Room的属性
                NSLog([caps description]);
                [self parseDiscoInfoWithRoom:caps roomid:room.jid];
                
                rooms_ --;
                break;
            }
        }
    }
    if (rooms_ <= 0) {
        [roomsDelegate newRoomsReceived:roomModel_];
    }
}

- (void)parseDiscoInfo:(NSXMLElement *)query
{
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
     */
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
    [iq addAttributeWithName:@"to" stringValue:server_];
    
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
    NSString *strRoom = [NSString stringWithFormat:@"conference.%@", server_];
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
    NSMutableArray *array = [NSMutableArray array];
    NSArray *items = [query children];
    
    if (roomModel_ == nil) {
        roomModel_ = [NSMutableArray array];
    }
    
    for (NSXMLNode *node in items) {
        NSXMLElement *ele = [[NSXMLElement alloc] initWithXMLString:[node description] error:nil];
        NSXMLNode *jid = [ele attributeForName:@"jid"];
        NSXMLNode *name = [ele attributeForName:@"name"];
        if (jid != nil && name != nil) {
            
            RoomModel *room = [[RoomModel alloc] init];
            room.name = [name stringValue];
            room.jid = [jid stringValue];
  
            [roomModel_ addObject:room];
        }
    }
    isRoomInfo_ = YES;
    rooms_ = [roomModel_ count];
    
        // 询问房间情况
        for (RoomModel* key in roomModel_) {
            [xmppCapabilities fetchCapabilitiesForJID:[XMPPJID jidWithString:key.jid]];

    //        [self queryRoomsInfo:key.jid];
        }
//    [roomsDelegate newRoomsReceived:roomModel_];
}

// 查询房间信息
- (void)queryRoomsInfo:(NSString *)room
{
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
    NSArray *elemets = [query children];
    
    BOOL isMucPasswordProtected = NO;
    for (NSXMLNode *node in elemets) {
        NSXMLElement *ele = [[NSXMLElement alloc] initWithXMLString:[node description] error:nil];
        NSXMLNode *href = [ele attributeForName:@"var"];
        if (href != nil) {
            NSLog([href stringValue]);
            
            NSString *value = [href stringValue];
            if ([value compare:PROTOCOL_MUC_PASSWORDPROTECTED] == NSOrderedSame) {
                //
                href = nil;
                ele = nil;
                
                for (RoomModel *key in roomModel_) {
                    if ([key.jid compare:room] == NSOrderedSame) {
                        key.isMucPasswordProtocted = YES;
                        break;
                    }
                }
                break;
            }
        }
        href = nil;
        ele = nil;
    }
    
}

#pragma mark JoinRoom

- (void)joinRoom:(NSString *)roomjid password:(NSString *)password
{
    /*
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    //由谁发送
    [presence addAttributeWithName:@"from" stringValue:jabberID_];
    //发送给谁
    [presence addAttributeWithName:@"to" stringValue:roomjid];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"];
    //查询类型
    [x addAttributeWithName:@"xmlns" stringValue:PROTOCOL_MUC];
    
    //组合
    [presence addChild:x];
    
    //发送消息
    [[self xmppStream] sendElement:presence];
    */
/*
    if (rosterstorage != nil) {
        rosterstorage = nil;
    }
    rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];

    if (room != nil) {
        room = nil;
    }
*/
    XMPPRoomCoreDataStorage *roomstorage = [XMPPRoomCoreDataStorage sharedInstance];
    
//    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    if (xmppRoom != nil) {
        [xmppRoom removeDelegate:self];
        [xmppRoom deactivate];
        xmppRoom = nil;
    }
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomstorage
                                                           jid:[XMPPJID jidWithString:roomjid]
                                                 dispatchQueue:dispatch_get_main_queue()];
  
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:jabberID_ history:nil password:password];
//    [xmppRoom joinRoomUsingNickname:jabberID_ history:nil password:password_];
//    [room configureRoomUsingOptions:nil];
    //    [room fetchConfigurationForm];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_room
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//	return [rosterstorage mainThreadManagedObjectContext];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoom Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[xmppRoom fetchConfigurationForm];
	[xmppRoom fetchBanList];
	[xmppRoom fetchMembersList];
	[xmppRoom fetchModeratorsList];
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
	DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
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
	NSLog(@"%@  xmppRoom:didReceiveMessage:%@",[[self class] description], message);
    
//    NSString *type = [message isChatMessage];
    NSString *body = [[message elementForName:@"body"] stringValue];
    if (body == nil) {
        return;
    }
    
    // location:[28.1767081,112.9779156]
    if ([body hasPrefix:@"location"]) {
        CLLocationCoordinate2D *location;
        double latitude, longitude;
        
        sscanf([body UTF8String], "location:[%lf,%lf]", &latitude, &longitude);
     
        NSString *log = [NSString stringWithFormat:@"%lf, %lf", latitude, longitude];
        NSLog(log);
    }
    
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *to = [[message attributeForName:@"to"] stringValue];
    
    if ([message isGroupChatMessage]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
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
        [dict setObject:body forKey:@"msg"];
        [dict setObject:from forKey:@"sender"];

        if ([dict objectForKey:@"SendTime"] == nil) {
            //消息接收到的时间
            [dict setObject:[self getCurrentTime] forKey:@"SendTime"];
        }
        if ([dict objectForKey:@"SendUser"] == nil) {
            [dict setObject:from forKey:@"SendUser"];
        }
        
        [groupChatMessage addObject:dict];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:to forKey:@"userId"];
        [defaults setObject:from forKey:@"JoinRoom"];
        [defaults synchronize];
        
        // 群聊天消息
        [roomMessageDelegate newMessageReceived:[groupChatMessage mutableCopy] from:from to:to];
        
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:body forKey:@"msg"];
        [dict setObject:from forKey:@"sender"];
        //消息接收到的时间
        [dict setObject:[self getCurrentTime] forKey:@"time"];
        
        [messageDelegate newMessageReceived:dict];
    }
    

}

- (void)xmppRoom:(XMPPRoom *)room didReceiveMessage:(NSString*)message fromNick:(NSString*)nick
{
	NSLog(@"xmppRoom:didReceiveMessage:%@",message);
}
//房间人员列表发生变化
-(void)xmppRoom:(XMPPRoom*)room didChangeOccupants:(NSDictionary*)occupants{
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
