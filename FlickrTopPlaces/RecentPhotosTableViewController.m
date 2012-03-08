//
//  FlickrRecentPlacesTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/21/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "RecentPhotos.h"

/*@interface RecentPhotosTableViewController() <ImageListTableViewControllerDelegate>
@end
*/

@implementation RecentPhotosTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.reversedList = YES;
    //self.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageList = [RecentPhotos retrieveList];
    [self.tableView reloadData];
}

/*
-(void) imageListTVCNewPhotosAvailable:(NSArray *)photos
                    withMapAnnotations:(NSArray *)annotations
                                sender:(ImageListTableViewController *)sender
{
    [self refreshMapWithAnnotations:annotations];
}
 */
@end
