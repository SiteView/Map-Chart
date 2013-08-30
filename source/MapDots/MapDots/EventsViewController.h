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

@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
//            NSFetchedResultsControllerDelegate,
    XMPPAuthenticateDelegate, XMPPChatDelegate, XMPPRoomsDelegate
#ifdef GOOGLE_MAPS
    , GMSMapViewDelegate>
#else
, MKMapViewDelegate, CLLocationManagerDelegate>
#endif

@end
