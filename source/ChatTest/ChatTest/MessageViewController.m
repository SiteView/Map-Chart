//
//  MessageViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-12.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "MessageViewController.h"
#import "AppDelegate.h"
#import "MessageContextCell.h"
#import "MessageContextViewController.h"
#import "MessageListCell.h"
#import "DDLog.h"

#define padding 20

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

//static NSString *USERID = @"userId";
//static NSString *PASS= @"pass";
//static NSString *SERVER = @"server";

@implementation MessageViewController {
    UITableView *tableView_;
    UITextField *messageTextField;
    NSMutableDictionary *messages;

    // 为了响应Model层的变化而设计的。
	NSFetchedResultsController *fetchedResultsController;
}

//@synthesize chatWithUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30)];
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView_];

    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(refreshMessage)];
    [self.navigationItem setRightBarButtonItem:refreshBtn];
    
    AppDelegate *app = [self appDelegate];
    app.messageDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [messageTextField resignFirstResponder];
    return YES;
}

- (void)refreshMessage
{
	[tableView_ reloadData];
}
/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_room];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
        // 需要一个操作环境，即NSManagedObjectContext
        // fetchRequest必须得有一个sortDescriptor
        // 过滤条件predicate则是可选的
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
        // 通过设置keyPath，就是将要读取的entity的（间接）属性，来作为section分类key。
        // 可选的cache名称，以避免执行一些重复操作
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}
*/
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[tableView_ reloadData];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//	return [[[self fetchedResultsController] sections] count];
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
/*	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
*/
    return [[[self appDelegate] managedObjectContext_rooms] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"msgCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    XMPPRoom *room = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSDictionary *dict = [[self appDelegate] managedObjectContext_rooms];

    int index = 0;
    for (NSString *key in dict) {
        if (index == [indexPath row]) {
            cell.textLabel.text = key;
            break;
//            cell.textLabel.text = @"房间或昵称";
//            cell.detailTextLabel.text = @"最后一条消息";
        }
        index++;
    }
/*
    MessageListCell *cell =(MessageListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[MessageListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }

    cell.titleLabel.text = @"房间或昵称";
    cell.messageContentableView.text = @"最后一条消息";
    cell.headImageView.image = [UIImage imageNamed:@"aqua.png"];//[[UIImage alloc] initWithContentsOfFile:@"aqua.png"];
    cell.timeLabel.text = @"昨天";
*/    
/*
    NSDictionary *dict = [messages objectAtIndex:indexPath.row];
    if (dict == nil) {
        return cell;
    }
    //发送者
    NSString *sender = [dict objectForKey:@"sender"];
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"time"];
    
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    size.width +=(padding/2);
    
    cell.messageContentableView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //发送消息
    if ([sender isEqualToString:@"you"]) {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentableView setFrame:CGRectMake(padding, padding*2, size.width + 5, size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentableView.frame.origin.x - padding/2, cell.messageContentableView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }else {
        
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentableView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width + 5, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentableView.frame.origin.x - padding/2, cell.messageContentableView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }
    
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
*/    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[self appDelegate] managedObjectContext_rooms];
 
    NSString *roomName = nil;
    int index = 0;
    for (NSString *key in dict) {
        if (index == [indexPath row]) {
            roomName = key;
            break;
        }
        index++;
    }

    MessageContextViewController* messageContextViewController = [[MessageContextViewController alloc] init];
    
    messageContextViewController.roomName = roomName;
    
    [self.navigationController pushViewController:messageContextViewController animated:YES];
}
/*
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
        [tableView reloadData];
        
    }
    
    
}
*/
#pragma mark XMPPMessageDelegate

-(void)newMessageReceived:(NSDictionary *)messageCotent
{
    [tableView_ reloadData];
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
