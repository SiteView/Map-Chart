//
//  MapViewController.m
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController
{
    MKMapView *mapView_;
    CLLocationCoordinate2D position_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(confirmPosition)];
    [self.navigationItem setRightBarButtonItem:confirmBtn];

    mapView_ = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [mapView_ removeAnnotations:mapView_.annotations];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
}

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
        
        position_ = placeAnnotation.coordinate;
    }
}

- (void)confirmPosition
{
    CLLocationCoordinate2D coordinate;
    
    // 获得用户点击的位置
    coordinate = position_;
    
    NSString *position = [NSString stringWithFormat:@"[%lf,%lf]", coordinate.latitude, coordinate.longitude];
    [m_target_edit performSelector:m_selector_edit withObject:position];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

@end
