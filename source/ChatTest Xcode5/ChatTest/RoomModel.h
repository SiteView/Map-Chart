//
//  RoomModel.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RoomModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *roominfo_creationdate;

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
