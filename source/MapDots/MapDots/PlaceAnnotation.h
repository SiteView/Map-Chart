//
//  PlaceAnnotation.h
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceAnnotation : NSObject <
#ifdef BAIDU_MAPS
BMKAnnotation
#else
MKAnnotation
#endif
>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSURL *url;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
