//
//  UserPropertyCoreDataStorage.h
//  MapDots
//
//  Created by siteview_mac on 13-8-29.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPropertyCoreDataStorage : NSObject
{
@private

    NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *mainThreadManagedObjectContext;

@protected
	
	NSString *databaseFileName;
	NSUInteger saveThreshold;
	NSUInteger saveCount;
    
	BOOL autoRecreateDatabaseFile;
	
	dispatch_queue_t storageQueue;
	void *storageQueueTag;
}

- (id)initWithDatabaseFilename:(NSString *)databaseFileName;

@property (readonly) NSString *databaseFileName;

@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

@property (readwrite) BOOL autoRecreateDatabaseFile;

+ (UserPropertyCoreDataStorage *)sharedInstance;

@end
