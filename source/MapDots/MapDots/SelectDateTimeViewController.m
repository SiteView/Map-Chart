//
//  SelectDateTimeViewController.m
//  MapChat
//
//  Created by siteview_mac on 13-8-26.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "SelectDateTimeViewController.h"

@interface SelectDateTimeViewController ()

@end

@implementation SelectDateTimeViewController
{
    UIDatePicker *datePicker;
    NSDate *selected;
}

- (void)initWithDate:(NSDate *)date
{
    selected = date;
    if (date) {
        [datePicker setDate:date];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Select Time";

    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    float controlTop = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        controlTop = 60;
    }

    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, controlTop, self.view.bounds.size.width, 50)];
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [datePicker setDate:[NSDate date]];
    //    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker addTarget:self
                   action:@selector(datePickerValueChanged)
         forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:datePicker];
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"Confirm"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(confirm)];
    [self.navigationItem setRightBarButtonItem:confirmBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFinish:(id)target action:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;
}

- (void)datePickerValueChanged
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    selected = [datePicker date];
}


- (void)confirm
{
    selected = [datePicker date];

    [m_target_edit performSelector:m_selector_edit withObject:selected];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
