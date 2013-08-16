//
//  RoomsViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoomsDelegate.h"
#import <CoreData/CoreData.h>

@interface RoomsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
//            NSFetchedResultsControllerDelegate,
            XMPPRoomsDelegate>

@end
