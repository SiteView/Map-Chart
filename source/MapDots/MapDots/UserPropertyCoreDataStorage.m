//
//  UserPropertyCoreDataStorage.m
//  MapDots
//
//  Created by siteview_mac on 13-9-2.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import "UserPropertyCoreDataStorage.h"

@implementation UserPropertyCoreDataStorage
{
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *mainThreadManagedObjectContext;
}

static UserPropertyCoreDataStorage *sharedInstance;

+ (UserPropertyCoreDataStorage *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[UserPropertyCoreDataStorage alloc] init];
	});

	return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) {
        //
    }
    return self;
}

- (void)initCoreData
{
    NSError *error;
    
    // Path to sqlite file.
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/UserPropertyCoreDataStorage.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // Init the model
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Establish the persistent store coordinator
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    } else {
        // Create the context and assign the coordinator
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
}
@end
