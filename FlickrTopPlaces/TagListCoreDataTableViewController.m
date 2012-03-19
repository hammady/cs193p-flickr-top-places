//
//  TagListCoreDataTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "TagListCoreDataTableViewController.h"
#import "Tag+Create.h"
#import "CoreDataImageListTableViewController.h"

@interface TagListCoreDataTableViewController() <UINavigationControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation TagListCoreDataTableViewController
@synthesize searchBar = _searchBar;

@synthesize document = _document;

#pragma mark - setters/getters

-(void) filterTags:(NSString*) filter
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Tag"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"photosCount" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    if (filter && filter.length) {
        request.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", filter];
    }
    self.fetchedResultsController = [[NSFetchedResultsController alloc] 
                                     initWithFetchRequest:request 
                                     managedObjectContext:self.document.managedObjectContext 
                                     sectionNameKeyPath:nil cacheName:nil];
    self.navigationItem.title = @"Tags";
}

-(void) setDocument:(UIManagedDocument *)document
{
    _document = document;
    [self filterTags:nil];
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
    self.searchBar.delegate = self;

}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self popViewControllerIfNecessary];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [tag.photosCount longValue]  == 1 
        ? @"1 photo" 
        : [NSString stringWithFormat:@"%@ photos", tag.photosCount];
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setRequest:inManagedObjectContext:)]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        Tag* tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"any tags = %@", tag];
        [segue.destinationViewController setRequest:request inManagedObjectContext:self.document.managedObjectContext];
        [segue.destinationViewController setTitle:tag.name];
    }
}

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // NEVER GET CALLED!!!
    if (viewController == self) {
        [self popViewControllerIfNecessary];
    }
}

# pragma mark - UISearchBarDelegate methods

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTags:searchText];
}

@end
