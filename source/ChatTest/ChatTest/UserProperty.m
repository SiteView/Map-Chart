//
//  UserProperty.m
//  ChatTest
//
//  Created by chenwei on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "UserProperty.h"
#import <objc/runtime.h>

#define DOMAIN_NAME @"192.168.9.11"
#define DOMAIN_URL  @"siteviewwzp"

@interface UserProperty ()
{
    NSString *nickName;
    NSString *account;
    NSString *password;
    NSString *serverName;
    NSString *serverAddress;
    
	dispatch_queue_t userPropertyQueue;
    void *userPropertyQueueTag;

}

@end
@implementation UserProperty

static UserProperty *sharedInstance;

+ (UserProperty *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedInstance = [[UserProperty alloc] init];
	});
	
	return sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
	{
        // Get the stored data before the view loads
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        nickName = [defaults objectForKey:NICK_NAME];
        account = [defaults objectForKey:ACCOUNT_NAME];
        password = [defaults objectForKey:PASSWORD_NAME];

        serverAddress = DOMAIN_NAME;
        serverName = DOMAIN_URL;

        userPropertyQueue = dispatch_queue_create(class_getName([self class]), NULL);
        
        userPropertyQueueTag = &userPropertyQueueTag;
        dispatch_queue_set_specific(userPropertyQueue, userPropertyQueueTag, userPropertyQueueTag, NULL);
        

    }
    return self;
}

- (BOOL)save
{
    __block BOOL result = NO;
    
	dispatch_block_t block = ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nickName forKey:NICK_NAME];
        [defaults setObject:account forKey:ACCOUNT_NAME];
        [defaults setObject:password forKey:PASSWORD_NAME];
        [defaults synchronize];
        
        result = YES;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
	if (userPropertyQueue)
		dispatch_release(userPropertyQueue);
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)nickName
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = nickName;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
	
	return result;
}

- (void)setNickName:(NSString *)newNickName
{
	dispatch_block_t block = ^{
		nickName = newNickName;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_async(userPropertyQueue, block);
}


- (NSString *)account
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = account;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
	
	return result;
}

- (void)setAccount:(NSString *)newAccount
{
	dispatch_block_t block = ^{
		account = newAccount;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_async(userPropertyQueue, block);
}


- (NSString *)password
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = password;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
	
	return result;
}

- (void)setPassword:(NSString *)newPassword
{
	dispatch_block_t block = ^{
		password = newPassword;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_async(userPropertyQueue, block);
}


- (NSString *)serverAddress
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = serverAddress;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
	
	return result;
}

- (void)setServerAddress:(NSString *)newServerAddress
{
	dispatch_block_t block = ^{
		serverAddress = newServerAddress;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_async(userPropertyQueue, block);
}


- (NSString *)serverName
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = serverName;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_sync(userPropertyQueue, block);
	
	return result;
}

- (void)setServerName:(NSString *)newServerName
{
	dispatch_block_t block = ^{
		serverName = newServerName;
	};
	
	if (dispatch_get_specific(userPropertyQueueTag))
		block();
	else
		dispatch_async(userPropertyQueue, block);
}

@end