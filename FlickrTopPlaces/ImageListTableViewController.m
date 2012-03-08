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
@property (nonatomic) dispatch_queue_t thumbnailsQueue;
@property (nonatomic, strong) UIImage *thumbnailPlaceholder;
@end

@implementation ImageListTableViewController

@synthesize imageList = _imageList;
@synthesize reversedList = _reversedList;
@synthesize thumbnailsQueue = _thumbnailsQueue;
@synthesize thumbnailPlaceholder = _thumbnailPlaceholder;

//@synthesize delegate = _delegate;

#pragma mark - setters/getters

-(UIImage*) thumbnailPlaceholder
{
    if (!_thumbnailPlaceholder)
        _thumbnailPlaceholder = [UIImage imageNamed:@"thumbnail_placeholder.png"];
    return _thumbnailPlaceholder;
}

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

-(void) viewWillAppear:(BOOL)animated
{
    self.thumbnailsQueue  = dispatch_queue_create("Flickr thumbnails fetcher", NULL);    
}

-(void) viewDidAppear:(BOOL)animated
{
    [self refreshMapWithAnnotations:self.mapAnnotations];
}

-(void) viewWillDisappear:(BOOL)animated
{
    dispatch_release(self.thumbnailsQueue);            
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
    cell.imageView.image = self.thumbnailPlaceholder;
    
    // point to cell text to compare it afterwards as it may change by reusing
    NSString* originalTitle = cell.textLabel.text;
    
    // load thumbnail
    //dispatch_queue_t thumbnailQueue = dispatch_queue_create("Flickr thumbnail fetcher", NULL);
    dispatch_async(self.thumbnailsQueue, ^{
        
        UIImage* image = [FlickrImage imageWithInfo:photo format:FlickrFetcherPhotoFormatSquare useCache:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // make sure we are modifying the imageView in the row that originally
            // appeared as cells are reused, we do this by comparing
            // the local originalTitle which is basically copied on stack
            // to be used by this block, the fresh cell title is checked
            // by inspecting the attached one to the cell textLabel which changes
            // only in this enclosing method
            
            if ([cell.textLabel.text isEqualToString:originalTitle]) {
                cell.imageView.image = image;
            }
            //cell.textLabel.text = @"back";
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"width: %f, height: %f", image.size.width, image.size.height];
        });
    });
    //dispatch_release(thumbnailQueue);            

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
                                format:FlickrFetcherPhotoFormatSquare 
                             useCache:YES];
}

@end
