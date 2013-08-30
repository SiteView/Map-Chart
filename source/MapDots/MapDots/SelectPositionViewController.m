//
//  SelectPositionViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-9.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "SelectPositionViewController.h"
#import "PlaceAnnotation.h"

@interface SelectPositionViewController ()

@end

@implementation SelectPositionViewController
{
    BOOL firstLocationUpdate_;
#ifdef GOOGLE_MAPS

    GMSMapView *mapView_;
#else
    CLLocationManager *locationManager;
    MKMapView *mapView_;
    PlaceAnnotation *annotation_;
#endif
    CLLocationCoordinate2D position_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Position";
    
    CGRect rectMap = CGRectMake(0, 0,
                                   self.view.bounds.size.width,
                                   self.view.bounds.size.height);
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

    annotation_ = [[PlaceAnnotation alloc] init];
    [mapView_ addAnnotation:annotation_];

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

- (void)dealloc {
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
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
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
    
    position_ = coordinate;
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
}
#else

- (void)fingerTapAction:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView_];//这里touchPoint是点击的某点在地图控件中的位置
    CLLocationCoordinate2D coordinate =
    [mapView_ convertPoint:touchPoint toCoordinateFromView:mapView_];//这里touchMapCoordinate就是该点的经纬度了
    
    position_ = coordinate;

//    [mapView_ removeAnnotation:annotation_];
    // add the single annotation to our map
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        annotation_.coordinate = coordinate;
        annotation_.title = placemark.name;
    }];
//    [mapView_ addAnnotation:annotation_];

}
#endif

- (void)confirmPosition
{
    CLLocationCoordinate2D coordinate;
    
    // 获得用户点击的位置
    coordinate = position_;
    
    NSString *position = [NSString stringWithFormat:@"[%lf,%lf]", coordinate.latitude, coordinate.longitude];
    [m_target_edit performSelector:m_selector_edit withObject:position];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
