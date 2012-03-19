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
#import "Photo+Create.h"

@interface FlickrImageViewController()  <UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property (strong, nonatomic) NSDictionary* imageInfo;
@property (weak, nonatomic) IBOutlet UILabel *tagListLabel;
@property (strong, nonatomic) UIActionSheet* actionSheet;
-(void) recalculateMinAndMaxZoomScale;
-(void) displayWholeImage;
-(void) unvisitPhoto;
@end

@implementation FlickrImageViewController
@synthesize visitButton = _visitButton;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize imageInfo = _imageInfo;
@synthesize tagListLabel = _tagListLabel;
@synthesize documentContext = _documentContext;
@synthesize actionSheet = _actionSheet;

#pragma mark - setters/getters
-(void) setDocumentContext:(NSManagedObjectContext *)documentContext
{
    _documentContext = documentContext;

    if (documentContext) {
        self.visitButton.title = @"Unvisit";
    }
    else {
        self.visitButton.title = @"Visit";
    }

}

-(UIActionSheet* )actionSheet
{
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Not yet" destructiveButtonTitle:@"Unvisit" otherButtonTitles:nil];
    }
    return _actionSheet;
}

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
    [self setVisitButton:nil];
    [self setTagListLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray* tagArray = [self.imageInfo objectForKey:PHOTO_DICT_TAGS];
    self.tagListLabel.text = [tagArray componentsJoinedByString:@" | "];

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
    self.tagListLabel.text = @"";   // in prepareForSegue outlets r not ready yet!

    // clear any document context and consequently change visit/unvisit button title
    self.documentContext = nil;
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    UIBarButtonItem *originalButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:info];
    
    self.navigationItem.title = [titleAndDescr objectAtIndex:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        UIImage* image = 
        [FlickrImage imageWithInfo:info
                            format:FlickrFetcherPhotoFormatLarge
         useCache:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = originalButton;
            
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
}

#pragma mark - UIScrollViewDelegate methods

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - actions

- (IBAction)visitButtonPressed:(id)sender
{
    if (self.documentContext) {
        // unvisiting
        [self.actionSheet showInView:self.view];
    } else {
        // visiting
        [self performSegueWithIdentifier:@"Select vacation" sender:self];
    }
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select vacation"]) {
        VacationsTableViewController *vc = segue.destinationViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*) vc;
            vc = (VacationsTableViewController*) nvc.topViewController;
        }
        vc.delegate = self;
    }
}

-(void) unvisitPhoto
{
    Photo *photo = [Photo photoWithFlickrData:self.imageInfo inManagedObjectContext:self.documentContext];
    [self.documentContext deleteObject:photo];
    self.documentContext = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - VacationsTableViewControllerModalDelegate methods

-(void) vacationsTVCSelectedVacationDocument:(UIManagedDocument *)document
{
    // visit this image in this document
    self.documentContext = document.managedObjectContext;
    [Photo photoWithFlickrData:self.imageInfo inManagedObjectContext:document.managedObjectContext];
    //[document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        [self dismissModalViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    //}];
}

#pragma mark - UIActionSheetDelegate methods

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
        [self unvisitPhoto];
}
@end
