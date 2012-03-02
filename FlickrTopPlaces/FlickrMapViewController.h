//
//  FlickrMapViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FlickrMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
// the model is an array of id <MKAnnotation>
@property (strong, nonatomic) NSArray* annotations;
@end
