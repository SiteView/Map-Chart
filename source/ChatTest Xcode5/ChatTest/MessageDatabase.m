//
//  MessageDatabase.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MessageDatabase.h"

@implementation MessageDatabase
{
}

static MessageDatabase *shareInstance_;
sqlite3 *database_;
char *errorMsg_;

@synthesize isOpenDatabase_;

- (id)init
{
    self = [super init];
    if (self) {
        shareInstance_ = nil;
        database_ = nil;
        errorMsg_ = NULL;
        isOpenDatabase_ = NO;
    }
    return self;
}

+ (MessageDatabase *)shareInstance
{
    @synchronized(self)
    {
        if (!shareInstance_) {
            shareInstance_ = [[MessageDatabase alloc] init];
        }
        return shareInstance_;
    }
    return nil;
}

+ (void)releaseInstance
{
    if (shareInstance_) {
        shareInstance_ = nil;
    }
}
- (BOOL)openDatabase
{
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES);
    
    NSString *databaseFilePath = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"message.db"];
    
    if (sqlite3_open([databaseFilePath UTF8String], &database_) != SQLITE_OK) {
        NSLog(@"Open sqlite db failure.");
        isOpenDatabase_ = NO;
        return NO;
    }
    isOpenDatabase_ = YES;
    return YES;
}

+ (BOOL)isOpenDatabase
{
    return [MessageDatabase shareInstance].isOpenDatabase_;
}

+ (void)closeDatabase
{
    if ([self isOpenDatabase]) {
        sqlite3_close(database_);
    }
}

+ (BOOL)createMessageTable
{
    const char *createSql = "CREATE TABLE IF NOT EXISTS Message (id integer primary key autoincrement, name_ text, time_ time, message_ text)";
    
    if (sqlite3_exec(database_, createSql, NULL, NULL, &errorMsg_) != SQLITE_OK) {
        NSLog(@"Create message table failure.");
        sqlite3_free(errorMsg_);
        return NO;
    }
    sqlite3_free(errorMsg_);
    return YES;
}

- (BOOL)addMessage:(NSString *)name message:(NSString *)message time:(NSString *)timer
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO Message (name_, time_, message_) VALUES('%@', '%@', '%@')", name, timer, message];
    if (sqlite3_exec(database_, [insertSql UTF8String], NULL, NULL, &errorMsg_) != SQLITE_OK) {
        sqlite3_free(errorMsg_);
        return NO;
    }
    sqlite3_free(errorMsg_);
    
    return YES;
}

// 获取指定top条记录
- (BOOL)getMessageRecord:(NSInteger)top array:(NSMutableDictionary *)records
{
    if (records == nil) {
        return NO;
    }
    NSString *selectSql = [NSString stringWithFormat:@"SELECT name_, timer_, message_ FROM Message top %d", top];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database_, [selectSql UTF8String], -1, &statement, nil) != SQLITE_OK) {
        return NO;
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *name = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
        NSString *timer = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
        NSString *message = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
        
        NSArray *array = @[name, timer, message];
        
        [records setObject:array forKey:name];
    }
    sqlite3_finalize(statement);
    return YES;
}
@end
