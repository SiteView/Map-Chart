//
//  FriendsPositionViewController.h
//  MapDots
//
//  Created by siteview_mac on 13-9-17.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsPositionViewController : UIViewController<
#ifdef GOOGLE_MAPS
GMSMapViewDelegate
#else
#ifdef BAIDU_MAPS
BMKMapViewDelegate
#else
MKMapViewDelegate,
CLLocationManagerDelegate
#endif
#endif
    >

@property (nonatomic, strong) NSString *roomName;

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color;

@end
