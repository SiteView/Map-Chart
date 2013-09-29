//
//  EditNameViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNameViewController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id m_target_edit;
    SEL m_selector_edit;
}

@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *account;

- (void)setEditFinish:(id)target callback:(SEL)selector;

@end
