//
//  RoomContextCell.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-15.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomContextCell : UITableViewCell
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UIImageView *lockImageView;
}
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *lockImageView;

@end
