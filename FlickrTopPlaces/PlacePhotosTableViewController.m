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
    
    __block NSMutableArray* photos;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *barePhotos = [FlickrFetcherHelper photosAtPlace:[self.place objectForKey:PLACE_DICT_PLACEID]];
        // attach place dict to each photo (needed later in saving photo in db)
        // also remove tags with : in them
        photos = [NSMutableArray arrayWithCapacity:barePhotos.count];
        for (NSDictionary* photo in barePhotos) {
            NSMutableDictionary *photoDict = [photo mutableCopy];
            [photoDict setObject:self.place forKey:PHOTO_DICT_PLACE];
            
            NSString* tags = [photo objectForKey:PHOTO_DICT_TAGS];
            NSArray *tagArray = [tags componentsSeparatedByString:@" "];
            NSMutableArray *newTagArray = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@":"];
            for (NSString* tagName in tagArray) {
                if ([tagName rangeOfCharacterFromSet:set].location == NSNotFound) {
                    [newTagArray addObject:tagName];
                }
            }
            [photoDict setObject:newTagArray forKey:PHOTO_DICT_TAGS];

            [photos addObject:photoDict];
        }
        NSLog(@"Photos with places: %@", photos);
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
