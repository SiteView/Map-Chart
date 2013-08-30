//
//  MessageCell.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-12.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageContextCell : UITableViewCell

@property(nonatomic, retain) UILabel *senderAndTimeLabel;
@property(nonatomic, retain) UITextView *messageContentView;
@property(nonatomic, retain) UIImageView *bgImageView;

@end
