//
//  CreateRoomViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-5.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "CreateEventViewController.h"
#import "AppDelegate.h"
#import "SelectPositionViewController.h"
#import "RoomModel.h"
#import "SelectDateTimeViewController.h"
#import "SearchPositionViewController.h"

@interface CreateEventViewController ()

@end

@implementation CreateEventViewController
{
    UITextField* roomTextField_;
    UITextField* roomPasswordTextField_;
    UISwitch* rememberMeSwitcher_;
    UITextField* motionStartTimeTextField_;
    UITextField* motionEndTimeTextField_;
    UITextField* motionPositionTextField_;
    UITextField* discriptionTextField_;
    UIControl* view_;
    UIButton *motionPositionBtn;
    CLLocationCoordinate2D coordinate;
    SelectDateTimeViewController *selectDateTimeViewController;
    NSDateFormatter *dateFormatter;
    UIActionSheet *actionSheet_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Create Events";
    
    view_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view_.backgroundColor = [UIColor whiteColor];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];
    
//    self.view.backgroundColor =
//    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    

    CGPoint ptNickName;
    CGSize sizeAccount;
    
    float controlTop = 0;
    float passwordWidth = 180;
    float serverWidth = 180;
    float alignRight = 110;
    float rightWidth = 200;
//    float summitBtnLeft = 16;
//    float cancelBtnLeft = 148;
    
    sizeAccount.height = 29;
    ptNickName.x = 120;
    ptNickName.y = 16;

    if ([self appDelegate].isiOS7) {
        controlTop = STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
    }
    
    if ([self appDelegate].isiPAD) {
        sizeAccount.width = 600;
        
        passwordWidth = 600;
        serverWidth = 600;
        
        rightWidth = 600;
        
//        summitBtnLeft = 110;
//        cancelBtnLeft = 300;
        
    } else {
        sizeAccount.width = rightWidth;
        
        passwordWidth = rightWidth;
    }
    
    // Room Name label.
    UILabel *roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16 + controlTop, 200, 29)];
    roomLabel.text = @"Events";
    roomLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    roomLabel.textAlignment = NSTextAlignmentLeft;
    roomLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:roomLabel];
    
    roomTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(alignRight, 16 + controlTop, sizeAccount.width, 30)];
    roomTextField_.borderStyle = UITextBorderStyleRoundedRect;
    roomTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    roomTextField_.returnKeyType = UIReturnKeyDone;
    roomTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    roomTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    roomTextField_.keyboardType = UIKeyboardTypeEmailAddress;
    roomTextField_.placeholder = @"Please input events name...";

    roomTextField_.delegate = self;

    [self.view addSubview:roomTextField_];
    
    // Nick Name label.
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 64 + controlTop, 200, 29)];
    nickNameLabel.text = @"Password";
    nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    nickNameLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nickNameLabel];
    
    roomPasswordTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(alignRight, 64 + controlTop, passwordWidth, 30)];
    roomPasswordTextField_.borderStyle = UITextBorderStyleRoundedRect;
    roomPasswordTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    roomPasswordTextField_.delegate = self;
    roomPasswordTextField_.enabled = YES;

    roomPasswordTextField_.returnKeyType = UIReturnKeyDone;
    roomPasswordTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    roomPasswordTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    roomPasswordTextField_.secureTextEntry = YES;
    roomPasswordTextField_.placeholder = @"Password could is empty...";
    roomPasswordTextField_.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:roomPasswordTextField_];
    
    // Motion time label.
    UILabel *motionStartTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 112 + controlTop, 200, 29)];
    motionStartTimeLabel.text = @"Start Time";
    motionStartTimeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionStartTimeLabel.textAlignment = NSTextAlignmentLeft;
    motionStartTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionStartTimeLabel];
    
    motionStartTimeTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(alignRight, 112 + controlTop, rightWidth, 30)];
    motionStartTimeTextField_.borderStyle = UITextBorderStyleRoundedRect;
    motionStartTimeTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    motionStartTimeTextField_.delegate = self;
//    motionStartTimeTextField_.returnKeyType = UIReturnKeyNext;
//    motionStartTimeTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    motionStartTimeTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [self.view addSubview:motionStartTimeTextField_];
    
    // Motion time label.
    UILabel *motionEndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 160 + controlTop, 200, 29)];
    motionEndTimeLabel.text = @"End Time";
    motionEndTimeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionEndTimeLabel.textAlignment = NSTextAlignmentLeft;
    motionEndTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionEndTimeLabel];
    
    motionEndTimeTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(alignRight, 160 + controlTop, rightWidth, 30)];
    motionEndTimeTextField_.borderStyle = UITextBorderStyleRoundedRect;
    motionEndTimeTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    motionEndTimeTextField_.delegate = self;
//    motionEndTimeTextField_.returnKeyType = UIReturnKeyNext;
//    motionEndTimeTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    motionEndTimeTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:motionEndTimeTextField_];
    
    // Motion Position label.
    UILabel *motionPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 208 + controlTop, 200, 29)];
    motionPositionLabel.text = @"Position";
    motionPositionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionPositionLabel.textAlignment = NSTextAlignmentLeft;
    motionPositionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:motionPositionLabel];
    
    motionPositionBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    motionPositionBtn.frame = CGRectMake(alignRight, 208 + controlTop, rightWidth, 30);
    motionPositionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    motionPositionBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    motionPositionBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [motionPositionBtn setTitle:@"My Position" forState:UIControlStateNormal];
//    [motionPositionBtn setTitle:@"The point on the map" forState:UIControlStateNormal];
    
    [motionPositionBtn addTarget:self
                          action:@selector(motionPositionBtnPress)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:motionPositionBtn];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
        // ios6.1以上才支持MKLocalSearch
        actionSheet_ = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"My Position"
                                          otherButtonTitles:@"Select", @"Search", nil];

    } else {
        actionSheet_ = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"My Position"
                                          otherButtonTitles:@"Select", nil];

    }
    actionSheet_.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet_.destructiveButtonIndex = 3;
/*
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitBtn.frame = CGRectMake(summitBtnLeft, 304 + controlTop, 90, 30);
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    submitBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [submitBtn addTarget:self
                 action:@selector(submitBtnPress)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame = CGRectMake(cancelBtnLeft, 304 + controlTop, 90, 30);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn addTarget:self
                  action:@selector(cancelBtnPress)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
*/
    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle:@"Summit"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(submitBtnPress)];
    [self.navigationItem setRightBarButtonItem:submitBtn];

    selectDateTimeViewController = [[SelectDateTimeViewController alloc] init];

    AppDelegate *app = [self appDelegate];
    app.createRoomDelegate = self;
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
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

-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

#pragma mark -
#pragma mark Action

- (void)submitBtnPress
{
    RoomModel *room = [[RoomModel alloc] init];
    room.roomName = roomTextField_.text;
    room.password = roomPasswordTextField_.text;
    
    NSDate *effectivetimeStart = [dateFormatter dateFromString:motionStartTimeTextField_.text];
    room.effectivetimeStart = effectivetimeStart.timeIntervalSince1970;
    
    NSDate *effectivetimeEnd = [dateFormatter dateFromString:motionEndTimeTextField_.text];
    room.effectivetimeEnd = effectivetimeEnd.timeIntervalSince1970;

    if (room.effectivetimeStart > room.effectivetimeEnd) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Start time must less End Time."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    AppDelegate *app = [self appDelegate];
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
    // 有UITabBar遮挡
//    [actionSheet_ showInView:self.view];
    [actionSheet_ showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)selectPosition:(NSString *)position
{
#define TITLE_LEN   (100)
    char chText[TITLE_LEN] = { 0 };
    sscanf([position UTF8String], "[%lf,%lf]%s", &coordinate.latitude, &coordinate.longitude, chText);
    NSString *strTitle = (NSString *)[NSString stringWithUTF8String:chText ];
    if (([strTitle length] == 0) || [strTitle isEqualToString:@"(null)"]) {
        [motionPositionBtn setTitle:@"The point on the map" forState:UIControlStateNormal];
    } else {
        [motionPositionBtn setTitle:strTitle forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == roomTextField_) {
        [textField resignFirstResponder];
    } else if (textField == roomPasswordTextField_) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 此处编写弹出日期选择器的代码。
    if (textField == motionStartTimeTextField_) {
        [self selectStartTime];
    } else if (textField == motionEndTimeTextField_) {
        [self selectEndTime];
    }
    
    return YES;
}

- (void)selectStartTime
{
    NSDate *date = [dateFormatter dateFromString:motionStartTimeTextField_.text];
    [selectDateTimeViewController initWithDate:date];
    [selectDateTimeViewController setFinish:self action:@selector(startDateCallback:)];
    
    [self.navigationController pushViewController:selectDateTimeViewController animated:YES];
}

- (void)selectEndTime
{
    NSDate *date = [dateFormatter dateFromString:motionEndTimeTextField_.text];
    [selectDateTimeViewController initWithDate:date];
    [selectDateTimeViewController setFinish:self action:@selector(endDateCallback:)];
    
    [self.navigationController pushViewController:selectDateTimeViewController animated:YES];
}

- (void)startDateCallback:(NSDate *)obj
{
    if (obj != nil) {
        motionStartTimeTextField_.text = [dateFormatter stringFromDate:obj];
    }
    
}

- (void)endDateCallback:(NSDate *)obj
{
    if (obj != nil) {
        motionEndTimeTextField_.text = [dateFormatter stringFromDate:obj];
    }
    
}

#pragma make -
#pragma make UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            // My Position
            coordinate = [self appDelegate].myLocation;
            [motionPositionBtn setTitle:@"My position" forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            // Select
            SelectPositionViewController *selectPositionViewController = [[SelectPositionViewController alloc] init];
            [selectPositionViewController setFinish:self action:@selector(selectPosition:)];
            [self.navigationController pushViewController:selectPositionViewController animated:YES];
            
        }
            break;
        case 2:
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
                // Search
                SearchPositionViewController *searchPositionViewController = [[SearchPositionViewController alloc] init];
                [searchPositionViewController setFinish:self action:@selector(selectPosition:)];
                [self.navigationController pushViewController:searchPositionViewController animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
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
