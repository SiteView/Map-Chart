//
//  UserPropertyCoreDataStorageObject.h
//  MapDots
//
//  Created by siteview_mac on 13-8-29.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserPropertyCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSNumber * sexual;
@property (nonatomic, retain) NSString * sexualStr;

@end
