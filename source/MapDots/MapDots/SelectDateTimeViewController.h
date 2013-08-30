//
//  SelectDateTimeViewController.h
//  MapChat
//
//  Created by siteview_mac on 13-8-26.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectDateTimeViewController : UIViewController
{
    id m_target_edit;
    SEL m_selector_edit;
}

- (void)initWithDate:(NSDate *)date;
- (void)setFinish:(id)target action:(SEL)selector;

@end
