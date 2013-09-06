//
//  RoomMessageViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-24.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MessageContextViewController.h"
#import "MessageContextCell.h"
#import "AppDelegate.h"

#define padding 20

@interface MessageContextViewController ()

@end

@implementation MessageContextViewController
{
    UITableView *tView;
    UITextField *messageTextField;
    UIControl* view_;
    UIButton *sendBtn;
    int messageRightPosition;
    BOOL isShowKeyboard;
	NSFetchedResultsController *fetchedResultsController;
    NSDateFormatter *dateFormatter;
}

@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = roomName;
    isShowKeyboard = NO;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    

    float messageTextFieldWidth = 229;
    float sendBtnLeft = 235;
    messageRightPosition = 320;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        messageTextFieldWidth = 610;
        sendBtnLeft = 615;
        messageRightPosition = 768;
    }
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
    view_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];

    CGFloat tableBottom = self.view.bounds.size.height - 130;
    CGFloat textTop = self.view.bounds.size.height - 130 + 5;

    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, tableBottom)];
    tView.delegate = self;
    tView.dataSource = self;
    tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tView];

    
    messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(3, textTop, messageTextFieldWidth, 29)];
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    messageTextField.delegate = self;
    messageTextField.returnKeyType = UIReturnKeySend;
    messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    messageTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    messageTextField.keyboardType = UIKeyboardTypeDefault;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [self.view addSubview:messageTextField];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(sendBtnLeft, textTop, 70, 29);
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [sendBtn addTarget:self
                action:@selector(sendButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    // 滚动到最后一行
    [self scrollToLastRow];

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// for ios 4 and 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// begin for ios6
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

// end for ios 6
*/

- (void)showKeyboard
{
    isShowKeyboard = YES;
    
    CGRect frame = self.view.frame;
    
    frame.origin.y -=216;
    frame.origin.y += 30;
    
    frame.size.height +=216;
    frame.size.height -= 30;

    self.view.frame = frame;
    
    [UIView beginAnimations:@"ResizeView"context:nil];
    
    NSTimeInterval animationDuration = 0.30f;   
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)hideKeyboard
{
    
    NSTimeInterval animationDuration = 0.30f;
    
    CGRect frame = self.view.frame;
    
    frame.origin.y +=216;
    frame.origin.y -= 30;
    
    frame.size.height -=216;
    frame.size.height += 30;
    
    self.view.frame = frame;
    
    //self.view移回原位置
    
    [UIView beginAnimations:@"ResizeView" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = frame;
    
    [UIView commitAnimations];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButton:nil];
    return YES;
}

-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)backgroundTap:(id)sender {
    if (isShowKeyboard) {
        [self textFieldShouldReturn:messageTextField];
        isShowKeyboard = NO;
    }
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
    NSString *nickName = message.jidStr;
    
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
    if (message.isFromMe)
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
    }
    
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", nickName, time];    
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
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    
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
    
    MessageContextCell *cell =(MessageContextCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
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
