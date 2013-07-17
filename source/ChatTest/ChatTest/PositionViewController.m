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

static int kMarkerCount = 0;

// Returns a random value from 0-1.0f.
static CGFloat randf() {
    return (((float)arc4random()/0x100000000)*1.0f);
}

@implementation PositionViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    UIBarButtonItem *loginButton_;
    BOOL m_isCertified;

    // Online users
    NSMutableArray *onlineUsers_;

    // GSMaker
    NSMutableDictionary *onlineMaker_;
}
- (id) init
{
    self = [super init];
    if (self)
    {
        m_isCertified = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:20];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
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

#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
#endif
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
*/
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mapView_];
    
    onlineUsers_ = [NSMutableArray array];
    
    onlineMaker_ = [NSMutableDictionary dictionary];
    
    loginButton_ =
    [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(login)];
    [self.navigationItem setLeftBarButtonItem:loginButton_];

    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;

//        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(28.17523, 112.9703);
//        [self addMarkerInBounds:position stringWithTitle:@"Test"];

//    [self didTapAdd];
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
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}


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
-(void)newBuddyOnline:(NSString *)buddyName{
    
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
    
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName{
    
    [onlineUsers_ removeObject:buddyName];

    GMSMarker* marker = [onlineMaker_ objectForKey:buddyName];
    marker.map = nil;
}

// 和好友聊天
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //start a Chat
    NSString *chatUserName = marker.title;
    MessageViewController *messageView = [[MessageViewController alloc] init];
    
    messageView.chatWithUser = chatUserName;
    
    [self.navigationController pushViewController:messageView animated:YES ];

}
@end
