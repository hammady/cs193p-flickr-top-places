//
//  ImageViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrImageViewController.h"
#import "FlickrFetcherHelper.h"

@interface FlickrImageViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FlickrImageViewController
@synthesize imageView;
@synthesize scrollView;

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) reloadImageWithInfo:(NSDictionary *)info
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:info];
    
    self.navigationItem.title = [titleAndDescr objectAtIndex:0];
    
    __block NSData* imageData;
    dispatch_queue_t photosQueue = dispatch_queue_create("Flickr photos fetcher", NULL);
    dispatch_async(photosQueue, ^{
        imageData = [FlickrFetcherHelper 
                             imageDataForPhotoWithFlickrInfo:info 
                             format:FlickrFetcherPhotoFormatLarge];
        NSLog(@"Image data length returned: %x", imageData.length);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            self.imageView.image = image;
            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            self.scrollView.contentSize = image.size;
        });
    });
    dispatch_release(photosQueue);    
}

@end
