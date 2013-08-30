//
//  SearchPositionViewController.h
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPositionViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
{
    id m_target_edit;
    SEL m_selector_edit;
}

- (void)setFinish:(id)target action:(SEL)selector;

@end
