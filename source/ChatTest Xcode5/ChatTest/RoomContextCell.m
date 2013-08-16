//
//  RoomContextCell.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-15.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "RoomContextCell.h"

@implementation RoomContextCell

@synthesize titleLabel;
@synthesize lockImageView;
@synthesize timeLabel;
/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 锁
        lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 40, 40)];
        lockImageView.image = [UIImage imageWithContentsOfFile:@"room_lock.png"];
        [self.contentView addSubview:lockImageView];
        
        // room name
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 100, 40)];
        //居中显示
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        //文字颜色
        [self.contentView addSubview:titleLabel];

        // time
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 300, 40)];
        //居中显示
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];

    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 */

@end
