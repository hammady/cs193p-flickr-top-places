//
//  ImageListTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/24/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "ImageListTableViewController.h"
#import "FlickrFetcherHelper.h"
#import "FlickrImageViewController.h"
#import "FlickrPhotoMKAnnotation.h"
#import "FlickrMapViewController.h"
#import "FlickrImage.h"

@interface ImageListTableViewController() <FlickrMapViewControllerDelegate>
@end

@implementation ImageListTableViewController

@synthesize imageList = _imageList;
@synthesize reversedList = _reversedList;
//@synthesize delegate = _delegate;

#pragma mark - setters/getters

-(NSArray*) mapAnnotations
{
    NSMutableArray* annotations = [[NSMutableArray alloc] 
                                   initWithCapacity:self.imageList.count];
    for (NSDictionary* imageDict in self.imageList) {
        NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:imageDict];
        NSString* title = [titleAndDescr objectAtIndex:0];
        NSString* subtitle = [titleAndDescr lastObject];
        CLLocationCoordinate2D coord;
        coord.latitude = [[imageDict objectForKey:PHOTO_DICT_LAT] doubleValue];
        coord.longitude = [[imageDict objectForKey:PHOTO_DICT_LNG] doubleValue];
        FlickrPhotoMKAnnotation *annotation = [FlickrPhotoMKAnnotation 
                                               flickrPhotoMKAnnotationWithTitle:title
                                               subtitle:subtitle
                                               coord:coord];
        annotation.infoDict = imageDict;
        [annotations addObject:annotation];
    }
    return annotations;
}

-(void) refreshMapWithAnnotations:(NSArray*) annotations
{
    FlickrMapViewController *mapVC = [self mapViewControllerForSplitViewController:self.splitViewController];
    mapVC.delegate = self;
    mapVC.annotations = annotations;
}

-(void) setImageList:(NSArray *)imageList
{
    if (_imageList != imageList) {
        _imageList = imageList;
        if (self.view.window) [self.tableView reloadData];
        [self refreshMapWithAnnotations:self.mapAnnotations];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void) viewDidAppear:(BOOL)animated
{
    [self refreshMapWithAnnotations:self.mapAnnotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Image summary cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    if (self.reversedList) row = self.imageList.count - row - 1;
    
    NSDictionary* photo = [self.imageList objectAtIndex:row];
    NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:photo];
    
    cell.textLabel.text = [titleAndDescr objectAtIndex:0];
    cell.detailTextLabel.text = [titleAndDescr objectAtIndex:1];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        NSInteger row = indexPath.row;
        if (self.reversedList) row = self.imageList.count - row - 1;
        NSDictionary* photo = [self.imageList objectAtIndex:row];

        UIViewController* vc = [self topVisibleViewController:self.splitViewController];
        
        if ([vc isKindOfClass:[FlickrMapViewController class]]) {        
            [vc performSegueWithIdentifier:@"Image view segue from map" sender:photo];
        }
        else if ([vc isKindOfClass:[FlickrImageViewController class]]) {
            [(FlickrImageViewController*) vc reloadImageWithInfo:photo];
            // TODO RECENTS INSIDE RELOADIMAGE
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Image view segue"]
         || [segue.identifier isEqualToString:@"Image view segue from recents"]
        || [segue.identifier isEqualToString:@"Image view segue from map"]) {
        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        if (self.reversedList) row = self.imageList.count - row -1;
        NSDictionary* photo = [self.imageList 
                               objectAtIndex:row];
        [segue.destinationViewController reloadImageWithInfo:photo];
    } else if ([segue.identifier isEqualToString:@"Show Map"]) {
        // prepare annotations
        NSArray* annotations = self.mapAnnotations;
        [segue.destinationViewController setAnnotations:annotations];
        [segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - FlickrMapViewControllerDelegate methods

-(NSString*) flickrMapViewControllerSegueIdForAnnotationDict:(NSDictionary*) dict
{
    return @"Image view segue from map";
}

-(void) flickrMapViewControllerPrepareForSegue:(UIStoryboardSegue *)segue withDict:(NSDictionary *)dict
{
    if ([segue.identifier isEqualToString:@"Image view segue from map"]) {
        [segue.destinationViewController reloadImageWithInfo:dict];
    }
}

-(BOOL) flickrMapViewControllerAnnotationHasThumbnail
{
    return YES;
}

-(UIImage*) flickrMapViewControllerThumbnailWithInfo:(NSDictionary *)info
{
    return [FlickrImage imageWithInfo:info
                                format:FlickrFetcherPhotoFormatSquare];
}

@end
