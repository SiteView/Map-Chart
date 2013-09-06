//
//  UserPropertyCoreDataStorage.h
//  MapDots
//
//  Created by siteview_mac on 13-9-2.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPropertyCoreDataStorage : NSObject
{
    dispatch_queue_t storageQueue;
	void *storageQueueTag;

}

+ (UserPropertyCoreDataStorage *)sharedInstance;

@end
