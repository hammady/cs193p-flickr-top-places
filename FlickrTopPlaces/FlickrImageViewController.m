//
//  ImageViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrImageViewController.h"
#import "FlickrFetcherHelper.h"
#import "FlickrImage.h"
#import "RecentPhotos.h"

@interface FlickrImageViewController()  <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSDictionary* imageInfo;
-(void) recalculateMinAndMaxZoomScale;
-(void) displayWholeImage;
@end

@implementation FlickrImageViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize imageInfo = _imageInfo;

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

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
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self recalculateMinAndMaxZoomScale];
    //[self displayWholeImage];
    // because min/max zoom scales have changed, we might be in a state where
    // the zoom scale is lower than min or larger than max, fix this
    if (self.scrollView.zoomScale < self.scrollView.minimumZoomScale)
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    else if (self.scrollView.zoomScale > self.scrollView.maximumZoomScale)
        self.scrollView.zoomScale = self.scrollView.maximumZoomScale;
}

-(void) recalculateMinAndMaxZoomScale
{
    // calculate min and max zoom scale
    CGFloat xPixels, yPixels, xMinZoom, yMinZoom, xMaxZoom, yMaxZoom;
    // we multiply by contentScaleFactor to get pixels rather than points (retina)
    xPixels = self.scrollView.bounds.size.width * self.scrollView.contentScaleFactor;
    yPixels = self.scrollView.bounds.size.height * self.scrollView.contentScaleFactor;
    xMinZoom = xPixels / self.imageView.image.size.width;
    yMinZoom = yPixels / self.imageView.image.size.height;
    xMaxZoom = 1 / xMinZoom;
    yMaxZoom = 1 / yMinZoom;
    self.scrollView.minimumZoomScale = MIN(xMinZoom, yMinZoom);
    self.scrollView.maximumZoomScale = MAX(xMaxZoom, yMaxZoom);
}

-(void) displayWholeImage
{
    // we can display the whole image by either zoomin to minZoom
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    // or by zooming to the whole image rect
    //[self.scrollView zoomToRect:self.imageView.frame animated:NO];
    self.scrollView.contentOffset = CGPointZero;
}

-(void) reloadImageWithInfo:(NSDictionary *)info
{
    // store info as instance variable to compare it afterwards with the parameter
    self.imageInfo = info;
    [RecentPhotos appendPhoto:info];

    self.imageView.image = nil;
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:info];
    
    self.navigationItem.title = [titleAndDescr objectAtIndex:0];
    
    dispatch_queue_t photosQueue = dispatch_queue_create("Flickr photos fetcher", NULL);
    dispatch_async(photosQueue, ^{
        
        __block UIImage* image = 
        [FlickrImage imageWithInfo:info
                            format:FlickrFetcherPhotoFormatLarge
         useCache:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            
            /* we compare instance variable self.imageInfo (which might have
             been changed by a later call to reloadImageWithInfo) with the local
             variable info which is now const to make sure we are indeed
             displaying the same image that was originally requested.
             This is not useful in iPhone because each time an image is requested
             A segue happens and a new instance of this VC is created so there
             is no interference between imageViews. However in iPad where no 
             segue happens, but image is replaced, this is essentially useful
             */
            if (self.imageInfo == info) {
                //NSLog(@"Back from flickr with title %@", [info objectForKey:PHOTO_DICT_TITLE]);
                
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                self.scrollView.contentSize = image.size;
                
                [self recalculateMinAndMaxZoomScale];
                [self displayWholeImage];
            }
        });
    });
    dispatch_release(photosQueue);    
}

#pragma makr UIScrollViewDelegate methods

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
