//
//  FlickrMapViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrMapViewController.h"

@implementation FlickrMapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;

#pragma mark setters/getters

-(void) updateMapWithAnnotations:(NSArray*) annotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
}

-(void) setAnnotations:(NSArray *)annotations
{
    if (_annotations == annotations) return;
    _annotations = annotations;
    [self updateMapWithAnnotations:annotations];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
