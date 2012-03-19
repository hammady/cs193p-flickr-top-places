//
//  Place+Create.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/14/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

@property (readonly) NSUInteger photosCount;

+(Place *) storedPlaceWithUnique:(NSString *)unique inManagedObjectContext:(NSManagedObjectContext *)context;

+(Place *) placeWithFlickrData:(NSDictionary *)infoDict
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
