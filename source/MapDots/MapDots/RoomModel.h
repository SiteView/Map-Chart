//
//  RoomModel.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomModel : NSObject
/*
@property (readonly) XMPPJID * roomJID;     // E.g. xmpp-development@conference.deusty.com

@property (readonly) XMPPJID * myRoomJID;   // E.g. xmpp-development@conference.deusty.com/robbiehanson
@property (readonly) NSString * myNickname; // E.g. robbiehanson

@property (readonly) NSString *roomSubject;

// 表示是否已经加入房间
@property (readonly) BOOL isJoined;
*/
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *roominfo_creationdate;
@property (nonatomic, strong) NSMutableDictionary *members;

@property (nonatomic) BOOL muc_passwordprotected;
@property (nonatomic) BOOL muc_public;
@property (nonatomic) BOOL muc_open;
@property (nonatomic) BOOL muc_unmoderated;
@property (nonatomic) BOOL muc_semianonymous;
@property (nonatomic) BOOL muc_persistent;
@property (nonatomic) CLLocationCoordinate2D coordinatePosition;
@property (nonatomic) NSTimeInterval effectivetimeStart;
@property (nonatomic) NSTimeInterval effectivetimeEnd;

@end
