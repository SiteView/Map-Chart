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

@implementation FriendsViewController {
    UISearchBar *search_;
    UITableView *tView_;
    // Online users
    NSMutableArray *onlineUsers_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	search_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 29)];
    [self.view addSubview:search_];
    
    tView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 30)];
    tView_.delegate = self;
    tView_.dataSource = self;
    [self.view addSubview:tView_];
    
    onlineUsers_ = [NSMutableArray array];
    
    AppDelegate *app = [self appDelegate];
    app.chatDelegate = self;

    if (app.isOnline) {
        UIBarButtonItem *logoutButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(Logout)];
        [self.navigationItem setLeftBarButtonItem:logoutButton];
    } else {
        UIBarButtonItem *loginButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(login)];
        [self.navigationItem setLeftBarButtonItem:loginButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [onlineUsers_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //文本
    cell.textLabel.text = [onlineUsers_ objectAtIndex:[indexPath row]];
    //标记
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //start a Chat
//    NSString *chatUserName = (NSString *)[onlineUsers_ objectAtIndex:indexPath.row];
    MessageViewController *messageView = [[MessageViewController alloc] init];
    
//    messageView.chatWithUser = chatUserName;

    [self.navigationController pushViewController:messageView animated:YES ];

}

- (void)login
{
    if (self.loginViewController == nil) {
        self.loginViewController = [[LoginViewController alloc] init];
    }
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    [self.navigationController pushViewController:self.loginViewController animated:YES];
    
}

- (void)logout
{
    AppDelegate *app = [self appDelegate];
    [app disconnect];
}

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

//在线好友
-(void)newBuddyOnline:(NSString *)buddyName{
    
    if (![onlineUsers_ containsObject:buddyName]) {
        [onlineUsers_ addObject:buddyName];
        [tView_ reloadData];
    }
    
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName{
    
    [onlineUsers_ removeObject:buddyName];
    [tView_ reloadData];
    
}

@end
