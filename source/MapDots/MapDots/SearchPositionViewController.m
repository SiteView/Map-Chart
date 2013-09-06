//
//  SearchPositionViewController.m
//  MapChat
//
//  Created by siteview_mac on 13-8-27.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "SearchPositionViewController.h"
#import "AppDelegate.h"
#import "MapViewController.h"

#define SEARCH_HEIGH    40

@interface SearchPositionViewController ()

@end

@implementation SearchPositionViewController
{
    UISearchBar *search_;
    UITableView *table_;
    NSArray *places;
    MKCoordinateRegion boundingRegion;
    MKLocalSearch *localSearch;
    UIBarButtonItem *viewAllButton;
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rectSearch = CGRectMake(0, 0,
                                   self.view.bounds.size.width,
                                   SEARCH_HEIGH);
    
    search_ = [[UISearchBar alloc] initWithFrame:rectSearch];
    search_.showsCancelButton = YES;
    search_.keyboardType = UIKeyboardTypeDefault;
    search_.placeholder = @"Please enter position...";
    search_.delegate = self;
    [self.view addSubview:search_];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectMake(0, SEARCH_HEIGH, self.view.bounds.size.width, self.view.bounds.size.height - SEARCH_HEIGH)];
    table_.dataSource = self;
    table_.delegate = self;
    table_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table_.autoresizesSubviews = YES;
    table_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:table_];

    viewAllButton =
    [[UIBarButtonItem alloc] initWithTitle:@"All"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(showAll:)];
    [self.navigationItem setRightBarButtonItem:viewAllButton];
    
/*
    MapViewController *mapViewController;
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setFinish:m_target_edit action:m_selector_edit];
*/ 
}


- (void)setFinish:(id)target action:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    MKMapItem *mapItem = [places objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapViewController *mapViewController;
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setFinish:m_target_edit action:m_selector_edit];

    // pass the new bounding region to the map destination view controller
    mapViewController.boundingRegion = boundingRegion;
    
    // pass the individual place to our map destination view controller
    NSIndexPath *selectedItem = [table_ indexPathForSelectedRow];
    mapViewController.mapItemList = [NSArray arrayWithObject:[places objectAtIndex:selectedItem.row]];
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}
#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
/*    NSString *strSearch = [NSString stringWithFormat:@"comgooglemaps://?q=%@", searchBar.text];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strSearch]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strSearch]];
    }
*/
    if (localSearch.searching) {
        [localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = [self appDelegate].myLocation.latitude;
    newRegion.center.longitude = [self appDelegate].myLocation.longitude;

    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //  (smaller delta values corresponding to a highter zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            places = [response mapItems];
            
            // TODO: 
//            [places sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // used for later when setting the map's region in "prepareForSegue"
            boundingRegion = response.boundingRegion;
            
            viewAllButton.enabled = places != nil ? YES : NO;
            
            [table_ reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (localSearch != nil) {
        localSearch = nil;
    }
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (NSComparisonResult)caseInsensitiveCompare:(MKMapItem *)mapItem
{
//    return NSOrderedDescending;
    return [@"" compare:mapItem.name];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disable for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO) {
        causeStr = @"device";
    }
    // check the application's explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil) {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (IBAction)showAll:(id)sender
{
    MapViewController *mapViewController;
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setFinish:m_target_edit action:m_selector_edit];

    // pass the new bounding region to the map destination view controller
    mapViewController.boundingRegion = boundingRegion;
    
    // pass the places list to the map destination view controller
    mapViewController.mapItemList = places;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

@end
