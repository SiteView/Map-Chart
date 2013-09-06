//
//  PlaceAnnotation.m
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
