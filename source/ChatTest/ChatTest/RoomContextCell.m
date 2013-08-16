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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 锁
        lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"room_lock" ofType:@"png"];
        lockImageView.image = [UIImage imageWithContentsOfFile:path];
        [self.contentView addSubview:lockImageView];
        
        // room name
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 100, 30)];
        //居中显示
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        //文字颜色
        [self.contentView addSubview:titleLabel];

        // time
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 50, 20)];
        //居中显示
        timeLabel.textAlignment = UITextAlignmentRight;
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

@end
