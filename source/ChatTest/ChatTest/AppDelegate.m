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

@implementation AppDelegate {
    NSString *password_;
    BOOL isXMPPStreamOpen;
}

@synthesize xmppStream;
@synthesize authenticateDelegate;
@synthesize chatDelegate;
@synthesize messageDelegate;
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

@end
