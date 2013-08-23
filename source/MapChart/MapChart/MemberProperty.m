//
//  MemberProperty.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-19.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MemberProperty.h"

@implementation MemberProperty

@synthesize jid;
@synthesize name;
@synthesize UserGender;
@synthesize color;
@synthesize sexual = _sexual;

- (id)init
{
    if ((self = [super init]))
    {
        _sexual = @"Female";
        UserGender = 1;
        color = [UIColor redColor];
    }
    return self;
}

- (void)setSexual:(NSString *)newSexual
{
    if ([newSexual isEqualToString:@"Female"]) {
        UserGender = 1;
        color = [UIColor redColor];
    } else {
        UserGender = 0;
        color = [UIColor blueColor];
    }
    _sexual = newSexual;
}
@end
