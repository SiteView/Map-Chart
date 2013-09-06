//
//  RoomsViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "EventsViewController.h"
#import "AppDelegate.h"
#import "XMPPRoom.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "CreateEventViewController.h"
#import "UserProperty.h"
#import "RoomContextCell.h"
#import "FriendsViewController.h"
#import "PlaceAnnotation.h"
#import "UserProperty.h"

@interface EventsViewController ()

@end

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation EventsViewController
{
    BOOL isViewPosition_;
    UIView *viewPosition_;
    UIView *viewEvents_;
    
    // viewPosition_
#ifdef GOOGLE_MAPS
    GMSMapView *mapView_;
#else
#ifdef BAIDU_MAPS
    BMKMapView *mapView_;
#else
    MKMapView *mapView_;
#endif
    CLLocationManager *locationManager;
#endif
    CLLocationCoordinate2D position_;
    NSMutableDictionary *onlineMaker_;
    UIBarButtonItem *createEventButton_;

    // viewEvents_
    UITableView *table_;
    UIActivityIndicatorView *indicator_;
    UIBarButtonItem *refreshButton_;
    UIBarButtonItem *rightButton_;
    UIBarButtonItem *indicatorButton_;
	NSFetchedResultsController *fetchedResultsController;
    
    UIBarButtonItem *flipMapButton_;
    UIBarButtonItem *flipListButton_;
    NSMutableDictionary *rooms_;
    NSString *roomPassword_;
    NSString *roomjid_;
    CreateEventViewController *createRoomViewController;
    
    BOOL m_isCertified;
    // 用户是否已注册
    BOOL isRegistry_;

    UIActionSheet *actionSheet_;
    NSString *strTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    // viewEvents_
    viewEvents_ = [[UIView alloc] initWithFrame:rect];
    
    indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorButton_ = [[UIBarButtonItem alloc] initWithCustomView:indicator_];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 10)];
    table_.dataSource = self;
    table_.delegate = self;
    table_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table_.autoresizesSubviews = YES;
    table_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [viewEvents_ addSubview:table_];

    roomPassword_ = nil;
    
    createEventButton_ =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create Events", @"Create Events")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(CreateRoom)];

    refreshButton_ =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refresh", @"Refresh")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(refreshRoom)];
//    [self.navigationItem setLeftBarButtonItem:refreshButton_];
    
    flipListButton_ = [[UIBarButtonItem alloc] initWithTitle:@"List"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(flipView)];
    flipMapButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                   style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(flipView)];
    
    actionSheet_ = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:@"Join Event"
                                      otherButtonTitles:@"Shared to WeiChat", nil];
    
    actionSheet_.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet_.destructiveButtonIndex = 3;

    [self.view addSubview:viewEvents_];
    
    // viewPosition_
    viewPosition_ = [[UIView alloc] initWithFrame:rect];
#ifdef GOOGLE_MAPS
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:14];
    
    mapView_ = [GMSMapView mapWithFrame:rect camera:camera];
    mapView_.buildingsEnabled = YES;
    mapView_.delegate = self;
    mapView_.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
#else
#ifdef BAIDU_MAPS
    mapView_ = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView_.delegate = self;
    //实现旋转、俯视的3D效果
//    mapView_.rotate = 90;
    mapView_.overlooking = -30;
    //开启定位功能
    mapView_.showsUserLocation = NO;
    mapView_.userTrackingMode = BMKUserTrackingModeFollow;
    mapView_.showsUserLocation = YES;
#else
    mapView_ = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView_.mapType = MKMapTypeStandard;
    mapView_.delegate = self;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 39.90809;
    coordinate.longitude = 116.34333;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    //    [mapView_ setRegion:region];
    mapView_.showsUserLocation = YES;
    
    locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位不可用");
    } else {
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        
        // Set the optional distance filter
        locationManager.distanceFilter = 5.0f;
        
        [locationManager startUpdatingLocation];
        
    }
#endif
    
#endif
    viewPosition_ = mapView_;
    [self.view addSubview:viewPosition_];
    
    onlineMaker_ = [NSMutableDictionary dictionary];

    isViewPosition_ = YES;
    
    [self.navigationItem setLeftBarButtonItem:createEventButton_];
    [self.navigationItem setRightBarButtonItem:flipListButton_];

    AppDelegate *app = [self appDelegate];
    app.authenticateDelegate = self;
    
    [self loginRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;
    app.roomsDelegate = self;
    
    rooms_ = [app.xmppRoomList_ mutableCopy];
#ifdef GOOGLE_MAPS
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    //    firstLocationUpdate_ = NO;
    
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;
    app.roomsDelegate = nil;
#ifdef GOOGLE_MAPS
    
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}
#ifdef GOOGLE_MAPS

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    //    if (!firstLocationUpdate_) {
    // If the first location update has not yet been recieved, then jump to that
    // location.
    //        firstLocationUpdate_ = YES;
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    
    AppDelegate *app = [self appDelegate];
    app.myLocation = location.coordinate;
    
    mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:mapView_.camera.zoom];
    //    }
}

#else
#ifdef BAIDU_MAPS

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D coordinate;
    coordinate = [userLocation coordinate];
    
    position_ = coordinate;
    
    BMKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    BMKCoordinateRegion region = {coordinate, span};
//    [mapView_ setRegion:[mapView_ regionThatFits:region]];
    mapView_.showsUserLocation = YES;
}

- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

#else

#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coordinate;
    coordinate = [newLocation coordinate];
    
    position_ = coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView_ setRegion:region];
    mapView_.showsUserLocation = YES;
}

- (void)locationmanager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    // 定位失败
}

#endif
#endif

- (void)refreshRoom
{
    [indicator_ startAnimating];
    self.navigationItem.leftBarButtonItem = indicatorButton_;
    
    AppDelegate *app = [self appDelegate];
    rooms_ = [app.xmppRoomList_ mutableCopy];
    [table_ reloadData];
    
    [indicator_ stopAnimating];
    self.navigationItem.leftBarButtonItem = refreshButton_;

    // 没有新的房间，服务器不更新
//    app.roomsDelegate = self;
//    [app querySupportMUC];
}

- (void)flipView
{
    // Start Animation Block
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    
    NSInteger list = [[self.view subviews] indexOfObject:viewEvents_];
    NSInteger map = [[self.view subviews] indexOfObject:viewPosition_];
    
    // Animations
    [self.view exchangeSubviewAtIndex:list withSubviewAtIndex:map];
    
    // commit Animation Block
    [UIView commitAnimations];
    
    if (isViewPosition_) {
        isViewPosition_ = NO;

        [self.navigationItem setLeftBarButtonItem:refreshButton_];
        [self.navigationItem setRightBarButtonItem:flipMapButton_];
    } else {
        isViewPosition_ = YES;
        [self.navigationItem setLeftBarButtonItem:nil];
        
        [self.navigationItem setLeftBarButtonItem:createEventButton_];
        [self.navigationItem setRightBarButtonItem:flipListButton_];
    }
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

/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_room];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"roomJIDStr" ascending:YES];
//		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
		
//        NSComparisonPredicate
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"roomJIDStr == %@", roomName];

		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:20];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil//@"sectionNum"
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
/*	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
    return 0;
*/
    return [rooms_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RoomContextCell";
    
    RoomContextCell *cell = (RoomContextCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RoomContextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        NSArray * cellNib = [[NSBundle mainBundle] loadNibNamed:@"RoomContextCell" owner:self options:nil];
        
//        cell = [cellNib lastObject];
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"RoomContextCell" owner:self options:nil] lastObject];
 
    }
    /*
    XMPPRoomMessageCoreDataStorageObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    room.description;
    room.messageEntityName;
    room.occupantEntityName;
 */

    __block XMPPRoom *room = nil;
    __block int nCount = 0;
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (nCount == [indexPath row]) {
            room = obj;
            *stop = YES;
        }
        nCount++;
    }];

    if (room.muc_passwordprotected) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"room_lock" ofType:@"png"];
        cell.lockImageView.image = [UIImage imageWithContentsOfFile:path];
    } else {
        cell.lockImageView.image = nil;
    }
//        cell.textLabel.text = room.name;
    cell.titleLabel.text = room.roomName;
//    cell.timeLabel.text = @"时间";
//    NSDate *start = [[NSDate alloc] initWithTimeIntervalSince1970:room.effectivetimeStart];
//    NSDate *end = [NSDate dateWithTimeIntervalSince1970:room.effectivetimeEnd];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block XMPPRoom *room = nil;
    __block int nCount = 0;
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (nCount == [indexPath row]) {
            room = obj;
            *stop = YES;
        }
        nCount++;
    }];

    [self joinEvents:[room.roomJID full]];

}

- (void)CreateRoom
{
    if (createRoomViewController == nil) {
        createRoomViewController = [[CreateEventViewController alloc] init];
    }
    [createRoomViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:createRoomViewController animated:YES];
    
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
                    
                    AppDelegate *app = [self appDelegate];
                    app.roomsDelegate = self;
                    
                    [app joinRoom:roomjid_ password:textField.text nickName:[UserProperty sharedInstance].nickName];
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

- (void)didAuthenticate:(XMPPStream *)sender {
    // 获得聊天室列表
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *app = [self appDelegate];
        app.roomsDelegate = self;
        [app querySupportMUC];
    });
    
}

- (void)didConnect:(XMPPStream *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loginRequest];
    });
}

- (void)registery
{
    NSLog(@"%s", __FUNCTION__);
    
    if (isRegistry_ == NO) {
        /*
         // Get the stored data before the view loads
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSString *account = [defaults objectForKey:@"account"];
         NSString *password = [defaults objectForKey:@"password"];
         NSString *serverName = [defaults objectForKey:@"serverName"];
         NSString *serverAddress = [defaults objectForKey:@"serverAddress"];
         */
        //        if (account == @"" || password == @"")
        
        NSString *account = [UserProperty sharedInstance].account;
        NSString *nickName = [UserProperty sharedInstance].nickName;
        NSString *password = [UserProperty sharedInstance].password;
        //        NSString *serverName = [UserProperty sharedInstance].serverName;
        //        NSString *serverAddress = [UserProperty sharedInstance].serverAddress;
        if (account == nil || password == nil)
        {
            AppDelegate *app = [self appDelegate];
            
            NSString *uuid = [[app uuid] substringToIndex:8];
            account = uuid;
            password = uuid;
            //            serverName = DOMAIN_NAME;
            //            serverName = DOMAIN_URL;
            
            [UserProperty sharedInstance].nickName = account;
            [UserProperty sharedInstance].account = account;
            [UserProperty sharedInstance].password = password;
            [[UserProperty sharedInstance] save];
        }
        NSString *jabberID = [NSString stringWithFormat:@"%@@%@", account, DOMAIN_NAME];
        // 用户的注册
        [[self appDelegate] registery:jabberID password:password];// serverName:serverName server:serverAddress];
        
    }
    
}

- (void)loginRequest
{
    NSLog(@"%s", __FUNCTION__);
    NSString *nickName = [UserProperty sharedInstance].nickName;
    NSString *account = [UserProperty sharedInstance].account;
    NSString *password = [UserProperty sharedInstance].password;
    //    NSString *serverName = [UserProperty sharedInstance].serverName;
    //    NSString *serverAddress = [UserProperty sharedInstance].serverAddress;
    if (account == nil || password == nil)
    {
        AppDelegate *app = [self appDelegate];
        
        NSString *uuid = [[app uuid] substringToIndex:8];
        account = uuid;
        password = uuid;
        //        serverAddress = DOMAIN_NAME;
        //        serverName = DOMAIN_NAME;
        
        [UserProperty sharedInstance].nickName = account;
        [UserProperty sharedInstance].account = account;
        [UserProperty sharedInstance].password = password;
        [[UserProperty sharedInstance] save];
    }
    
    if ([nickName length] == 0) {
        [UserProperty sharedInstance].nickName = account;
        [[UserProperty sharedInstance] save];
    }
    
    NSString *jabberID = [NSString stringWithFormat:@"%@@%@", account, DOMAIN_NAME];
    
    // 用户的登录
    [[self appDelegate] connect:jabberID password:password];// serverName:serverName server:serverAddress];
    
}

- (void)didNotAuthenticate:(NSXMLElement *)authResponse
{
    // 认证失败，没有注册
    dispatch_async(dispatch_get_main_queue(), ^{
        [self registery];
    });
}
- (void)didRegister:(XMPPStream *)sender
{
    [[self appDelegate] disconnect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loginRequest];
    });
}

- (void)didNotRegister:(NSXMLElement *)error
{
    
    //    [self loginRequest];
}

-(void)newRoomsReceived:(NSArray *)roomsContent
{
    AppDelegate *app = [self appDelegate];
    rooms_ = [app.xmppRoomList_ mutableCopy];

    [table_ reloadData];

    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *room = obj;
        
        CLLocationCoordinate2D coordinate = room.coordinatePosition;
#ifdef GOOGLE_MAPS
        UIColor *color = [UIColor redColor];//[UIColor colorWithHue:randf() saturation:1.f brightness:1.f alpha:1.0f];
        
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        marker.title = [NSString stringWithFormat:@"%@", room.roomName];
        marker.animated = YES;
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.map = mapView_;
        
        [onlineMaker_ setObject:marker forKey:marker.title];
#else
        PlaceAnnotation *placeAnnotation = [[PlaceAnnotation alloc] init];
        placeAnnotation.coordinate = coordinate;
        placeAnnotation.title = [NSString stringWithFormat:@"%@", room.name];
        
        [mapView_ addAnnotation:placeAnnotation];
#endif
    }];
}

- (void)joinEvents:(NSString *)roomJid
{
    //start a Chat
    
    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = self;
    
    // 是否为已加入房间
    NSDictionary *roomJoined = [app.xmppRoomList_ copy];
    XMPPRoom* roomJoin = [roomJoined objectForKey:roomJid];
    if (roomJoin != nil)
    {
        [self didJoinRoomSuccess:roomJid];
        return;
    }
    
    // 加入房间
    __block XMPPRoom *roomChat = nil;
    
    rooms_ = [app.xmppRoomList_ mutableCopy];
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *room = obj;
        if ([[room.roomJID full] isEqualToString:roomJid]) {
            roomChat = obj;
            *stop = YES;
        }
    }];
    
    if (roomChat != nil) {
        if (roomChat.muc_passwordprotected) {
            roomjid_ = [roomChat.roomJID full];
            [self showRoomPasswordAlertView];
            return;
        }
        
        [app joinRoom:[roomChat.roomJID full] password:nil nickName:[UserProperty sharedInstance].nickName];
        return;
    }
}


#pragma make -
#pragma make UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            // Join Event
            [[self appDelegate].xmppRoomList_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                XMPPRoom *rm = obj;
                if ([rm.roomName isEqualToString:strTitle]) {
                    [self joinEvents:[rm.roomJID full]];
                    *stop = YES;
                }
            }];
        }
            break;
        case 1:
        {
            // Shared to WeiChat
            NSString *strWX = [NSString stringWithFormat:@"%@ 邀请您参加 %@ 的活动", [UserProperty sharedInstance].nickName, strTitle];
            [[self appDelegate] sendTextContent:strWX];
        }
            break;
        default:
            break;
    }
}

#ifdef GOOGLE_MAPS

// 和好友聊天
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    strTitle = marker.title;
    // 有UITabBar遮挡
    //    [actionSheet_ showInView:self.view];
    [actionSheet_ showInView:[UIApplication sharedApplication].keyWindow];
/*
    [[self appDelegate].XMPPRoom_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *rm = obj;
        if ([rm.name isEqualToString:strTitle]) {
            [self joinEvents:rm.jid];
            *stop = YES;
        }
    }];
*/ 
}
#else
#ifdef BAIDU_MAPS
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    PlaceAnnotation *annotation = view.annotation;
    
    [[self appDelegate].XMPPRoom_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *rm = obj;
        if ([rm.name isEqualToString:annotation.title]) {
            [self joinEvents:rm.jid];
            *stop = YES;
        }
    }];

}
#else
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *place in views) {
        place.canShowCallout = YES;
        //        MKPinAnnotationView *mkaview = place;
        //        mkaview.pinColor = MKPinAnnotationColorPurple;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    if (annotation != mapView_.userLocation) {
        static NSString *defaultPinID = @"PIN";
        pinView = (MKPinAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        }
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    PlaceAnnotation *annotation = view.annotation;
    
    [[self appDelegate].XMPPRoom_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XMPPRoom *rm = obj;
        if ([rm.name isEqualToString:annotation.title]) {
            [self joinEvents:rm.jid];
            *stop = YES;
        }
    }];

}
/*
 - (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
 {
 if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
 PlaceAnnotation *placeAnnotation = view.annotation;
 
 }
 }
 */
#endif
#endif


#pragma mark XMPPRoomsDelegate

- (void)didJoinRoomSuccess:(NSString *)roomJid
{
    /*    UITabBarController *tabBarController;
     tabBarController = (UITabBarController *)self.parentViewController.parentViewController;
     
     tabBarController.selectedIndex = 1;
     */
    
    // 广播自己的位置
    [[self appDelegate] updateMyPositionWithRoomName:roomJid];
    
    FriendsViewController *friendsViewController;
    friendsViewController = [[FriendsViewController alloc] init];
    
    friendsViewController.roomName = roomJid;
    
    [friendsViewController setHidesBottomBarWhenPushed:YES];

    [self.navigationController pushViewController:friendsViewController animated:YES];
    
}

- (void)didJoinRoomFailure:(NSString *)errorMsg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Events Error"
                              message:errorMsg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView show];
    
}
@end
