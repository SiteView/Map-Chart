//
//  LoginViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPAuthenticateDelegate.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, XMPPAuthenticateDelegate> {
    id                              m_target_login;//assign   local login callback
    SEL                             m_selector_login;

}

- (void) setLoginFinish:(id)target callback:(SEL)selector;

@end
