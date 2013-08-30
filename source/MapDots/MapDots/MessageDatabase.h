//
//  MessageDatabase.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import "/usr/include/sqlite3.h"

@interface MessageDatabase : NSObject

@property (nonatomic, readonly) BOOL isOpenDatabase_;

@end
