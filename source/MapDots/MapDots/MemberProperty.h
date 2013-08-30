//
//  MemberProperty.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

@interface MemberProperty : NSObject

@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sexual;
@property (nonatomic) BOOL UserGender;

@property (nonatomic, readonly, strong) UIColor *color;
@property (nonatomic) CLLocationCoordinate2D coordinatePosition;

@end
