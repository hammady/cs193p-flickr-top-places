//
//  Place+Create.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/14/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcherHelper.h"

@implementation Place (Create)

-(NSUInteger) photosCount
{
    return self.photos.count;
}

+(Place *) storedPlaceWithUnique:(NSString *)unique inManagedObjectContext:(NSManagedObjectContext *)context
{
    // returns Place object only if it exists in the database, else return nil
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    return [[context executeFetchRequest:request error:nil] lastObject];
}

+(Place *) placeWithFlickrData:(NSDictionary *)infoDict inManagedObjectContext:(NSManagedObjectContext *)context
{
    // see if a Place for that Flickr data is already in the database
    Place *place = [self storedPlaceWithUnique:[infoDict objectForKey:PLACE_DICT_PLACEID]
                        inManagedObjectContext:context];
    if (!place) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:context];
        place.name = [infoDict objectForKey:PLACE_DICT_NAME];
        place.unique = [infoDict objectForKey:PLACE_DICT_PLACEID];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        place.latitude = [formatter numberFromString:[infoDict objectForKey:PLACE_DICT_LAT]];
        place.longitude = [formatter numberFromString:[infoDict objectForKey:PLACE_DICT_LNG]];
        place.firstVisitedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    return place;
}
@end
