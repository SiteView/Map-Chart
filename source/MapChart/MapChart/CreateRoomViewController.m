//
//  CreateRoomViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-5.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "CreateRoomViewController.h"
#import "AppDelegate.h"
#import "SelectPositionViewController.h"
#import "RoomModel.h"

@interface CreateRoomViewController ()

@end

@implementation CreateRoomViewController
{
    UITextField* roomTextField_;
    UITextField* roomPasswordTextField_;
    UISwitch* rememberMeSwitcher_;
    UITextField* motionStartTimeTextField_;
    UITextField* motionEndTimeTextField_;
    UIDatePicker *dateStartPicker;
    UIDatePicker *dateEndPicker;
    UITextField* motionPositionTextField_;
    UITextField* discriptionTextField_;
    UIControl* view_;
    UIButton *motionPositionBtn;
    CLLocationCoordinate2D coordinate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Create Room";
    
    view_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];
    
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
    CGPoint ptNickName;
    CGSize sizeAccount;
    
    float passwordWidth = 180;
    float serverWidth = 180;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        ptNickName.x = 120;
        ptNickName.y = 16;
        sizeAccount.width = 180;
        sizeAccount.height = 29;
    } else {
        ptNickName.x = 120;
        ptNickName.y = 16;
        sizeAccount.width = 400;
        sizeAccount.height = 29;
        
        passwordWidth = 400;
        serverWidth = 400;
    }
    // Room Name label.
    UILabel *roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 29)];
    roomLabel.text = @"Room";
    roomLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    roomLabel.textAlignment = NSTextAlignmentLeft;
    roomLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:roomLabel];
    
    roomTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 16, sizeAccount.width, 30)];
    roomTextField_.borderStyle = UITextBorderStyleRoundedRect;
    roomTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    roomTextField_.delegate = self;
    roomTextField_.returnKeyType = UIReturnKeyNext;
    roomTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    roomTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    roomTextField_.keyboardType = UIKeyboardTypeDefault;
    roomTextField_.placeholder = @"Please input room name...";
    [self.view addSubview:roomTextField_];
    
    // Nick Name label.
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, 200, 29)];
    nickNameLabel.text = @"Password";
    nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    nickNameLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nickNameLabel];
    
    roomPasswordTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 64, passwordWidth, 30)];
    roomPasswordTextField_.borderStyle = UITextBorderStyleRoundedRect;
    roomPasswordTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    roomPasswordTextField_.delegate = self;
    roomPasswordTextField_.returnKeyType = UIReturnKeyNext;
    roomPasswordTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    roomPasswordTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    roomPasswordTextField_.secureTextEntry = YES;
    roomPasswordTextField_.placeholder = @"Password could is empty...";
    roomPasswordTextField_.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:roomPasswordTextField_];
    
    // Motion time label.
    UILabel *motionStartTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 112, 200, 29)];
    motionStartTimeLabel.text = @"Start Time";
    motionStartTimeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionStartTimeLabel.textAlignment = NSTextAlignmentLeft;
    motionStartTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionStartTimeLabel];
    
    motionStartTimeTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 112, serverWidth, 30)];
    motionStartTimeTextField_.borderStyle = UITextBorderStyleRoundedRect;
    motionStartTimeTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    motionStartTimeTextField_.delegate = self;
    motionStartTimeTextField_.returnKeyType = UIReturnKeyNext;
    motionStartTimeTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    motionStartTimeTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    motionStartTimeTextField_.keyboardType = UIKeyboardTypeDefault;
    
    dateStartPicker = [[UIDatePicker alloc] init];
    [dateStartPicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [dateStartPicker setDate:[NSDate date]];
//    [datePicker setMaximumDate:[NSDate date]];
    [dateStartPicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [dateStartPicker addTarget:self action:@selector(dateStartPickerValueChanged) forControlEvents:UIControlEventValueChanged];
    motionStartTimeTextField_.inputView = dateStartPicker;
    [self.view addSubview:motionStartTimeTextField_];
    
    // Motion time label.
    UILabel *motionEndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 160, 200, 29)];
    motionEndTimeLabel.text = @"End Time";
    motionEndTimeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionEndTimeLabel.textAlignment = NSTextAlignmentLeft;
    motionEndTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionEndTimeLabel];
    
    motionEndTimeTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 160, serverWidth, 30)];
    motionEndTimeTextField_.borderStyle = UITextBorderStyleRoundedRect;
    motionEndTimeTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    motionEndTimeTextField_.delegate = self;
    motionEndTimeTextField_.returnKeyType = UIReturnKeyNext;
    motionEndTimeTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    motionEndTimeTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    motionEndTimeTextField_.keyboardType = UIKeyboardTypeDefault;
    
    dateEndPicker = [[UIDatePicker alloc] init];
    [dateEndPicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [dateEndPicker setDate:[NSDate date]];
    //    [datePicker setMaximumDate:[NSDate date]];
    [dateEndPicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [dateEndPicker addTarget:self action:@selector(dateEndPickerValueChanged) forControlEvents:UIControlEventValueChanged];
    motionEndTimeTextField_.inputView = dateEndPicker;
    [self.view addSubview:motionEndTimeTextField_];
    
    // Motion Position label.
    UILabel *motionPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 208, 200, 29)];
    motionPositionLabel.text = @"Position";
    motionPositionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionPositionLabel.textAlignment = NSTextAlignmentLeft;
    motionPositionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionPositionLabel];
    
    motionPositionBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    motionPositionBtn.frame = CGRectMake(130, 208, serverWidth, 30);
    motionPositionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionPositionBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [motionPositionBtn setTitle:@"My Position" forState:UIControlStateNormal];
    [motionPositionBtn addTarget:self
                          action:@selector(motionPositionBtnPress)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:motionPositionBtn];

/*
    motionPositionTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 208, serverWidth, 30)];
    motionPositionTextField_.borderStyle = UITextBorderStyleRoundedRect;
    motionPositionTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    motionPositionTextField_.delegate = self;
    motionPositionTextField_.returnKeyType = UIReturnKeyNext;
    motionPositionTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    motionPositionTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    motionPositionTextField_.keyboardType = UIKeyboardTypeDefault;
    motionPositionTextField_.placeholder = @"Please select position...";
    [self.view addSubview:motionPositionTextField_];

    // Discription label.
    UILabel *discriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 256, 200, 29)];
    discriptionLabel.text = @"Discription";
    discriptionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    discriptionLabel.textAlignment = NSTextAlignmentLeft;
    discriptionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:discriptionLabel];
    
    discriptionTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 256, serverNameWidth, 30)];
    discriptionTextField_.borderStyle = UITextBorderStyleRoundedRect;
    discriptionTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    discriptionTextField_.delegate = self;
    discriptionTextField_.returnKeyType = UIReturnKeyDone;
    discriptionTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    discriptionTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    discriptionTextField_.keyboardType = UIKeyboardTypeEmailAddress;
    discriptionTextField_.placeholder = @"Please input room discription...";
    [self.view addSubview:discriptionTextField_];
*/
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitBtn.frame = CGRectMake(16, 304, 90, 30);
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    submitBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [submitBtn addTarget:self
                 action:@selector(submitBtnPress)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame = CGRectMake(148, 304, 90, 30);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn addTarget:self
                  action:@selector(cancelBtnPress)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    AppDelegate *app = [self appDelegate];
    app.createRoomDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.createRoomDelegate = nil;
}

// for ios 4 and 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// begin for ios6
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

// end for ios 6

- (void)backgroundTap:(id)sender {
    [roomTextField_ resignFirstResponder];
    [roomPasswordTextField_ resignFirstResponder];
    [motionStartTimeTextField_ resignFirstResponder];
    [motionEndTimeTextField_ resignFirstResponder];
    [motionPositionTextField_ resignFirstResponder];
    [discriptionTextField_ resignFirstResponder];
}

- (void)dateStartPickerValueChanged
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *selected = [dateStartPicker date];
    
    motionStartTimeTextField_.text = [dateFormatter stringFromDate:selected];
    [dateStartPicker removeFromSuperview];
}

- (void)dateEndPickerValueChanged
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *selected = [dateEndPicker date];
    
    motionEndTimeTextField_.text = [dateFormatter stringFromDate:selected];
    [dateEndPicker removeFromSuperview];
}

-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

- (void)submitBtnPress
{
    AppDelegate *app = [self appDelegate];
    RoomModel *room = [[RoomModel alloc] init];
    room.name = roomTextField_.text;
    room.password = roomPasswordTextField_.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];

    NSDate *effectivetimeStart = [dateFormatter dateFromString:motionStartTimeTextField_.text];
    room.effectivetimeStart = effectivetimeStart.timeIntervalSince1970;
    
    NSDate *effectivetimeEnd = [dateFormatter dateFromString:motionEndTimeTextField_.text];
    room.effectivetimeEnd = effectivetimeEnd.timeIntervalSince1970;

    if ((coordinate.latitude > -0.000001 && coordinate.longitude < 0.000001) &&
        (coordinate.longitude > -0.000001 && coordinate.longitude < 0.000001))
    {
        room.coordinatePosition = app.myLocation;
    } else {
        room.coordinatePosition = coordinate;
    }
    
    [app createRoom:room];
}

- (void)cancelBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)motionPositionBtnPress
{
    SelectPositionViewController *selectPositionViewController = [[SelectPositionViewController alloc] init];
    [selectPositionViewController setFinish:self action:@selector(selectPosition:)];
    [self.navigationController pushViewController:selectPositionViewController animated:YES];
}

- (void)selectPosition:(NSString *)position
{
    sscanf([position UTF8String], "[%lf,%lf]", &coordinate.latitude, &coordinate.longitude);
    motionPositionBtn.titleLabel.text = position;
}

#pragma make -
#pragma make XMPPCreateRoomDelegate

- (void)didCreateRoomSuccess
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Create room"
                              message:@"Create room success"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView show];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didCreateRoomFailure:(NSString *)errorMsg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Create room"
                              message:errorMsg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end
