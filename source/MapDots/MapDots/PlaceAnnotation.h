//
//  PlaceAnnotation.h
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSURL *url;

@end
