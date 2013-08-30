//
//  EditSexViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-14.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "EditSexViewController.h"

#define MALE    @"Male"
#define FEMALE @"Female"

@interface EditSexViewController ()

@end

@implementation EditSexViewController
{
//    UISegmentedControl *segmentedControl;
    UITableView *tView;
}

@synthesize sex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                          self.view.bounds.size.width,
                                                          self.view.bounds.size.height)
                                         style:UITableViewStyleGrouped];
    
    
    tView.delegate = self;
    tView.dataSource = self;
    
    [self.view addSubview:tView];
/*
    UILabel *tint = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, self.view.bounds.size.width, 30)];
    tint.text = @"请选择你的性别";
    [self.view addSubview:tint];
    
    NSArray *segmentedArray = @[MALE, FEMALE];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(3, 33, self.view.bounds.size.width - 6, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    
    [segmentedControl addTarget:self
                         action:@selector(segmentAction:)
               forControlEvents:UIControlEventValueChanged];

    if ([sex isEqualToString:MALE]) {
        segmentedControl.selectedSegmentIndex = 0;
    } else {
        segmentedControl.selectedSegmentIndex = 1;
    }

    [self.view addSubview:segmentedControl];
*/ 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditFinish:(id)target callback:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;
}
/*
- (void)segmentAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            sex = MALE;
            break;
        case 1:
            sex = FEMALE;
            break;
            
        default:
            break;
    }
    
    [m_target_edit performSelector:m_selector_edit withObject:sex];
}
*/
#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == tView) {
        return @"Please select your gender";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = MALE;
            break;
        case 1:
            cell.textLabel.text = FEMALE;
            break;
            
        default:
            break;
    }
    
    // Set cell checkmark
    if ([sex isEqualToString:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    switch (row) {
        case 0:
        {
            sex = MALE;
        }
            break;
        case 1:
        {
            sex = FEMALE;
        }
            break;
            
        default:
            break;
    }
    [m_target_edit performSelector:m_selector_edit withObject:sex];

    [tableView reloadData];
}


@end
