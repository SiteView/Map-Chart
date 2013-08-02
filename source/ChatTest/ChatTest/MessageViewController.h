//
//  MessageViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-12.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPMessageDelegate.h"

@interface MessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, XMPPMessageDelegate>

@property(nonatomic, retain) NSString *chatWithUser;

@end
