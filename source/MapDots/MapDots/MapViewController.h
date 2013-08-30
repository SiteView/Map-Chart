//
//  MapViewController.h
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    id m_target_edit;
    SEL m_selector_edit;
}

- (void)setFinish:(id)target action:(SEL)selector;

@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@end
