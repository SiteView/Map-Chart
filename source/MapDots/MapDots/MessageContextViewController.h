//
//  RoomMessageViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-24.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageContextViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSString *roomName;

@end
