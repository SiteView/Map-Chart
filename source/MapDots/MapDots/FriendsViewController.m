//
//  FriendsViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "MessageContextViewController.h"
#import "MemberProperty.h"
#import "PlaceAnnotation.h"
#import "MessageContextCell.h"
#import "UserProperty.h"

#define padding 20
#define KEYBOARD_HEIGHT 256

@implementation FriendsViewController
{
    BOOL isViewPosition_;
    UIView *viewPosition_;
    UIView *viewMessages_;
    UIBarButtonItem *flipMapButton_;
    UIBarButtonItem *flipListButton_;

    UIToolbar *toolBar;
    
    // viewPosition_
#ifdef GOOGLE_MAPS
    BOOL firstLocationUpdate_;
    GMSMapView *mapView_;
#else
#ifdef BAIDU_MAPS
    BMKMapView *mapView_;
#else
    CLLocationManager *locationManager;
    MKMapView *mapView_;
#endif
#endif
    CLLocationCoordinate2D position_;

    // GSMaker
    NSMutableDictionary *onlineMaker_;
    UIBarButtonItem *messageButton_;
    BOOL isMapView_;
    
    // viewMessages_
    UITableView *tView;
    UITextField *messageTextField;
    UIControl* messageControl_;
    UIButton *sendBtn;
    int messageRightPosition;
    BOOL isShowKeyboard;
	NSFetchedResultsController *fetchedResultsController;
    NSDateFormatter *dateFormatter;

    float keyboardHeight;
//    MessageContextViewController* messageContextViewController;
}

@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = roomName;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    flipListButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Message"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(flipView)];
    flipMapButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:@selector(flipView)];

    
    // viewMessages_
    float controlTop = 0;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        controlTop = 30;
    }

    viewMessages_ = [[UIView alloc] initWithFrame:rect];
    
    CGFloat tableBottom = self.view.bounds.size.height - 80;
    CGFloat textTop = tableBottom + 5;
    
    float messageTextFieldWidth = 229;
    float sendBtnLeft = 235;
    messageRightPosition = 320;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        messageTextFieldWidth = 610;
        sendBtnLeft = 615;
        messageRightPosition = 768;
    }
    viewMessages_.backgroundColor = [UIColor blackColor];
//    viewMessages_.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
/*    messageControl_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [messageControl_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [viewMessages_ addSubview:messageControl_];
*/    
    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, controlTop, self.view.bounds.size.width, tableBottom)];
    tView.delegate = self;
    tView.dataSource = self;
    tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [viewMessages_ addSubview:tView];
    
    
    messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(3, textTop + controlTop, messageTextFieldWidth, 29)];
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    messageTextField.delegate = self;
    messageTextField.returnKeyType = UIReturnKeySend;
    messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    messageTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    messageTextField.keyboardType = UIKeyboardTypeDefault;
    [viewMessages_ addSubview:messageTextField];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(sendBtnLeft, textTop + controlTop, 70, 29);
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [sendBtn addTarget:self
                action:@selector(sendButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [viewMessages_ addSubview:sendBtn];
    
    // 滚动到最后一行
    [self scrollToLastRow];

    
    // viewPosition_
    viewPosition_ = [[UIView alloc] initWithFrame:rect];
    
    CGRect rectToolBar = CGRectMake(0,
                                    self.view.bounds.size.height - 40,
                                self.view.bounds.size.width,
                                self.view.bounds.size.height - 40 - toolBar.frame.size.height);
//    toolBar = [[UIToolbar alloc] initWithFrame:rectToolBar];
    toolBar = [[UIToolbar alloc] init];
    
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    
    [myToolBarItems addObject:[[UIBarButtonItem alloc]
                                initWithTitle:@"Members"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(actionMembers)]];
    [myToolBarItems addObject:flipListButton_];
    [toolBar setItems:myToolBarItems animated:YES];

    CGRect rectMap = CGRectMake(0,
                                controlTop,
                                self.view.bounds.size.width,
                                self.view.bounds.size.height - 40 - toolBar.frame.size.height);
    

#ifdef GOOGLE_MAPS
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.17523
                                                            longitude:112.9803
                                                                 zoom:10];
    mapView_ = [GMSMapView mapWithFrame:rectMap camera:camera];
    mapView_.buildingsEnabled = YES;
    mapView_.delegate = self;
    mapView_.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
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
#else
    mapView_ = [[MKMapView alloc] initWithFrame:rect];
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
#endif
 
    onlineMaker_ = [NSMutableDictionary dictionary];
    
//    [viewPosition_ addSubview:toolBar];
    [viewPosition_ addSubview:mapView_];
    
    [self.view addSubview:viewMessages_];
    [self.view addSubview:viewPosition_];
    
    isViewPosition_ = YES;
    
//    [self.navigationItem setLeftBarButtonItem:createEventButton_];
    [self.navigationItem setRightBarButtonItem:flipListButton_];
//    [self.navigationItem setRightBarButtonItem:toolBar];

//    [self.navigationController.visibleViewController.navigationController.navigationBar addSubview:toolBar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFriendsPosition];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = roomName;

    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
#ifdef GOOGLE_MAPS
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
#endif
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = nil;
    
    // 移除键盘事件的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
//    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        
        AppDelegate *app = [self appDelegate];
        app.myLocation = location.coordinate;
        
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
//    }
}

#else
#ifdef BAIDU_MAPS
#else


#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    
    position_ = coordinate;
    [self appDelegate].myLocation = coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region = {coordinate, span};
    [mapView_ setRegion:region];
    mapView_.showsUserLocation = YES;
}
#endif
#endif

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}
/*
- (void)messageContext
{
    messageContextViewController.roomName = self.title;
    [self.navigationController pushViewController:messageContextViewController animated:YES];
}
*/
- (void)flipView
{
    // Start Animation Block
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    
    NSInteger list = [[self.view subviews] indexOfObject:viewMessages_];
    NSInteger map = [[self.view subviews] indexOfObject:viewPosition_];
    
    // Animations
    [self.view exchangeSubviewAtIndex:list withSubviewAtIndex:map];
    
    // commit Animation Block
    [UIView commitAnimations];
    
    if (isViewPosition_) {
        isViewPosition_ = NO;
        
//        [self.navigationItem setLeftBarButtonItem:refreshButton_];
        [self.navigationItem setRightBarButtonItem:flipMapButton_];
    } else {
        isViewPosition_ = YES;
        [self.navigationItem setLeftBarButtonItem:nil];
        
        [self hideKeyboard];

//        [self.navigationItem setLeftBarButtonItem:createEventButton_];
        [self.navigationItem setRightBarButtonItem:flipListButton_];
    }
}

- (void)actionMembers
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK" message:@"OK" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
}

#ifdef GOOGLE_MAPS

//在线好友
-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSLog(@"%s", __FUNCTION__);
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.position = coordinate;
        marker.icon = [GMSMarker markerImageWithColor:color];

    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName
{
    NSLog(@"%s", __FUNCTION__);
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.map = nil;
    }
}

- (void)updateBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    GMSMarker *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.position = coordinate;
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.map = mapView_;
    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = title;
//    marker.snippet = @"Population: 4,605,992";
    marker.animated = YES;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.map = mapView_;
    
    if (marker != nil && [title length] > 0) {
        [onlineMaker_ setObject:marker forKey:title];
    }
}

#else
// BAIDU_MAPS和Apple Map使用相同的PlaceAnnotation
//在线好友
-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSLog(@"%s", __FUNCTION__);
    
        PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
        if (marker) {
            marker.coordinate = coordinate;
            //        marker.icon = [GMSMarker markerImageWithColor:color];
            
        } else {
            [self addCoordinate:buddyName coordinate:coordinate color:color];
        }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName
{
    NSLog(@"%s", __FUNCTION__);
    PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        [mapView_ removeAnnotation:marker];
    }
}

- (void)updateBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    PlaceAnnotation *marker = [onlineMaker_ objectForKey:buddyName];
    if (marker) {
        marker.coordinate = coordinate;
    } else {
        [self addCoordinate:buddyName coordinate:coordinate color:color];
    }
}

- (void)addCoordinate:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color
{
    NSString *lowerName = [title lowercaseString];
    NSString *lowerNickName = [[UserProperty sharedInstance].nickName lowercaseString];
    if ([lowerName isEqualToString:lowerNickName]) {
    } else {

        PlaceAnnotation *marker = [[PlaceAnnotation alloc] init];
        marker.title = title;
        marker.coordinate = coordinate;
        [mapView_ addAnnotation:marker];
        
        if (marker != nil && [title length] > 0) {
            [onlineMaker_ setObject:marker forKey:title];
        }
    }
}
#endif

- (void)showFriendsPosition
{
    NSLog(@"%s", __FUNCTION__);
    AppDelegate *app = [self appDelegate];
    RoomModel *room = [app.xmppRoomList_ objectForKey:roomName];
    if (room.members != nil) {
        [room.members enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            MemberProperty * member = obj;
            
            NSString *lowerName = [member.name lowercaseString];
            NSString *lowerNickName = [[UserProperty sharedInstance].nickName lowercaseString];
            if ([lowerName isEqualToString:lowerNickName]) {
            } else {
                [self updateBuddyOnline:member.name coordinate:member.coordinatePosition color:member.color];
            }
        }];
    }
}

#ifdef GOOGLE_MAPS
#pragma mark -
#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    
}
#endif

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect ekbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat yOffset = ekbSize.origin.y - bkbSize.origin.y;
    
    // 弹出:-216
    // 汉字:-36
    NSLog(@"%f", yOffset);
    
    keyboardHeight += yOffset;
//    [self moveInputBarWithKeyboardHeight:yOffset withDuration:0.0];
    CGRect frame = self.view.frame;
    
    frame.origin.y += yOffset;
    
    frame.size.height -= yOffset;
    
    self.view.frame = frame;
    
    [UIView beginAnimations:@"ResizeView"context:nil];
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = frame;
    
    [UIView commitAnimations];
    
    isShowKeyboard = YES;

}

- (void)keyboardWillShow:(NSNotification *)notification
{
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(float)height withDuration:(int)duration
{
/*    if ((height > -0.00001) && (height < 0.00001))
    {
        [self hideKeyboard];
    } else {
        keyboardHeight = height;
        [self showKeyboard];
    }
*/ 
}

- (void)showKeyboard
{
//    keyboardHeight = KEYBOARD_HEIGHT;
    if (isShowKeyboard) {
    } else {
        CGRect frame = self.view.frame;
        
        frame.origin.y -= keyboardHeight;
        
        frame.size.height += keyboardHeight;
        
        self.view.frame = frame;
        
        [UIView beginAnimations:@"ResizeView"context:nil];
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView setAnimationDuration:animationDuration];
        
        self.view.frame = frame;
        
        [UIView commitAnimations];
        
        isShowKeyboard = YES;
    }
}

- (void)hideKeyboard
{
//    keyboardHeight = KEYBOARD_HEIGHT;
    if (isShowKeyboard) {
        NSTimeInterval animationDuration = 0.30f;
        
        CGRect frame = self.view.frame;
        
        frame.origin.y -= keyboardHeight;
        
        frame.size.height += keyboardHeight;
        
        self.view.frame = frame;
        
        //self.view移回原位置
        
        [UIView beginAnimations:@"ResizeView" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        self.view.frame = frame;
        
        [UIView commitAnimations];

        keyboardHeight = 0.0;
        isShowKeyboard = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButton:nil];
    [self hideKeyboard];
    return YES;
}
/*
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self hideKeyboard];
    return NO;
}
*/
- (void)backgroundTap:(id)sender
{
    [self hideKeyboard];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_room];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSPredicate *predicate;
        if ([roomName length] == 0) {
            predicate = [[NSPredicate alloc] init];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"roomJIDStr == %@", roomName];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil//@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            NSLog(@"Error performing fetch: %@", error);
        }
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [tView reloadData];
    
    // 滚动到最后一行
    [self scrollToLastRow];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(MessageContextCell *)cell message:(XMPPRoomMessageCoreDataStorageObject *)message
{
    //消息
    NSString *messageStr = message.body;

    NSString *nickName = message.nickname;
    if (nickName == nil) {
        NSString *name = message.jidStr;
        if (name != nil) {
            nickName = [[name componentsSeparatedByString:@"/"] lastObject];
        }
    }
    
    NSString *strTitle = nickName;
    if (nickName != nil) {
        strTitle = [[nickName componentsSeparatedByString:@"@"] objectAtIndex:0];
    }
    NSString *time = [dateFormatter stringFromDate:message.localTimestamp];
    
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [messageStr sizeWithFont:[UIFont boldSystemFontOfSize:13]
                         constrainedToSize:textSize
                             lineBreakMode:NSLineBreakByWordWrapping];
    
    size.width +=(padding/2);
    
    cell.messageContentView.text = messageStr;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if ((message.isFromMe) || [strTitle isEqualToString:[UserProperty sharedInstance].nickName])
    {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding,
                                                     padding*2,
                                                     size.width + 5,
                                                     size.height)];

        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              size.width + padding,
                                              size.height + padding)];
        
        cell.senderAndTimeLabel.textAlignment = UITextAlignmentLeft;
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@\n%@", strTitle, time];
        //    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
    }else {
        
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(messageRightPosition - size.width - padding,
                                                     padding*2,
                                                     size.width + 5,
                                                     size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              size.width + padding,
                                              size.height + padding)];

        cell.senderAndTimeLabel.textAlignment = UITextAlignmentRight;
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@\n%@", strTitle, time];
        //    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
    }
    
    cell.bgImageView.image = bgImage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)scrollToLastRow
{
    NSInteger lastIndex = ([tView numberOfRowsInSection:0] - 1);
    if (lastIndex <= 0) {
        return;
    }
    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:lastIndex
                                              inSection:0];
    
    [tView scrollToRowAtIndexPath:lastRow
                 atScrollPosition:UITableViewScrollPositionBottom
                         animated:YES];
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSDictionary *dict  = [messages objectAtIndex:indexPath.row];
    //    NSString *msg = [dict objectForKey:@"msg"];
    XMPPRoomMessageCoreDataStorageObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *msg = message.body;
    
    CGSize textSize = {260.0 , 10000.0};
    CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    size.height += padding*2;
    
    CGFloat height = size.height < 75 ? 75 : size.height;
    
    return height;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    NSInteger count = 0;
    if (section < [sections count]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		count = sectionInfo.numberOfObjects;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"msgCell";
    
    MessageContextCell *cell = (MessageContextCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[MessageContextCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    XMPPRoomMessageCoreDataStorageObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
	[self configurePhotoForCell:cell message:message];
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)getCurrentTime{
    
    NSDate *nowUTC = [NSDate date];
    return [dateFormatter stringFromDate:nowUTC];
}

- (void)sendButton:(id)sender {
    
    //本地输入框中的信息
    NSString *message = messageTextField.text;
    
    if (message.length > 0) {
        [[self appDelegate] sendRoomMessage:roomName message:message];
        
        messageTextField.text = @"";
        [messageTextField resignFirstResponder];
        [self hideKeyboard];
    }
}

@end
