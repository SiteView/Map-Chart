//
//  MessageListCell.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MessageListCell.h"

@implementation MessageListCell

@synthesize titleLabel;
@synthesize messageContentView;
@synthesize headImageView;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 大头贴
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 40, 40)];
        [self.contentView addSubview:headImageView];
        
        // 发送者
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 3, self.contentView.bounds.size.width - 40, 15)];

        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont boldSystemFontOfSize:12.0];

        [self.contentView addSubview:titleLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 70, 3, 50, 15)];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];

        //聊天信息
        messageContentView = [[UILabel alloc] initWithFrame:CGRectMake(41, 18, self.contentView.bounds.size.width - 40, self.contentView.bounds.size.height - 18)];
//        messageContentView.backgroundColor = [UIColor clearColor];
        messageContentView.font = [UIFont systemFontOfSize:11.0];
        //不可编辑
//        messageContentView.allowsEditingTextAttributes = NO;
        messageContentView.textAlignment = NSTextAlignmentLeft;

//        [messageContentView sizeToFit];
        [self.contentView addSubview:messageContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
