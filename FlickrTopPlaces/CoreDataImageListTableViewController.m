//
//  CoreDataImageListTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/12/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "CoreDataImageListTableViewController.h"
#import "Photo+Create.h"
#import "FlickrImageViewController.h"

@interface CoreDataImageListTableViewController() 
@property (nonatomic, strong) NSManagedObjectContext* documentContext;
@property (nonatomic, strong) NSFetchRequest* request;
@end

@implementation CoreDataImageListTableViewController
@synthesize request = _request;
@synthesize documentContext = _documentContext;
@dynamic title;

#pragma mark - setters/getters

-(void) refreshList
{
    NSArray* photoEntities = [self.documentContext executeFetchRequest:self.request error:nil];
    NSMutableArray *imageListArray = [[NSMutableArray alloc] initWithCapacity:photoEntities.count];
    for (Photo* photo in photoEntities) {
        [imageListArray addObject:photo.infoDict];
    }
    self.imageList = imageListArray;    
}

-(void) setRequest:(NSFetchRequest *)request inManagedObjectContext:(NSManagedObjectContext *)context
{
    // set imageList 
    self.documentContext = context;
    // request may be the same but results may not!
    _request = request;
    if (self.view.window)
        [self refreshList];
}

-(void) setTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

-(void) popViewControllerIfNecessary
{
    if (self.imageList.count == 0)
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // refresh list from db 
    [self refreshList];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self popViewControllerIfNecessary];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"View Image"]) {
        [segue.destinationViewController setDocumentContext:self.documentContext];
    }
}
@end


