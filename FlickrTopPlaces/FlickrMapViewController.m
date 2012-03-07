//
//  FlickrMapViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrMapViewController.h"
#import "FlickrPhotoMKAnnotation.h"
#import "FlickrImage.h"

#define MAP_REGION_MARGIN   .002

@interface FlickrMapViewController() <MKMapViewDelegate>
@end

@implementation FlickrMapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;

#pragma mark utility methods

-(void) updateMapWithAnnotations:(NSArray*) annotations
{
    // skip this expensive function if mapView is not ready yet
    if (!self.mapView || !annotations || !annotations.count) return;
    
    // attach annotations
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
    // zoom/pan map to a proper size
    // first find min/max lat/lng
    CLLocationDegrees minLat = 90, minLng = 180, maxLat = -90, maxLng = -180;
    for (id <MKAnnotation> annotation in annotations) {
        CLLocationCoordinate2D coord = [annotation coordinate];
        if (coord.latitude <= minLat)
            minLat = coord.latitude;
        if (coord.latitude >= maxLat)
            maxLat = coord.latitude;
        if (coord.longitude <= minLng)
            minLng = coord.longitude;
        if (coord.longitude >= maxLng)
            maxLng = coord.longitude;
    }
    CLLocationDegrees deltaLat = (maxLat - minLat), deltaLng = (maxLng - minLng);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(minLat+deltaLat/2, minLng+deltaLng/2);
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat + MAP_REGION_MARGIN, deltaLng + MAP_REGION_MARGIN);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

    [self.mapView setRegion:region animated:YES];
}

#pragma mark setters/getters

-(void) setAnnotations:(NSArray *)annotations
{
    if (_annotations == annotations) return;
    _annotations = annotations;
    /* if this is called while the view is not loaded yet (from prepareForSegue)
     the outlets won't be ready yet, so manipulating self.mapView will do nothing,
     so we should update annotations in viewDidLoad */
    [self updateMapWithAnnotations:annotations];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.splitViewController.delegate = self;
    // attach annotations to mapView
    [self updateMapWithAnnotations:self.annotations];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - MKMapViewDelegate methods

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ann"];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:@"ann"];
        view.canShowCallout = YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        view.rightCalloutAccessoryView = button;
    }
    // build accessories here for the callout (but don't load thumbnail yet)
    // creating thumbnail accessory is not redundant because same MapView
    // is reused between different delegates, some of them could have thumbnail
    // and some not, so we make sure thumbnail is set accordingly
    if ([self.delegate flickrMapViewControllerAnnotationHasThumbnail]) {
        view.leftCalloutAccessoryView = [[UIImageView alloc] 
                                         initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    else
        view.leftCalloutAccessoryView = nil;
    view.annotation = annotation;
    return view;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // load the thumbnail here in a separate thread, set to nil initially
    UIImageView *thumbnailView = (UIImageView*) view.leftCalloutAccessoryView;
    if (thumbnailView) {
        thumbnailView.image = nil;
        
        dispatch_queue_t photosQueue = dispatch_queue_create("Flickr photos fetcher", NULL);
        dispatch_async(photosQueue, ^{
            
            FlickrPhotoMKAnnotation* photoAnnotation = (FlickrPhotoMKAnnotation*) view.annotation;
            __block UIImage* image = [self.delegate flickrMapViewControllerThumbnailWithInfo:photoAnnotation.infoDict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // make sure we are modifying the imageView that originally
                // appeared as imageViews are reused, we do this by comparing
                // the local photoAnnotation which is basically copied on stack
                // to be used by this block, the fresh annotation is checked
                // by inspecting the attached one to the view which changes
                // only in mapView:viewForAnnotation
                if (thumbnailView.window && view.annotation == photoAnnotation)
                    thumbnailView.image = image;
            });
        });
        dispatch_release(photosQueue);            
    }
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view 
calloutAccessoryControlTapped:(UIControl *)control
{
    if ([control isKindOfClass:[UIButton class]]) {
        FlickrPhotoMKAnnotation* photoAnnotation = (FlickrPhotoMKAnnotation*) view.annotation;
        NSString* segueId = [self.delegate flickrMapViewControllerSegueIdForAnnotationDict:photoAnnotation.infoDict];
        if (segueId) {
            [self performSegueWithIdentifier:segueId sender:photoAnnotation.infoDict];
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.delegate flickrMapViewControllerPrepareForSegue:segue withDict:sender];
}

#pragma mark - UISplitViewControllerDelegate methods

-(BOOL) splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
