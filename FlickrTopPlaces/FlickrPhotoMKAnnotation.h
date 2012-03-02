//
//  FlickrPhotoMKAnnotation.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FlickrPhotoMKAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

+(FlickrPhotoMKAnnotation*) flickrPhotoMKAnnotationWithTitle:(NSString*)title 
                                                    subtitle:(NSString*)subtitle
                                                       coord:(CLLocationCoordinate2D)coord;

@end
