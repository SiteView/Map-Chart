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
#import "UserProperty.h"

#define padding 20

static NSString *USERID = @"userId";

@interface MessageContextViewController ()

@end

@implementation MessageContextViewController
{
    UITableView *tView;
    UITextField *messageTextField;
    NSMutableArray *messages;
    UIControl                       * view_;
    NSString *from_;
    NSString *to_;
    int messageRightPosition;
}

@synthesize roomName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = roomName;
    
    float messageTextFieldWidth = 229;
    float sendBtnLeft = 235;
    messageRightPosition = 320;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        messageTextFieldWidth = 610;
        sendBtnLeft = 615;
        messageRightPosition = 768;
    }
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
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
    messageTextField.returnKeyType = UIReturnKeyJoin;
    messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    messageTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    messageTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:messageTextField];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(sendBtnLeft, textTop, 70, 29);
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [sendBtn addTarget:self
                action:@selector(sendButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    [self loadHistoryRecord];
    
}

- (void)loadHistoryRecord
{
    // 加载聊天记录
    
    AppDelegate *app = [self appDelegate];
    app.roomMessageDelegate = self;
    
    messages = [[[self appDelegate] managedObjectContext_roomMessage:roomName] mutableCopy];
    /*
     messages = [NSMutableArray array];
     
     [messages addObject:@"测试1"];
     [messages addObject:@"测试1"];
     
     
     AppDelegate *app = [self appDelegate];
     
     if (app.messageList != nil)
     {
     messages = [[NSMutableDictionary alloc] initWithDictionary:[app.messageList copy]];
     } else {
     messages = [NSMutableDictionary dictionary];
     }
     */
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.roomMessageDelegate = nil;
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
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [messageTextField resignFirstResponder];
    return YES;
}
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
}

- (void)newMessageReceived:(NSDictionary *)array from:(NSString *)from to:(NSString *)to
{
//    messages = [array copy];
    [messages addObject:array];
    from_ = [from copy];
    to_ = [to copy];
    [tView reloadData];
}

- (void)backgroundTap:(id)sender {
    [messageTextField resignFirstResponder];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"msgCell";
    
    MessageContextCell *cell =(MessageContextCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[MessageContextCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSDictionary *dict = [messages objectAtIndex:indexPath.row];
    
    //发送者
    NSArray *array = [[dict objectForKey:@"SendUser"] componentsSeparatedByString:@"/"];
    NSString *sender = [array lastObject];
    NSArray *nick = [sender componentsSeparatedByString:@"@"];
    NSString *nickName = [nick objectAtIndex:0];
    
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"SendTime"];
    
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    size.width +=(padding/2);
    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if ([nickName isEqualToString:[UserProperty sharedInstance].nickName]) {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width + 5, size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }else {
    
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(messageRightPosition - size.width - padding, padding*2, size.width + 5, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }
    
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];

    return cell;
    
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *dict  = [messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];
    
    CGSize textSize = {260.0 , 10000.0};
    CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    size.height += padding*2;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    
    return height;
    
}

- (NSString *)getCurrentTime{
    
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}

- (void)sendButton:(id)sender {

    //本地输入框中的信息
    NSString *message = messageTextField.text;
    
    if (message.length > 0) {
        /*
         <message
         from='hag66@shakespeare.lit/pda'
         id='hysf1v37'
         to='coven@chat.shakespeare.lit'
         type='groupchat'>
         <body>Harpier cries: 'tis time, 'tis time.</body>
         </message>
         
         <message type="groupchat" to="&#x6D4B;&#x8BD5;@conference.siteviewwzp/cw" from="d2ecf8dd@siteviewwzp/1e960fb5"><body>aaaaaa</body></message>
         <message type="groupchat" to="&#x6D4B;&#x8BD5;@conference.siteviewwzp/cw" from="af7c55a7@siteviewwzp/a6c19564"><body>eeee</body></message>
        */
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *to = [defaults objectForKey:@"TargetRoom"];

        [mes addAttributeWithName:@"to" stringValue:roomName];
        //由谁发送
//        NSString *from = [defaults objectForKey:@"account"];
        NSString *from = from_;//[[NSUserDefaults standardUserDefaults] objectForKey:USERID];
        [mes addAttributeWithName:@"from" stringValue:from];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[self xmppStream] sendElement:mes];
        
        messageTextField.text = @"";
        [messageTextField resignFirstResponder];
/*
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[self getCurrentTime] forKey:@"time"];
        
        [messages addObject:dictionary];
        
        //重新刷新tableView
        [tView reloadData];
*/        
    }
    
    
}

@end
