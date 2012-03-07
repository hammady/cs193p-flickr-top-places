//
//  FlickrMapViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol FlickrMapViewControllerDelegate <NSObject>
-(NSString*) flickrMapViewControllerSegueIdForAnnotationDict:(NSDictionary*) dict;
-(void) flickrMapViewControllerPrepareForSegue:(UIStoryboardSegue *)segue withDict:(NSDictionary*) dict;
-(BOOL) flickrMapViewControllerAnnotationHasThumbnail;
@optional
-(UIImage*) flickrMapViewControllerThumbnailWithInfo:(NSDictionary*) info;
@end

@interface FlickrMapViewController : UIViewController <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
// the model is an array of id <MKAnnotation>
@property (strong, nonatomic) NSArray* annotations;
@property (weak, nonatomic) id <FlickrMapViewControllerDelegate> delegate;
@end
