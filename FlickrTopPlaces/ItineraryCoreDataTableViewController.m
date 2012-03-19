//
//  ItineraryCoreDataTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "ItineraryCoreDataTableViewController.h"
#import "Place.h"
#import "FlickrFetcherHelper.h"
#import "CoreDataImageListTableViewController.h"

@interface ItineraryCoreDataTableViewController() <UINavigationControllerDelegate>
@end

@implementation ItineraryCoreDataTableViewController

@synthesize document = _document;

#pragma mark - setters/getters

-(void) setDocument:(UIManagedDocument *)document
{
    _document = document;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstVisitedAt" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.navigationItem.title = @"Itinerary";
}

-(void) popViewControllerIfNecessary
{
    if (self.fetchedResultsController.fetchedObjects.count == 0)
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
    
    self.navigationController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self popViewControllerIfNecessary];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itinerary place cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [FlickrFetcherHelper cityNameForPlaceWithName:place.name];
    cell.detailTextLabel.text = [FlickrFetcherHelper restOfPlaceNameAndCountryForPlaceWithName:place.name];
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setRequest:inManagedObjectContext:)]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"takenAtPlace = %@", place];
        [segue.destinationViewController setRequest:request inManagedObjectContext:self.document.managedObjectContext];
        [segue.destinationViewController setTitle:[FlickrFetcherHelper cityNameForPlaceWithName:place.name]];
    }
}

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // NEVER GET CALLED!!!
    if (viewController == self) {
        [self popViewControllerIfNecessary];
    }
}
@end
