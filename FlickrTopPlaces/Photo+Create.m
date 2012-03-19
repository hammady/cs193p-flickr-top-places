//
//  Photo+Create.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/13/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Photo+Create.h"
#import "FlickrFetcherHelper.h"
#import "Tag+Create.h"
#import "Place+Create.h"

@implementation Photo (Create)

-(NSDictionary*) infoDict
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.flickrInfo];
}

+(Photo *) storedPhotoWithUnique:(NSString *)unique inManagedObjectContext:(NSManagedObjectContext *)context
{
    // returns Photo object only if it exists in the database, else return nil
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    return [[context executeFetchRequest:request error:nil] lastObject];
}

+(Photo *) photoWithFlickrData:(NSDictionary *)infoDict
        inManagedObjectContext:(NSManagedObjectContext *)context

{
    // see if a Photo for that Flickr data is already in the database
    Photo *photo = [self storedPhotoWithUnique:[infoDict objectForKey:PHOTO_DICT_ID]
                        inManagedObjectContext:context];
    if (!photo) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                          inManagedObjectContext:context];
        // initialize the photo from the Flickr data
        // perhaps even create other database objects (like the Photographer)
        
        NSArray* titleAndDescr = [FlickrFetcherHelper photoTitleAndDescriptionForPhoto:infoDict];
        
        photo.unique = [infoDict objectForKey:PHOTO_DICT_ID];
        photo.title = [titleAndDescr objectAtIndex:0];
        photo.subTitle = [titleAndDescr lastObject];
        photo.latitude = [infoDict objectForKey:PHOTO_DICT_LAT];
        photo.longitude = [infoDict objectForKey:PHOTO_DICT_LNG];
        
        photo.flickrInfo = [NSKeyedArchiver archivedDataWithRootObject:infoDict];
                
        NSArray *tagArray = [infoDict objectForKey:PHOTO_DICT_TAGS];
        for (NSString* tagName in tagArray) {
            if (tagName.length > 0) {
                Tag *tag = [Tag tagWithName:tagName inManagedObjectContext:context];
                [tag addPhotosObject:photo];
                tag.photosCount = [NSNumber numberWithLong:tag.photos.count];
            }
        }
        
        photo.takenAtPlace = [Place placeWithFlickrData:[infoDict objectForKey:PHOTO_DICT_PLACE] 
                                 inManagedObjectContext:context];
    }
    return photo;    
}


-(void) prepareForDeletion
{
    for (Tag *tag in self.tags) {
        tag.photosCount = [NSNumber numberWithLong:[tag.photosCount longValue] - 1];
        if ([tag.photosCount longValue] == 0)
            [self.managedObjectContext deleteObject:tag];
    }
    
    if (self.takenAtPlace.photos.count == 1) // last photo
        [self.managedObjectContext deleteObject:self.takenAtPlace];
}

@end
