//
//  UserProperty.h
//  ChatTest
//
//  Created by chenwei on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NICK_NAME   @"Nick Name"
#define PEOPLE_SEX      @"Sex"
#define ACCOUNT_NAME    @"account"
#define PASSWORD_NAME   @"password"

#if TARGET_OS_IPHONE
    #define DOMAIN_NAME @"xmpp.siteview.com"
#else
#define DOMAIN_NAME @"xmpp.siteview.com"
//    #define DOMAIN_NAME  @"siteviewwzp"
#endif
//#define DOMAIN_NAME @"192.168.9.11"
//#define DOMAIN_URL  @"siteviewwzp"
//#define DOMAIN_URL  @"xmpp.siteview.com"
#define DOMAIN_PORT 5223

@interface UserProperty : NSObject

+ (UserProperty *)sharedInstance;

- (BOOL)save;
- (void)cancel;

@property (strong, readwrite) NSString *nickName;
@property (strong, readwrite) NSString *originalNickName;
@property (strong, readwrite) NSString *sex;
@property (strong, readwrite) NSString *originalSex;
@property (strong, readwrite) NSString *account;
@property (strong, readwrite) NSString *password;
//@property (strong, readwrite) NSString *serverName;
//@property (strong, readwrite) NSString *serverAddress;
// UserGender 表示性别 0代表男 1代表女
@property (readonly) BOOL UserGender;
@property (readonly) BOOL originalUserGender;

@end
