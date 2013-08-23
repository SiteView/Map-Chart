//
//  FriendsViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "MessageContextViewController.h"
#import "MemberProperty.h"

@implementation FriendsViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    // Online users
//    NSMutableArray *onlineUsers_;
    // GSMaker
    NSMutableDictionary *onlineMaker_;
    UIBarButtonItem *messageButton_;
    BOOL isMapView_;
    MessageContextViewController* messageContextViewController;
}

@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
    messageButton_ =
    [[UIBarButtonItem alloc] initWithTitle:@"Message"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(messageContext)];
    [self.navigationItem setRightBarButtonItem:messageButton_];
    isMapView_ = YES;
    
    messageContextViewController = [[MessageContextViewController alloc] init];

    onlineMaker_ = [NSMutableDictionary dictionary];

//    AppDelegate *app = [self appDelegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFriendsPosition];
    });
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;
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

- (void)viewWillAppear:(BOOL)animated
{
    self.title = roomName;
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = nil;
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

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

- (void)messageContext
{
    messageContextViewController.roomName = self.title;
    [self.navigationController pushViewController:messageContextViewController animated:YES];
}
/*
- (void)changeView
{
    // 切换视图
    isMapView_ = !isMapView_;
    
    UIView* leftView = nil;
    UIView* rightView = nil;
    if (isMapView_) {
        // map
    } else {
        // Messages
        
    }
    
    // hide the button
    self.navigationItem.rightBarButtonItem = nil;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:leftView cache:YES];
    
    [UIView exchangeSubviewAtIndex:]
}
 */

//在线好友
-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSLog(@"%s", __FUNCTION__);
    
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.position = coordinate;
        marker.icon = [GMSMarker markerImageWithColor:color];

    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName
{
    NSLog(@"%s", __FUNCTION__);
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.map = nil;
    }
}

- (void)updateBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.position = coordinate;
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.map = mapView_;
    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = title;
//    marker.snippet = @"Population: 4,605,992";
    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    if (marker != nil && [title length] > 0) {
        [onlineMaker_ setObject:marker forKey:title];
    }
}

- (void)showFriendsPosition
{
    AppDelegate *app = [self appDelegate];
    RoomModel *room = [app.roomJoinModel_ objectForKey:roomName];
    if (room.items != nil) {
        [room.items enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            MemberProperty * member = obj;
            [self updateBuddyOnline:member.name coordinate:member.coordinatePosition color:member.color];
        }];
    }
}
#pragma mark -
#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    
}
@end
