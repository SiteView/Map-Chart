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
        cell.textLabel.text = dict.name;
        cell.detailTextLabel.text = dict.jid;
        
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rooms_ count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // join the room
    RoomModel *room = [rooms_ objectAtIndex:[indexPath row]];
    
    if (room.isMucPasswordProtocted) {
        // 加密房间，输入密码
    }

    [self.navigationController popViewControllerAnimated:YES];
}


@end
