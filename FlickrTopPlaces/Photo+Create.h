//
//  Photo+Create.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/13/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

@property (readonly) NSDictionary* infoDict;

+(Photo *) storedPhotoWithUnique:(NSString*) unique
         inManagedObjectContext:(NSManagedObjectContext *)context;

+(Photo *) photoWithFlickrData:(NSDictionary *)flickrData
        inManagedObjectContext:(NSManagedObjectContext *)context;
@end
