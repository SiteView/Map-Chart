//
//  PositionViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "PositionViewController.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "RoomModel.h"
#import "UserProperty.h"
//#import <MapKit/MapKit.h>

static int kMarkerCount = 0;

// Returns a random value from 0-1.0f.
static CGFloat randf() {
    return (((float)arc4random()/0x100000000)*1.0f);
}

@implementation PositionViewController {
    GMSMapView *mapView_;
/*    CLLocationManager *locationManager;
    CLLocationCoordinate2D coordinate;
    CLLocationDistance altitude;
    MKMapView *mapView;
*/    
    BOOL firstLocationUpdate_;
    UIBarButtonItem *loginButton_;
    UIBarButtonItem *roomLists_;
    BOOL m_isCertified;
    // 用户是否已注册
    BOOL isRegistry_;
    // Online users
    NSMutableArray *onlineUsers_;

    // GSMaker
    NSMutableDictionary *onlineMaker_;
    
    NSMutableDictionary *rooms_;

    NSString *roomjid_;
}

@synthesize roomsViewController;
@synthesize roomMessageViewController;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_isCertified = NO;
        isRegistry_ = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
/*
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    mapView.mapType = MKMapTypeStandard;
    
    coordinate.latitude = 39.90809;
    coordinate.longitude = 116.34333;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView setRegion:region];
    mapView.showsUserLocation = YES;

    locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位不可用");
    } else {
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager startUpdatingLocation];
        
    }
*/

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:10];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.buildingsEnabled = YES;
    mapView_.delegate = self;
    mapView_.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    self.view = mapView_;

/*
    GMSMarker *sydneyMarker = [[GMSMarker alloc] init];
    sydneyMarker.title = @"Sydney";
    sydneyMarker.snippet = @"Population: 4,605,992";
    sydneyMarker.position = CLLocationCoordinate2DMake(-33.8683, 151.2086);
    sydneyMarker.map = mapView_;
    
    GMSMarker *melbourneMarker = [[GMSMarker alloc] init];
    melbourneMarker.title = @"Melbourne";
    melbourneMarker.snippet = @"Population: 4,169,103";
    melbourneMarker.position = CLLocationCoordinate2DMake(-37.81969, 144.966085);
    melbourneMarker.map = mapView_;
    
    // Set the marker in Sydney to be selected
    mapView_.selectedMarker = sydneyMarker;

    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mapView_];
//    [self.view addSubview:mapView];
*/    

    onlineUsers_ = [NSMutableArray array];
    
    onlineMaker_ = [NSMutableDictionary dictionary];

/*    loginButton_ =
    [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(login)];
    [self.navigationItem setLeftBarButtonItem:loginButton_];

    roomLists_ =
    [[UIBarButtonItem alloc] initWithTitle:@"Rooms"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(roomLists)];
    [self.navigationItem setLeftBarButtonItem:roomLists_];
 
    UIBarButtonItem* groupChatBtn =
    [[UIBarButtonItem alloc] initWithTitle:@"GrouChat"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(GroupChatMessage)];
    [self.navigationItem setRightBarButtonItem:groupChatBtn];
*/
    AppDelegate *app = [self appDelegate];
    app.authenticateDelegate = self;
    app.chatDelegate = self;

    //#if TARGET_IPHONE_SIMULATOR
    //#elif TARGET_OS_IPHONE
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    //#endif
//        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(28.17523, 112.9703);
//        [self addMarkerInBounds:position stringWithTitle:@"Test"];

//    [self didTapAdd];

//    dispatch_async(dispatch_get_main_queue(), ^{
        [self loginRequest];
//        [self appDelegate].isXMPPRegister = YES;
//        [self registery];
//        [[self appDelegate] connect:@"anonymous" password:@"" serverName:DOMAIN_URL server:DOMAIN_URL];
//    });

}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = self;
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

- (void)dealloc {

    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];

}


- (void)didTapAdd {
    for (int i = 0; i < 10; ++i) {
        // Add a marker every 0.25 seconds for the next ten markers, randomly
        // within the bounds of the camera as it is at that point.
        double delayInSeconds = (i * 0.25);
        dispatch_time_t popTime =
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            GMSVisibleRegion region = [mapView_.projection visibleRegion];
            GMSCoordinateBounds *bounds =
            [[GMSCoordinateBounds alloc] initWithRegion:region];
            [self addMarkerInBounds:bounds];
        });
    }
}

- (void)addMarkerInBounds:(GMSCoordinateBounds *)bounds {
    CLLocationDegrees latitude = bounds.southWest.latitude +
    randf() * (bounds.northEast.latitude - bounds.southWest.latitude);
    
    // If the visible region crosses the antimeridian (the right-most point is
    // "smaller" than the left-most point), adjust the longitude accordingly.
    BOOL offset = (bounds.northEast.longitude < bounds.southWest.longitude);
    CLLocationDegrees longitude = bounds.southWest.longitude + randf() *
    (bounds.northEast.longitude - bounds.southWest.longitude + (offset ?
                                                                360 : 0));
    if (longitude > 180.f) {
        longitude -= 360.f;
    }
    
    UIColor *color =
    [UIColor colorWithHue:randf() saturation:1.f brightness:1.f alpha:1.0f];
    
    CLLocationCoordinate2D position =
    CLLocationCoordinate2DMake(latitude, longitude);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = [NSString stringWithFormat:@"Marker #%d", ++kMarkerCount];
    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    [onlineMaker_ setObject:marker forKey:marker.title];
}


- (void)addMarkerInBounds:(GMSCoordinateBounds *)bounds stringWithTitle:(NSString *)title {
    CLLocationDegrees latitude = bounds.southWest.latitude +
    randf() * (bounds.northEast.latitude - bounds.southWest.latitude);
    
    // If the visible region crosses the antimeridian (the right-most point is
    // "smaller" than the left-most point), adjust the longitude accordingly.
    BOOL offset = (bounds.northEast.longitude < bounds.southWest.longitude);
    CLLocationDegrees longitude = bounds.southWest.longitude + randf() *
    (bounds.northEast.longitude - bounds.southWest.longitude + (offset ?
                                                                360 : 0));
    if (longitude > 180.f) {
        longitude -= 360.f;
    }
    
    UIColor *color =
    [UIColor colorWithHue:randf() saturation:1.f brightness:1.f alpha:1.0f];
    
    CLLocationCoordinate2D position =
    CLLocationCoordinate2DMake(latitude, longitude);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = title;
    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    [onlineMaker_ setObject:marker forKey:marker.title];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        
        AppDelegate *app = [self appDelegate];
        app.myLocation = location.coordinate;
        
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

/*
#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    coordinate = [newLocation coordinate];
    altitude = [newLocation altitude];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView setRegion:region];
    mapView.showsUserLocation = YES;
}

- (void)locationmanager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    // 定位失败
}
*/
- (void)login
{
    if (m_isCertified) {
        // logout
        m_isCertified = NO;
        [self logout];
        [self setNaviItemLeftBtnTitle];
    } else {
        if (self.loginViewController == nil) {
            self.loginViewController = [[LoginViewController alloc] init];
        }
        
        [self.loginViewController setLoginFinish:self callback:@selector(loginOpCallback:)];
        
        UIBarButtonItem *backButton =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [self.navigationItem setBackBarButtonItem:backButton];
        [self.navigationController pushViewController:self.loginViewController animated:YES];
    }
    
}

- (void)roomLists
{
    if (self.roomsViewController == nil) {
        self.roomsViewController = [[MessageContextViewController alloc] init];
    }
    
    [self.navigationController pushViewController:self.roomsViewController animated:YES];

}

- (void)GroupChatMessage
{
    if (self.roomMessageViewController == nil) {
        self.roomMessageViewController = [[MessageContextViewController alloc] init];
    }
    [self.navigationController pushViewController:self.roomMessageViewController animated:YES];
}

- (void) setNaviItemLeftBtnTitle
{
    NSString * leftBtnTitle = @"Logout";
    if (!m_isCertified) {
        leftBtnTitle = @"Login";
    }
    self.navigationItem.leftBarButtonItem.title = leftBtnTitle;
}

- (void) loginOpCallback:(XMPPStream*) obj
{
    //do something
    m_isCertified = YES;
    
    [self setNaviItemLeftBtnTitle];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    if (self.roomsViewController == nil) {
        self.roomsViewController = [[MessageContextViewController alloc] init];
    }
    
    [self.navigationItem.backBarButtonItem setTitle:@""];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController pushViewController:self.roomsViewController animated:YES];
}

- (void)logout
{
    AppDelegate *app = [self appDelegate];
    [app disconnect];
}

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

//在线好友
-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
/*
    if (![onlineUsers_ containsObject:buddyName]) {
        [onlineUsers_ addObject:buddyName];
        
        GMSVisibleRegion region;
        region.nearLeft = CLLocationCoordinate2DMake(28.17523 + kMarkerCount * 0.00051, 112.9803);
        region.nearRight = CLLocationCoordinate2DMake(28.17523 + kMarkerCount * 0.00051, 112.9803);
        region.farLeft = CLLocationCoordinate2DMake(28.17523 + kMarkerCount * 0.00051, 112.9803);
        region.farRight = CLLocationCoordinate2DMake(28.17523 + kMarkerCount * 0.00051, 112.9803);
        
        kMarkerCount++;
        
        GMSCoordinateBounds *bounds =
        [[GMSCoordinateBounds alloc] initWithRegion:region];
        [self addMarkerInBounds:bounds stringWithTitle:buddyName];
        
    }
*/    
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName
{
    
    [onlineUsers_ removeObject:buddyName];

    GMSMarker* marker = [onlineMaker_ objectForKey:buddyName];
    marker.map = nil;
    [onlineMaker_ removeObjectForKey:buddyName];
}

- (void)updateBuddyOnline:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    
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

// 和好友聊天
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //start a Chat
    NSString *roomName = marker.title;
    
    AppDelegate *app = [self appDelegate];

    // 是否为已加入房间
    NSDictionary *roomJoined = [app.roomJoinModel_ copy];
    RoomModel* roomJoin = [roomJoined objectForKey:roomName];
    if (roomJoin != nil)
    {
        [self didJoinRoomSuccess:roomJoin.name];
        return;
    }
    
    // 加入房间
    __block RoomModel *roomChat = nil;

    rooms_ = [app.roomModel_ mutableCopy];
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RoomModel *room = obj;
        if ([room.jid isEqualToString:roomName]) {
            roomChat = obj;
            *stop = YES;
        }
    }];
    
    if (roomChat != nil) {
        if (roomChat.muc_passwordprotected) {
            roomjid_ = roomChat.jid;
            [self showRoomPasswordAlertView];
            return;
        }
        
        [app joinRoom:roomChat.jid password:nil nickName:[UserProperty sharedInstance].nickName];
        return;
    }
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

        NSString *account = [UserProperty sharedInstance].nickName;
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
    NSString *account = [UserProperty sharedInstance].nickName;
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
    rooms_ = [app.roomModel_ mutableCopy];
    
    [rooms_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RoomModel *room = obj;
        
        UIColor *color =
        [UIColor colorWithHue:randf() saturation:1.f brightness:1.f alpha:1.0f];
        
        CLLocationCoordinate2D position = room.coordinatePosition;
        
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = [NSString stringWithFormat:@"%@", room.jid];
        marker.animated = YES;
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.map = mapView_;
        
        [onlineMaker_ setObject:marker forKey:marker.title];

    }];
}
#pragma mark XMPPRoomsDelegate

- (void)didJoinRoomSuccess:(NSString *)roomName
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
