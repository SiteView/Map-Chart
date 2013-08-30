//
//  UserPropertyCoreDataStorage.m
//  MapDots
//
//  Created by siteview_mac on 13-8-29.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import "UserPropertyCoreDataStorage.h"
#import "XMPPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation UserPropertyCoreDataStorage

static UserPropertyCoreDataStorage *sharedInstance;


+ (UserPropertyCoreDataStorage *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedInstance = [[UserPropertyCoreDataStorage alloc] initWithDatabaseFilename:nil];
	});
	
	return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Override Me
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)managedObjectModelName
{
	// Override me, if needed, to provide customized behavior.
	//
	// This method is queried to get the name of the ManagedObjectModel within the app bundle.
	// It should return the name of the appropriate file (*.xdatamodel / *.mom / *.momd) sans file extension.
	//
	// The default implementation returns the name of the subclass, stripping any suffix of "CoreDataStorage".
	// E.g., if your subclass was named "XMPPExtensionCoreDataStorage", then this method would return "XMPPExtension".
	//
	// Note that a file extension should NOT be included.
	
	NSString *className = NSStringFromClass([self class]);
	NSString *suffix = @"CoreDataStorage";
	
	if ([className hasSuffix:suffix] && ([className length] > [suffix length]))
	{
		return [className substringToIndex:([className length] - [suffix length])];
	}
	else
	{
		return className;
	}
}

- (NSBundle *)managedObjectModelBundle
{
    return [NSBundle bundleForClass:[self class]];
}

- (NSString *)defaultDatabaseFileName
{
	// Override me, if needed, to provide customized behavior.
	//
	// This method is queried if the initWithDatabaseFileName method is invoked with a nil parameter.
	//
	// You are encouraged to use the sqlite file extension.
	
	return [NSString stringWithFormat:@"%@.sqlite", [self managedObjectModelName]];
}

- (void)willCreatePersistentStoreWithPath:(NSString *)storePath
{
	// Override me, if needed, to provide customized behavior.
	//
	// If you are using a database file with pure non-persistent data (e.g. for memory optimization purposes on iOS),
	// you may want to delete the database file if it already exists on disk.
	//
	// If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
	// If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
}

- (BOOL)addPersistentStoreWithPath:(NSString *)storePath error:(NSError **)errorPtr
{
	// Override me, if needed, to completely customize the persistent store.
	//
	// Adds the persistent store path to the persistent store coordinator.
	// Returns true if the persistent store is created.
	//
	// If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
	// If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
    
    NSPersistentStore *persistentStore;
	
	if (storePath)
	{
		// SQLite persistent store
		
		NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
		
		// Default support for automatic lightweight migrations
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
		                         [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
		                         [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
		                         nil];
		
		persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
		                                                           configuration:nil
		                                                                     URL:storeUrl
		                                                                 options:options
		                                                                   error:errorPtr];
	}
	
    return persistentStore != nil;
}

- (void)didNotAddPersistentStoreWithPath:(NSString *)storePath error:(NSError *)error
{
    // Override me, if needed, to provide customized behavior.
	//
	// For example, if you are using the database for non-persistent data and the model changes,
	// you may want to delete the database file if it already exists on disk.
	//
	// E.g:
	//
	// [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
	// [self addPersistentStoreWithPath:storePath error:NULL];
	//
	// This method is invoked on the storageQueue.
    
#if TARGET_OS_IPHONE
    XMPPLogError(@"%@:\n"
                 @"=====================================================================================\n"
                 @"Error creating persistent store:\n%@\n"
                 @"Chaned core data model recently?\n"
                 @"Quick Fix: Delete the app from device and reinstall.\n"
                 @"=====================================================================================",
                 [self class], error);
#else
    XMPPLogError(@"%@:\n"
                 @"=====================================================================================\n"
                 @"Error creating persistent store:\n%@\n"
                 @"Chaned core data model recently?\n"
                 @"Quick Fix: Delete the database: %@\n"
                 @"=====================================================================================",
                 [self class], error, storePath);
#endif
    
}

- (NSManagedObjectModel *)managedObjectModel
{
	// This is a public method.
	// It may be invoked on any thread/queue.
	
	__block NSManagedObjectModel *result = nil;
	
	dispatch_block_t block = ^{ @autoreleasepool {
		
		if (managedObjectModel)
		{
			result = managedObjectModel;
			return;
		}
        
		NSString *momName = [self managedObjectModelName];
		
		XMPPLogVerbose(@"%@: Creating managedObjectModel (%@)", [self class], momName);
		
		NSString *momPath = [[self managedObjectModelBundle] pathForResource:momName ofType:@"mom"];
		if (momPath == nil)
		{
			// The model may be versioned or created with Xcode 4, try momd as an extension.
			momPath = [[self managedObjectModelBundle] pathForResource:momName ofType:@"momd"];
		}
        
		if (momPath)
		{
			// If path is nil, then NSURL or NSManagedObjectModel will throw an exception
			
			NSURL *momUrl = [NSURL fileURLWithPath:momPath];
			
			managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl] copy];
		}
		else
		{
			XMPPLogWarn(@"%@: Couldn't find managedObjectModel file - %@", [self class], momName);
		}
		
		result = managedObjectModel;
	}};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_sync(storageQueue, block);
	
	return result;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	// This is a public method.
	// It may be invoked on any thread/queue.
	
	__block NSPersistentStoreCoordinator *result = nil;
	
	dispatch_block_t block = ^{ @autoreleasepool {
		
		if (persistentStoreCoordinator)
		{
			result = persistentStoreCoordinator;
			return;
		}
		
		NSManagedObjectModel *mom = [self managedObjectModel];
		if (mom == nil)
		{
			return;
		}
		
		XMPPLogVerbose(@"%@: Creating persistentStoreCoordinator", [self class]);
		
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		
		if (databaseFileName)
		{
			// SQLite persistent store
			
			NSString *docsPath = [self persistentStoreDirectory];
			NSString *storePath = [docsPath stringByAppendingPathComponent:databaseFileName];
			if (storePath)
			{
				// If storePath is nil, then NSURL will throw an exception
				
				[self willCreatePersistentStoreWithPath:storePath];
				
				NSError *error = nil;
				
				BOOL didAddPersistentStore = [self addPersistentStoreWithPath:storePath error:&error];
				
				if(autoRecreateDatabaseFile && !didAddPersistentStore)
				{
					[[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
					
					didAddPersistentStore = [self addPersistentStoreWithPath:storePath error:&error];
				}
				
				if (!didAddPersistentStore)
				{
					[self didNotAddPersistentStoreWithPath:storePath error:error];
				}
			}
			else
			{
				XMPPLogWarn(@"%@: Error creating persistentStoreCoordinator - Nil persistentStoreDirectory",
							[self class]);
			}
		}
		else
		{
			// In-Memory persistent store
			
			[self willCreatePersistentStoreWithPath:nil];
			
			NSError *error = nil;
			if (![self addPersistentStoreWithPath:nil error:&error])
			{
				[self didNotAddPersistentStoreWithPath:nil error:error];
			}
		}
		
		result = persistentStoreCoordinator;
		
	}};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_sync(storageQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)persistentStoreDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	
	// Attempt to find a name for this application
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (appName == nil) {
		appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	}
	
	if (appName == nil) {
		appName = @"xmppframework";
	}
	
	
	NSString *result = [basePath stringByAppendingPathComponent:appName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:result])
	{
		[fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    return result;
}

@end
