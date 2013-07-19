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

@implementation AppDelegate {
    NSString *jabberID_;
    NSString *password_;
    BOOL isXMPPStreamOpen;
    NSMutableArray *roomModel_;
}

#define DISCO_INFO  @"http://jabber.org/protocol/disco#info"
#define PROTOCOL_MUC   @"http://jabber.org/protocol/muc"
#define PROTOCOL_MUC_PASSWORDPROTECTED       @"muc_passwordprotected"
#define DISCO_ITEMS  @"http://jabber.org/protocol/disco#items"

@synthesize xmppStream;
@synthesize authenticateDelegate;
@synthesize chatDelegate;
@synthesize messageDelegate;
@synthesize roomsDelegate;
@synthesize server_;
@synthesize isOnline;

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

#pragma make XMPPDelegate

- (void)setupStream:(NSString *)hostName {
    isOnline = NO;
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream setHostName:hostName];
    //    [xmppStream setHostPort:5222];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}

- (BOOL)connect:(NSString *)userId password:(NSString *)password serverName:(NSString *)serverName server:(NSString *)server {
    [self setupStream:server];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || password == nil) {
        return NO;
    }
    
//    server = @"127.0.0.1";
    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", userId, serverName];
    
    jabberID_ = jabberID;
    //    [xmppStream setMyJID:[XMPPJID jidWithString:userId]];
    //    [xmppStream setHostName:server];
    XMPPJID *xmppJid = [XMPPJID jidWithString:jabberID];
    [xmppStream setMyJID:xmppJid];
    password_ = password;
//    server_ = @"172.16.0.16";
    server_ = serverName;
    
    NSTimeInterval ti = 50 * 1000;
    NSError *error = nil;
    //    if (![xmppStream connectToHost:])
    //    if (![xmppStream connectWithTimeout:ti error:&error]) {
    if (![xmppStream connect:&error]) {
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

#pragma make XMPP

//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    isXMPPStreamOpen = YES;
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
    [self goOffline];
    
    [authenticateDelegate didNotAuthenticate:authResponse];
}

- (NSString *)getCurrentTime{
    
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}

// 查询消息
- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSString *type = [iq type];
    DDXMLNode *from = [iq attributeForName:@"from"];
    
    NSXMLElement *elements = [iq childElement];
    NSArray *childrens = [iq elementsForName:@"query"];
	for (NSXMLElement *child in childrens)
	{
        NSArray *names = [child namespaces];
        NSXMLNode *xmlns = [names objectAtIndex:0];
        if (xmlns != nil) {
            NSLog([xmlns stringValue]);
            
            NSString *value = [xmlns stringValue];
            if ([value compare:DISCO_INFO] == NSOrderedSame) {
                if ([[from stringValue] compare:server_] == NSOrderedSame) {
                    [self parseDiscoInfo:child];
                } else {
                    // 指定房间信息
                    [self parseDiscoInfo:child roomid:from];
                }
            } else if ([value compare:DISCO_ITEMS] == NSOrderedSame) {
                [self parseDiscoItems:child];
            }
 
        }
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
            NSLog([href stringValue]);
            
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
    [self searchRooms];
    
}

// 获得指定房间的房间属性：是否加密房间
- (void)parseDiscoInfo:(NSXMLElement *)query roomid:(NSString *)room
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
    
    BOOL isSupportMUC = NO;
    
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

    // 询问房间情况
    for (RoomModel* key in roomModel_) {
        [self queryRoomsInfo:key.jid];
    }
    [roomsDelegate newRoomsReceived:roomModel_];
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    //    NSLog(@"message = %@", message);
    
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
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    //    NSLog(@"presence = %@", presence);
    
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
    
}

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

@end
