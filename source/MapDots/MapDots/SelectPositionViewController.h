//
//  SelectPositionViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-9.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPositionViewController : UIViewController<UISearchBarDelegate,
#ifdef GOOGLE_MAPS
GMSMapViewDelegate
#else
MKMapViewDelegate,
CLLocationManagerDelegate
#endif
    >
{
    id m_target_edit;
    SEL m_selector_edit;
}

- (void)setFinish:(id)target action:(SEL)selector;

@end
