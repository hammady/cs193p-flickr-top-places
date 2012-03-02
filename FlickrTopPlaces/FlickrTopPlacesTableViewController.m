//
//  FlickrTopPlacesTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/21/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrTopPlacesTableViewController.h"
#import "FlickrFetcherHelper.h"
#import "PlacePhotosTableViewController.h"
#import "FlickrPhotoMKAnnotation.h"
#import "FlickrMapViewController.h"

@interface FlickrTopPlacesTableViewController()
@property (nonatomic, strong) NSArray* countries;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)refresh:(id)sender;
@end

@implementation FlickrTopPlacesTableViewController
@synthesize countries = _countries;
@synthesize refreshButton = _refreshButton;

-(void) setCountries:(NSArray *)countries
{
    if (_countries != countries) {
        _countries = countries;
        if (self.view.window) [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self refresh:self.refreshButton];
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.countries.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary* country = [self.countries objectAtIndex:section];
    return [country objectForKey:COUNTRIES_DICT_COUNTRYNAME];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary* country = [self.countries objectAtIndex:section];
    NSArray* places = [country objectForKey:COUNTRIES_DICT_PLACES];
    return places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Place Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* country = [self.countries objectAtIndex:indexPath.section];
    NSArray* places = [country objectForKey:COUNTRIES_DICT_PLACES];

    NSDictionary* place = [places objectAtIndex:indexPath.row];
    NSString* placeName = [place objectForKey:PLACE_DICT_NAME];
    cell.textLabel.text = [FlickrFetcherHelper cityNameForPlaceWithName:placeName];
    cell.detailTextLabel.text =[FlickrFetcherHelper restOfPlaceNameForPlaceWithName:placeName];
    
    return cell;
}

#pragma mark action/targets

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    __block NSArray* remotePlaces;
    dispatch_queue_t fetcher_thread = dispatch_queue_create("Flickr downloader", NULL);
    dispatch_async(fetcher_thread, ^{
        remotePlaces = [FlickrFetcherHelper topPlacesPerCountry];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem = sender;
            self.countries = remotePlaces;
        });
    });
    dispatch_release(fetcher_thread);
    //NSLog(@"Top Places => %@", self.places);
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Image list segue"]) {
        NSIndexPath* indexPath = self.tableView.indexPathForSelectedRow;
        NSDictionary* country = [self.countries objectAtIndex:indexPath.section];
        NSArray* places = [country objectForKey:COUNTRIES_DICT_PLACES];
        NSDictionary* place = [places objectAtIndex:indexPath.row];
        [segue.destinationViewController setPlace:place];
    } else if ([segue.identifier isEqualToString:@"Show Map"]) {
        // prepare annotations
        NSMutableArray* annotations = [[NSMutableArray alloc] initWithCapacity:50];
        for (NSDictionary* countryDict in self.countries) {
            NSString* countryName = [countryDict objectForKey:COUNTRIES_DICT_COUNTRYNAME];
            NSArray* countryPlaces = [countryDict objectForKey:COUNTRIES_DICT_PLACES];
            for (NSDictionary* placeDict in countryPlaces) {
                NSString* placeName = [placeDict objectForKey:PLACE_DICT_NAME];
                NSString* title = [[FlickrFetcherHelper cityNameForPlaceWithName:placeName] 
                                   stringByAppendingFormat:@", %@", countryName];
                NSString* subtitle = [FlickrFetcherHelper restOfPlaceNameForPlaceWithName:placeName];
                CLLocationCoordinate2D coord;
                coord.latitude = [[placeDict objectForKey:PLACE_DICT_LAT] doubleValue];
                coord.longitude = [[placeDict objectForKey:PLACE_DICT_LNG] doubleValue];
                [annotations addObject:[FlickrPhotoMKAnnotation 
                                        flickrPhotoMKAnnotationWithTitle:title
                                        subtitle:subtitle
                                        coord:coord]];
            }
        }
        [segue.destinationViewController setAnnotations:annotations];
    }
}

@end
