//
//  RoomsViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPAuthenticateDelegate.h"
#import "XMPPChatDelegate.h"
#import "XMPPRoomsDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
    EGORefreshTableHeaderDelegate,
//            NSFetchedResultsControllerDelegate,
    XMPPAuthenticateDelegate, XMPPRoomsDelegate,
#ifdef GOOGLE_MAPS
    GMSMapViewDelegate
#else
#ifdef BAIDU_MAPS
BMKMapViewDelegate
#else
MKMapViewDelegate
#endif
#endif
, CLLocationManagerDelegate
>
@end
