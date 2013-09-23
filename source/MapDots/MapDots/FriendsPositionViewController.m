//
//  FriendsPositionViewController.m
//  MapDots
//
//  Created by siteview_mac on 13-9-17.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import "FriendsPositionViewController.h"
#import "PlaceAnnotation.h"
#import "AppDelegate.h"
#import "MemberProperty.h"
#import "UserProperty.h"

@interface FriendsPositionViewController ()

@end

@implementation FriendsPositionViewController
{
#ifdef GOOGLE_MAPS
    BOOL firstLocationUpdate_;
    GMSMapView *mapView_;
#else
#ifdef BAIDU_MAPS
    BMKMapView *mapView_;
#else
    CLLocationManager *locationManager;
    MKMapView *mapView_;
#endif
#endif
    CLLocationCoordinate2D position_;
    
    // GSMaker
    NSMutableDictionary *onlineMaker_;
    
}

@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    float controlTop = 0;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        controlTop = 30;
    }
    CGRect rectMap = CGRectMake(0,
                                controlTop,
                                self.view.bounds.size.width,
                                self.view.bounds.size.height - 40);
    

#ifdef GOOGLE_MAPS
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:10];
    mapView_ = [GMSMapView mapWithFrame:rectMap camera:camera];
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
    mapView_ = [[MKMapView alloc] initWithFrame:rect];
    mapView_.mapType = MKMapTypeStandard;
    mapView_.delegate = self;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 39.90809;
    coordinate.longitude = 116.34333;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView_ setRegion:region];
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
 
    onlineMaker_ = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFriendsPosition];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    
#ifdef GOOGLE_MAPS
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
#endif
    
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef GOOGLE_MAPS
    
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
#endif
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
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        
        AppDelegate *app = [self appDelegate];
        app.myLocation = location.coordinate;
        
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
//    }
}

#else
#ifdef BAIDU_MAPS
#else


#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    
    position_ = coordinate;
    [self appDelegate].myLocation = coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView_ setRegion:region];
    mapView_.showsUserLocation = YES;
}
#endif
#endif

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}
#ifdef GOOGLE_MAPS

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
//    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    if (marker != nil && [title length] > 0) {
        [onlineMaker_ setObject:marker forKey:title];
    }
}

#else
// BAIDU_MAPS和Apple Map使用相同的PlaceAnnotation
//在线好友
-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSLog(@"%s", __FUNCTION__);
    
        PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
        if (marker) {
            marker.coordinate = coordinate;
            //        marker.icon = [GMSMarker markerImageWithColor:color];
            
        } else {
            [self addCoordinate:buddyName coordinate:coordinate color:color];
        }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName
{
    NSLog(@"%s", __FUNCTION__);
    PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        [mapView_ removeAnnotation:marker];
    }
}

- (void)updateBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.coordinate = coordinate;
    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSString *lowerName = [title lowercaseString];
    NSString *lowerNickName = [[UserProperty sharedInstance].nickName lowercaseString];
    if ([lowerName isEqualToString:lowerNickName]) {
    } else {

        PlaceAnnotation *marker = [[PlaceAnnotation alloc] init];
        marker.title = title;
        marker.coordinate = coordinate;
        [mapView_ addAnnotation:marker];
        
        if (marker != nil && [title length] > 0) {
            [onlineMaker_ setObject:marker forKey:title];
        }
    }
}
#endif

- (void)showFriendsPosition
{
    NSLog(@"%s", __FUNCTION__);
    AppDelegate *app = [self appDelegate];
    XMPPRoom *room = [app.xmppRoomList_ objectForKey:roomName];
    if (room.members != nil) {
        [room.members enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            MemberProperty * member = obj;
            
            NSString *lowerName = [member.name lowercaseString];
            NSString *lowerNickName = [[UserProperty sharedInstance].nickName lowercaseString];
            if ([lowerName isEqualToString:lowerNickName]) {
            } else {
                [self updateBuddyOnline:member.name coordinate:member.coordinatePosition color:member.color];
            }
        }];
    }
}

#ifdef GOOGLE_MAPS
#pragma mark -
#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    
}
#endif

@end
