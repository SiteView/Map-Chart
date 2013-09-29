//
//  SelectPositionViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-9.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "SelectPositionViewController.h"
#import "PlaceAnnotation.h"
#import "AppDelegate.h"

@interface SelectPositionViewController ()

@end

@implementation SelectPositionViewController
{
    BOOL firstLocationUpdate_;
    CGFloat zoom_;
#ifdef GOOGLE_MAPS

    GMSMapView *mapView_;
#else
#ifdef BAIDU_MAPS
    BMKMapView *mapView_;
#else
    MKMapView *mapView_;
#endif
    CLLocationManager *locationManager;
    PlaceAnnotation *annotation_;
#endif
    
    NSString *addressName;
    CLLocationCoordinate2D position_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Position";
    
    CGRect rectMap = CGRectMake(0, 0,
                                   self.view.bounds.size.width,
                                   self.view.bounds.size.height);
    zoom_ = 14;
    if ([self appDelegate].isiPAD)
    {
        zoom_ = 18;
    }
#ifdef GOOGLE_MAPS

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:rectMap camera:camera];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });

#else
#ifdef BAIDU_MAPS
    mapView_ = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView_.zoomEnabled = YES;
    mapView_.delegate = self;
    //实现旋转、俯视的3D效果
    //    mapView_.rotate = 90;
    mapView_.overlooking = -30;
    
    // 加入点击手势
    
#else
    mapView_ = [[MKMapView alloc] initWithFrame:rectMap];
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
    
    // 创建一个手势识别器
    UITapGestureRecognizer *fingerTaps = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(fingerTapAction:)];
    
    // Set required taps and number of touches
    [fingerTaps setNumberOfTapsRequired:1];
    [fingerTaps setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [mapView_ setUserInteractionEnabled:YES];
    [mapView_ addGestureRecognizer:fingerTaps];

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
    annotation_ = [[PlaceAnnotation alloc] init];
    [mapView_ addAnnotation:annotation_];
#endif
 
//    [self.view addSubview:mapView_];
    self.view = mapView_;
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(confirmPosition)];
    [self.navigationItem setRightBarButtonItem:confirmBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
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
#else
#ifdef BAIDU_MAPS
    if (mapView_ != nil) {
        //开启定位功能
        mapView_.showsUserLocation = NO;
        mapView_.userTrackingMode = BMKUserTrackingModeFollow;
        mapView_.showsUserLocation = YES;
        mapView_.delegate = self;
    }
#endif
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
#ifdef GOOGLE_MAPS

    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
#else
#ifdef BAIDU_MAPS
    if (mapView_ != nil) {
        //开启定位功能
        mapView_.showsUserLocation = NO;
        mapView_.delegate = nil;
    }
#endif
#endif
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#ifdef GOOGLE_MAPS

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
                                                         zoom:mapView_.camera.zoom];
    }
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

    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    
    position_ = coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView_ setRegion:region];
    mapView_.showsUserLocation = YES;
}
#endif

#endif

#pragma mark -
#pragma mark Action

- (void)setFinish:(id)target action:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;

}

#ifdef GOOGLE_MAPS

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // 清除原来的点
    [mapView_ clear];
    
    UIColor *color = [UIColor blueColor];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
//    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    position_ = coordinate;
    addressName = marker.title;
    if ([addressName length] == 0) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position_.latitude longitude:position_.longitude];
        CLGeocoder *myGeocoder;
        myGeocoder = [[CLGeocoder alloc] init];
        [myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                addressName = placemark.locality;
            } else if (error == nil && [placemarks count] == 0) {
                NSLog(@"No results were returned.");
            } else if (error != nil) {
                NSLog(@"An error occurred = %@", error);
            }
        }];
    }
}
#else

#ifdef BAIDU_MAPS
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    PlaceAnnotation *annotation = view.annotation;
    addressName = annotation.title;
    position_ = annotation.coordinate;
    
    [self confirmPosition];
    
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    position_ = coordinate;
    annotation_.coordinate = coordinate;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        annotation_.title = placemark.name;
    }];

}
#else
- (void)fingerTapAction:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView_];//这里touchPoint是点击的某点在地图控件中的位置
    CLLocationCoordinate2D coordinate =
    [mapView_ convertPoint:touchPoint toCoordinateFromView:mapView_];//这里touchMapCoordinate就是该点的经纬度了
    
    position_ = coordinate;
    addressName = annotation.title;
    annotation_.coordinate = coordinate;

//    [mapView_ removeAnnotation:annotation_];
    // add the single annotation to our map
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        annotation_.title = placemark.name;
    }];
//    [mapView_ addAnnotation:annotation_];

}
#endif
#endif

- (void)confirmPosition
{
    CLLocationCoordinate2D coordinate;
    
    // 获得用户点击的位置
    coordinate = position_;
    
    NSString *position = [NSString stringWithFormat:@"[%lf,%lf]%@", coordinate.latitude, coordinate.longitude, addressName];
    [m_target_edit performSelector:m_selector_edit withObject:position];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
