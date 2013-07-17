//
//  MessageViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-12.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MessageViewController.h"
#import "AppDelegate.h"
#import "MessageCell.h"

#define padding 20

static NSString *USERID = @"userId";
static NSString *PASS= @"pass";
static NSString *SERVER = @"server";

@implementation MessageViewController {
    UITableView *tView;
    UITextField *messageTextField;
    NSMutableArray *messages;

}

@synthesize chatWithUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    self.title = chatWithUser;
    
    messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(3, 3, 229, 29)];
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    messageTextField.delegate = self;
    messageTextField.returnKeyType = UIReturnKeyJoin;
    messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    messageTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    messageTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [messageTextField becomeFirstResponder];
    [self.view addSubview:messageTextField];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(235, 3, 70, 29);
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [sendBtn addTarget:self
                 action:@selector(sendButton:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];

    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 30)];
    tView.delegate = self;
    tView.dataSource = self;
    tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tView];
    
    messages = [NSMutableArray array];
    
    AppDelegate *del = [self appDelegate];
    del.messageDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *del = [self appDelegate];
    del.messageDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"msgCell";
    
    MessageCell *cell =(MessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];
    
    //发送者
    NSString *sender = [dict objectForKey:@"sender"];
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"time"];
    
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    size.width +=(padding/2);
    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if ([sender isEqualToString:@"you"]) {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width + 5, size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }else {
        
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width + 5, size.height)];
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
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[self xmppStream] sendElement:mes];
        
        messageTextField.text = @"";
        [messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[self getCurrentTime] forKey:@"time"];
        
        [messages addObject:dictionary];
        
        //重新刷新tableView
        [tView reloadData];
        
    }
    
    
}

#pragma mark XMPPMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageCotent{
    
    [messages addObject:messageCotent];
    
    [tView reloadData];
    
}

- (IBAction)closeButton:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

@end
