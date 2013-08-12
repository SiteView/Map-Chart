//
//  UserProperty.h
//  ChatTest
//
//  Created by chenwei on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NICK_NAME   @"Nick Name"
#define ACCOUNT_NAME    @"account"
#define PASSWORD_NAME   @"password"

#define DOMAIN_NAME @"192.168.9.11"
#define DOMAIN_URL  @"siteviewwzp"


@interface UserProperty : NSObject

+ (UserProperty *)sharedInstance;

- (BOOL)save;

@property (strong, readwrite) NSString *nickName;
@property (strong, readwrite) NSString *account;
@property (strong, readwrite) NSString *password;
@property (strong, readwrite) NSString *serverName;
@property (strong, readwrite) NSString *serverAddress;

@end
