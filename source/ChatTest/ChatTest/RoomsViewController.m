//
//  RoomsViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "RoomsViewController.h"
#import "AppDelegate.h"
#import "RoomModel.h"

@interface RoomsViewController ()

@end

@implementation RoomsViewController
{
    UITableView *table_;
    NSMutableArray *rooms_;
    NSString *roomPassword_;
    NSString *roomjid_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    self.title = @"聊天室列表";

    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    table_.dataSource = self;
    table_.delegate = self;
    table_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:table_];

    rooms_ = [NSMutableArray array];
    roomPassword_ = nil;
    
/*    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Join", @"Join")
                                     style:UIBarButtonItemStyleBordered
                                    target:@selector(joinRooms)
                                    action:nil];
    [self.navigationItem setRightBarButtonItem:rightButton];
*/
//    [self.navigationItem setHidesBackButton:YES];

    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [app querySupportMUC];
    });

}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [self appDelegate];
    app.roomsDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

-(void)newRoomsReceived:(NSArray *)roomsContent
{
    rooms_ = [roomsContent copy];
    [table_ reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    RoomModel *dict = [rooms_ objectAtIndex:[indexPath row]];
    if (dict.isMucPasswordProtocted) {
        NSString *strProtocted = [NSString stringWithFormat:@"锁 %@", dict.jid];
        cell.detailTextLabel.text = strProtocted;
    } else {
        cell.detailTextLabel.text = dict.jid;
    }
        cell.textLabel.text = dict.name;
    
        
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rooms_ count];
}

- (void)showRoomPasswordAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Room password"
                                    message:@"Enter room password"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.alertViewStyle) {
        case UIAlertViewStyleSecureTextInput:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            roomPassword_ = textField.text;
            
            AppDelegate *app = [self appDelegate];
            app.roomsDelegate = self;
            
            [self joinRoom:roomjid_ password:roomPassword_];
            NSLog(@"Secure text input: %@", textField.text);
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UIAlertViewStyle style = alertView.alertViewStyle;
    
    if ((style == UIAlertViewStyleSecureTextInput) ||
        (style == UIAlertViewStylePlainTextInput) ||
        (style == UIAlertViewStyleLoginAndPasswordInput)) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // join the room
    RoomModel *room = [rooms_ objectAtIndex:[indexPath row]];
    
    roomjid_ = room.jid;
    if (room.isMucPasswordProtocted) {
        // 加密房间，输入密码
        [self showRoomPasswordAlertView];
        return;
    }

    [self joinRoom:roomjid_ password:nil];
    
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];

//    [[app xmppStream] joinRooms:roomjid];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)joinRoom:(NSString *)roomjid password:(NSString *)password
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *app = [self appDelegate];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:roomjid forKey:@"TargetRoom"];
        [defaults synchronize];
        
        [app joinRoom:roomjid password:nil];
    });
    
}

#pragma mark XMPPRoomsDelegate

- (void)didJoinRoomSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didJoinRoomFailure:(NSString *)errorMsg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Room password"
                              message:errorMsg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView show];

}

@end
