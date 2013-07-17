//
//  XMPPPackage.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "XMPPPackage.h"
#import "XMPP.h"
#import "XMPPAuthenticateDelegate.h"
static XMPPPackage* sharedInstance_;

@implementation XMPPPackage {
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isXMPPStreamOpen;
}
/*
+ (XMPPPackage *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance_ == nil)
            sharedInstance_ = [[self alloc] init];
    }
    return sharedInstance_;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance_ == nil) {
            sharedInstance_ = [super allocWithZone:zone];
            return sharedInstance_;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
*/
- (void)setupStream:(NSString *)hostName {
    xmppStream = [[XMPPStream alloc] init];
//    [xmppStream setHostName:hostName];
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

- (BOOL)connect:(NSString *)userId password:(NSString *)password server:(NSString *)server {
    [self setupStream:server];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || password == nil) {
        return NO;
    }
    
    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", userId, server];
//    [xmppStream setMyJID:[XMPPJID jidWithString:userId]];
//    [xmppStream setHostName:server];
    XMPPJID *xmppJid = [XMPPJID jidWithString:jabberID];
    [xmppStream setMyJID:xmppJid];
    
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

#pragma make XMPPStreamDelegate

- (void)xmppStreamConnect:(XMPPStream *)sender {
    isXMPPStreamOpen = YES;
    NSError *error = nil;
    [xmppStream authenticateWithPassword:password error:&error];
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self.authenticateDelegate didAuthenticate:sender];
//    [self goOnline];
}

// 验证未通过
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)authResponse{
    [self.authenticateDelegate didNotAuthenticate:sender];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];
    [dict setObject:from forKey:@"sender"];
    
//    [messageDelegate newMessageReceived:dict];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type];
    NSString *userId = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
/*
    if (![presenceFromUser isEqualToString:userId]) {
        if ([presenceType isEqualToString:@"available"]) {
            [chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [chatDelegate buddyWentOfflien:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
        }
    }
*/ 
}
@end
