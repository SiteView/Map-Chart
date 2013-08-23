//
//  MessageListCell.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListCell : UITableViewCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageContentView;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *headImageView;

@end
