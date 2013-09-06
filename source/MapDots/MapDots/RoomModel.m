//
//  RoomModel.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "RoomModel.h"

@implementation RoomModel

@synthesize roomName;
@synthesize password;
@synthesize members;
@synthesize roominfo_creationdate;
@synthesize muc_passwordprotected;
@synthesize muc_public;
@synthesize muc_open;
@synthesize muc_unmoderated;
@synthesize muc_semianonymous;
@synthesize muc_persistent;
@synthesize coordinatePosition;
@synthesize effectivetimeStart;
@synthesize effectivetimeEnd;

/*
- (id)init
{
    self = [super init];
    if (self) {
        items = [NSMutableDictionary dictionary];
    }
    return self;
}
*/
@end
