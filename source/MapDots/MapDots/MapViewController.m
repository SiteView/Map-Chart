//
//  MapViewController.m
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceAnnotation.h"
#import "AppDelegate.h"

@interface MapViewController ()

@end

@implementation MapViewController
{
#ifdef GOOGLE_MAPS
    GMSMapView *mapView_;
    GMSMarker *oldMarker_;
#else
#ifdef BAIDU_MAPS
    BMKMapView *mapView_;
#else
    MKMapView *mapView_;
#endif
#endif
    CLLocationCoordinate2D position_;
    NSString *addressName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(confirmPosition)];
    [self.navigationItem setRightBarButtonItem:confirmBtn];

    CGRect rectMap = CGRectMake(0, 0,
                                self.view.bounds.size.width,
                                self.view.bounds.size.height);
#ifdef GOOGLE_MAPS
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:rectMap camera:camera];
    mapView_.delegate = self;
    mapView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    
    // TODO: 
    if (self.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];
        
        self.title = mapItem.name;
        
        // add the single annotation to our map
        GMSMarker *annotation = [[GMSMarker alloc] init];
        annotation.position = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.map = mapView_;
        
        oldMarker_ = annotation;
        
        addressName = annotation.title;
        position_ = annotation.position;
        
        // we have only on annotation, select it's callout
//        [mapView_ selectAnnotation:[mapView_.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
//        mapView_.center = mapItem.placemark.location.coordinate;
    }
    else
    {
        self.title = @"All Places";
        
        oldMarker_ = nil;
        
        // add all the found annotations to the map
        for (MKMapItem *item in self.mapItemList) {
            GMSMarker *annotation = [[GMSMarker alloc] init];
            annotation.position = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.map = mapView_;
        }
    }
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
    
    if (self.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];
        
        self.title = mapItem.name;
        
        // add the single annotation to our map
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        [mapView_ addAnnotation:annotation];
        
        position_ = annotation.coordinate;
        
        // we have only on annotation, select it's callout
        [mapView_ selectAnnotation:[mapView_.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
        mapView_.centerCoordinate = mapItem.placemark.coordinate;
    }
    else
    {
        self.title = @"All Places";
        
        // add all the found annotations to the map
        for (MKMapItem *item in self.mapItemList) {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.url = item.url;
            [mapView_ addAnnotation:annotation];
        }
    }
#else
    mapView_ = [[MKMapView alloc] initWithFrame:rectMap];
    mapView_.delegate = self;
    
    // adjust the map to zoom/center to the annotations we want to show
    [mapView_ setRegion:self.boundingRegion];
    
    if (self.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];
        
        self.title = mapItem.name;
        
        // add the single annotation to our map
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        [mapView_ addAnnotation:annotation];
        
        position_ = annotation.coordinate;
        
        // we have only on annotation, select it's callout
        [mapView_ selectAnnotation:[mapView_.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
        mapView_.centerCoordinate = mapItem.placemark.coordinate;
    }
    else
    {
        self.title = @"All Places";
        
        // add all the found annotations to the map
        for (MKMapItem *item in self.mapItemList) {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.url = item.url;
            [mapView_ addAnnotation:annotation];
        }
    }
#endif
#endif
    self.view = mapView_;
}

- (void)setFinish:(id)target action:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;
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
    

#endif
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
#ifdef GOOGLE_MAPS
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
#else
    [mapView_ removeAnnotations:mapView_.annotations];
#endif
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
}

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    
    AppDelegate *app = [self appDelegate];
    app.myLocation = location.coordinate;
    
    mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:14];
    //    }
}

// 和好友聊天
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"%f,%f", marker.position.latitude, marker.position.longitude);
    
    addressName = marker.title;
    position_ = marker.position;
    [self confirmPosition];
    return NO;
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
#else

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
        annotationView = (MKPinAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
        }
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        PlaceAnnotation *placeAnnotation = view.annotation;
        
        addressName = annotation.title;
        position_ = placeAnnotation.coordinate;
        [self confirmPosition];
    }
}
#endif
#endif

- (void)confirmPosition
{
    CLLocationCoordinate2D coordinate;
    
    // 获得用户点击的位置
    coordinate = position_;
    
    NSString *position = [NSString stringWithFormat:@"[%lf,%lf]%@", coordinate.latitude, coordinate.longitude, addressName];
    
    NSLog(@"%@", position);
    
    [m_target_edit performSelector:m_selector_edit withObject:position];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

@end
