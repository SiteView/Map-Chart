//
//  SelectPositionViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-9.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "SelectPositionViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SelectPositionViewController ()

@end

@implementation SelectPositionViewController
{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    CLLocationCoordinate2D position_;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 0,
                             self.view.bounds.size.width,
                             self.view.bounds.size.height);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:rect camera:camera];
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
    
    // 创建一个手势识别器
    UITapGestureRecognizer *fingerTaps = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(fingerTapAction)];
    
    // Set required taps and number of touches
    [fingerTaps setNumberOfTapsRequired:1];
    [fingerTaps setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [mapView_ setUserInteractionEnabled:YES];
    [mapView_ addGestureRecognizer:fingerTaps];
    
    [self.view addSubview:mapView_];
 
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(confirmPosition)];
    [self.navigationItem setRightBarButtonItem:confirmBtn];
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
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
- (void)setFinish:(id)target action:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;

}
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
