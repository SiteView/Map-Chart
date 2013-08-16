//
//  RoomsViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "RoomsViewController.h"
#import "AppDelegate.h"
#import "RoomModel.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "CreateRoomViewController.h"
#import "UserProperty.h"
#import "RoomContextCell.h"

@interface RoomsViewController ()

@end

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation RoomsViewController
{
    UITableView *table_;
	NSFetchedResultsController *fetchedResultsController;
    NSMutableDictionary *rooms_;
    NSString *roomPassword_;
    NSString *roomjid_;
    CreateRoomViewController *createRoomViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 95)];
    table_.dataSource = self;
    table_.delegate = self;
    table_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:table_];

    roomPassword_ = nil;
    
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create Room", @"Create Room")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(CreateRoom)];
    [self.navigationItem setRightBarButtonItem:rightButton];

    UIBarButtonItem *refreshButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refresh", @"Refresh")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(refreshRoom)];
    [self.navigationItem setLeftBarButtonItem:refreshButton];

    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = self;
    
    rooms_ = [app.roomModel_ mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_current_queue(), ^{
        AppDelegate *app = [self appDelegate];
        [app querySupportMUC];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshRoom
{
    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = self;
    [app querySupportMUC];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//取得当前程序的委托
-(AppDelegate *)appDelegate
{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

-(void)newRoomsReceived:(RoomModel *)roomsContent
{
    AppDelegate *app = [self appDelegate];

    rooms_ = [app.roomModel_ mutableCopy];
    [table_ reloadData];
}
/*

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_room];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[table_ reloadData];
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
//	return [[[self fetchedResultsController] sections] count];
}
/*
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
/*	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
*/
    return [rooms_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    RoomContextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RoomContextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
/*
    XMPPRoomCoreDataStorage *room = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    room.description;
    room.messageEntityName;
    room.occupantEntityName;
 */

    __block RoomModel *room = nil;
    __block int nCount = 0;
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (nCount == [indexPath row]) {
            room = obj;
            *stop = YES;
        }
        nCount++;
    }];
    
    if (room != nil) {
        if (room.muc_passwordprotected) {
//            NSString *strProtocted = [NSString stringWithFormat:@"锁 %@", room.jid];
//            cell.detailTextLabel.text = strProtocted;
        } else {
//            cell.detailTextLabel.text = room.jid;
            cell.imageView.image = nil;
        }
//        cell.textLabel.text = room.name;
        cell.titleLabel.text = room.name;
        cell.timeLabel.text = @"时间";
    }
    
    return cell;
}

- (void)showRoomPasswordAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Room password"
                                    message:@"Enter room password"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.alertViewStyle) {
        case UIAlertViewStyleSecureTextInput:
        {
            switch (buttonIndex) {
                case 0:
                    break;
                case 1:
                {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    roomPassword_ = textField.text;
                    
                    AppDelegate *app = [self appDelegate];
                    app.roomsDelegate = self;
                    
                    [app joinRoom:roomjid_ password:roomPassword_ nickName:[UserProperty sharedInstance].nickName];
                    NSLog(@"Secure text input: %@", textField.text);
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UIAlertViewStyle style = alertView.alertViewStyle;
    
    if ((style == UIAlertViewStyleSecureTextInput) ||
        (style == UIAlertViewStylePlainTextInput) ||
        (style == UIAlertViewStyleLoginAndPasswordInput)) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // join the room
    __block RoomModel *room = nil;
    __block int nCount = 0;
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (nCount == [indexPath row]) {
            room = obj;
            *stop = YES;
        }
        nCount++;
    }];
    
    if (room == nil) {
        return;
    }
    
    AppDelegate *app = [self appDelegate];
    
    // 是否为已加入房间
    NSDictionary *roomJoined = [app.roomJoinModel_ copy];
    if ((roomJoined != nil) && ([roomJoined count] > 0))
    {
        RoomModel* roomJoin = [roomJoined objectForKey:room.jid];
        if (roomJoin != nil)
        {
            [self didJoinRoomSuccess];
            return;
        }
    }

    roomjid_ = room.jid;
    if (room.muc_passwordprotected) {
        // 加密房间，输入密码
        [self showRoomPasswordAlertView];
        return;
    }

    [app joinRoom:roomjid_ password:nil nickName:[UserProperty sharedInstance].nickName];
}

- (void)CreateRoom
{
    if (createRoomViewController == nil) {
        createRoomViewController = [[CreateRoomViewController alloc] init];
    }
    [self.navigationController pushViewController:createRoomViewController animated:YES];
    
}
#pragma mark XMPPRoomsDelegate

- (void)didJoinRoomSuccess
{
    UITabBarController *tabBarController;
    tabBarController = (UITabBarController *)self.parentViewController.parentViewController;
    
    tabBarController.selectedIndex = 1;
}

- (void)didJoinRoomFailure:(NSString *)errorMsg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Room password"
                              message:errorMsg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView show];

}

@end
