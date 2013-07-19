//
//  RoomModel.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *jid;
@property (nonatomic) BOOL isMucPasswordProtocted;

@end
