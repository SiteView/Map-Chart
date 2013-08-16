//
//  XMPPAuthenticateDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
@protocol XMPPAuthenticateDelegate <NSObject>

- (void)didConnect:(XMPPStream *)sender;
- (void)didAuthenticate:(XMPPStream *)sender;
- (void)didNotAuthenticate:(NSXMLElement *)authResponse;
- (void)didRegister:(XMPPStream *)sender;
- (void)didNotRegister:(NSXMLElement *)error;

@end
