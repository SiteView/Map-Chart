//
//  SettingViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "PreferencesViewController.h"
#import "EditPreferencesViewController.h"
#import "UserProperty.h"
#import "EditNameViewController.h"
#import "EditSexViewController.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "GuideViewController.h"

#define VERSION_INFO    @"0.8.6"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController
{
    UIImageView *image_;
    UITableView *table_;
    BOOL isEditMode;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *saveButton;
    UIBarButtonItem *editButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    
    editButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(editNickName)];
    cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(cancelEdit)];
    saveButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save")
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(saveEdit)];
    [self.navigationItem setRightBarButtonItem:editButton];
/*
    image_ = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 3, 0, 50, 50)];
    [self.view addSubview:image_];
*/    
    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    table_.dataSource = self;
    table_.delegate = self;
    table_.autoresizesSubviews = YES;
    table_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    table_.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:table_];
/*
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 3, table_.frame.size.height + 15, 100, 40)];
    version.text = [NSString stringWithFormat:@"版本 %@", VERSION_INFO];
    version.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:version];
*/    
    isEditMode = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configurePhoto:(UITableViewCell *)cell
{
    // [UserProperty sharedInstance].nickName
    UIImage *image = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, [UserProperty sharedInstance].account];
    
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:fileName isDirectory:&isDir]) {
        if (!isDir) {
            image = [UIImage imageWithContentsOfFile:fileName];
        }
    }
    
	if (image != nil)
	{
		cell.imageView.image = image;
	}
	else
	{
        cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 2;
            break;
        case 1:
            count = 1;
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if (isEditMode) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    switch ([indexPath section]) {
        case 0:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    cell.textLabel.text = NICK_NAME;
                    cell.detailTextLabel.text = [UserProperty sharedInstance].nickName ;
                    [self configurePhoto:cell];
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = PEOPLE_SEX;
                    cell.detailTextLabel.text = [UserProperty sharedInstance].sex ;
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case 1:
        {
            switch ([indexPath row])
            {
                case 0:
/*                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = @"功能介绍";
                    break;
                    
                case 1:
*/
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = @"关于 MapDots";
                    break;
            }

        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (section == 0) {
        if (!isEditMode)
        {
            return;
        }
        
        switch ([indexPath row]) {
            case 0:
            {
                EditNameViewController *editNameViewController = [[EditNameViewController alloc] init];
                editNameViewController.nickName = [UserProperty sharedInstance].nickName;
                editNameViewController.account = [UserProperty sharedInstance].account;
                [editNameViewController setEditFinish:self callback:@selector(editOpCallback:)];
                
                [editNameViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:editNameViewController animated:YES];
            }
                break;
            case 1:
            {
                EditSexViewController *editSexViewController = [[EditSexViewController alloc] init];
                editSexViewController.sex = [UserProperty sharedInstance].sex;
                [editSexViewController setEditFinish:self callback:@selector(editSexOpCallback:)];

                [editSexViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:editSexViewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else if (section == 1)
    {
        switch ([indexPath row]) {
            case 0:
/*            {
                GuideViewController *guideViewController = [[GuideViewController alloc] init];
                
                [guideViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:guideViewController animated:YES];
            }
                break;
                
            case 1:
*/
            {
                // About MapDots
                AboutViewController *aboutViewController = [[AboutViewController alloc] init];
                
                [aboutViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:aboutViewController animated:YES];
            }
                break;
        }
    }
}

#pragma make -

- (void)editNickName
{
    // 打开编辑模式
    isEditMode = YES;
    [table_ reloadData];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)cancelEdit
{
    isEditMode = NO;
    [[UserProperty sharedInstance] cancel];

    [table_ reloadData];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:editButton];
}

-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

- (void)saveEdit
{
    UserProperty *userProperty = [UserProperty sharedInstance];
    if (![userProperty.nickName isEqualToString:userProperty.originalNickName]) {
        // 修改NickName
        [[self appDelegate] changeNickName:userProperty.nickName];
    }
    
    if (![userProperty.sex isEqualToString:userProperty.originalSex]) {
        // 修改sex
        [[self appDelegate] changeUserSexual:userProperty.UserGender];
    }
    
    isEditMode = NO;
    [table_ reloadData];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:editButton];

    [[UserProperty sharedInstance] save];
}

- (void)editOpCallback:(NSString *)obj
{
    [UserProperty sharedInstance].nickName = obj;
    
    [table_ reloadData];
}

- (void)editSexOpCallback:(NSString *)obj
{
    [UserProperty sharedInstance].sex = obj;
    
    [table_ reloadData];
}
@end
