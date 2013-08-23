//
//  EditSexViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-14.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditSexViewController : UIViewController
{
    id m_target_edit;
    SEL m_selector_edit;
}

@property (nonatomic, strong) NSString *sex;

- (void)setEditFinish:(id)target callback:(SEL)selector;

@end
