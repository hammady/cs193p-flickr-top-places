//
//  FlickrImageListViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "PlacePhotosTableViewController.h"
#import "FlickrFetcherHelper.h"

@implementation PlacePhotosTableViewController

@synthesize place = _place;
//@synthesize delegate = _delegate;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    UIBarButtonItem* originalRightButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    self.navigationItem.title = [FlickrFetcherHelper cityNameForPlaceWithName:[self.place objectForKey:PLACE_DICT_NAME]];
    
    __block NSArray* photos;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        photos = [FlickrFetcherHelper photosAtPlace:[self.place objectForKey:PLACE_DICT_PLACEID]];
        //NSLog(@"Photos returned: %@", photos);
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = originalRightButton;
            self.imageList = photos;
        });
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
