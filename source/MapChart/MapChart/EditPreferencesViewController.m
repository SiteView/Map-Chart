//
//  EditPreferencesViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "EditPreferencesViewController.h"
#import "EditNameViewController.h"
#import "UserProperty.h"

@interface EditPreferencesViewController ()

@end

@implementation EditPreferencesViewController
{
    UIImageView *image_;
    UITableView *table_;
    NSMutableArray *message;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(cancelEdit)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *saveButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(saveEdit)];
    [self.navigationItem setRightBarButtonItem:saveButton];
/*
    image_ = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 3, 0, 50, 50)];
    [self.view addSubview:image_];
*/    
    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    table_.dataSource = self;
    table_.delegate = self;
    
    [self.view addSubview:table_];
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
    // 返回设置项数
    return 1;//[[message objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    switch ([indexPath row]) {
        case 0:
        {
            cell.textLabel.text = NICK_NAME;
            cell.detailTextLabel.text = [UserProperty sharedInstance].nickName ;
            
        }
            break;
            
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    switch (row) {
        case 0:
        {
            EditNameViewController *editNameViewController = [[EditNameViewController alloc] init];
            NSDictionary *dictionary = [message objectAtIndex:0];
            editNameViewController.nickName = dictionary[NICK_NAME];
            [editNameViewController setEditFinish:self callback:@selector(editOpCallback:)];
            [self.navigationController pushViewController:editNameViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)editOpCallback:(NSString *)obj
{
    [UserProperty sharedInstance].nickName = obj;
    
    [table_ reloadData];
}

- (void)cancelEdit
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveEdit
{
    // TODO: 
}
@end
