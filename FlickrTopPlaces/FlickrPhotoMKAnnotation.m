//
//  FlickrPhotoMKAnnotation.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/2/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrPhotoMKAnnotation.h"

@implementation FlickrPhotoMKAnnotation
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coord;

+(FlickrPhotoMKAnnotation*) flickrPhotoMKAnnotationWithTitle:(NSString *)title 
                                                    subtitle:(NSString *)subtitle 
                                                       coord:(CLLocationCoordinate2D)coord
{
    FlickrPhotoMKAnnotation* obj = [[FlickrPhotoMKAnnotation alloc] 
                                    init];
    obj.title = title;
    obj.subtitle = subtitle;
    obj.coordinate = coord;
    
    return obj;
}
@end
