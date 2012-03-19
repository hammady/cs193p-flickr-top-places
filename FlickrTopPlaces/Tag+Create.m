//
//  Tag+Create.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/14/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+(Tag *) storedTagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    // returns Tag object only if it exists in the database, else return nil
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name like[c] %@", name];
    return [[context executeFetchRequest:request error:nil] lastObject];
}

+(Tag *) tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (name.length == 0) return nil;
    
    // see if a Tag with name is already in the database
    Tag *tag = [self storedTagWithName:name inManagedObjectContext:context];
    if (!tag) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                              inManagedObjectContext:context];
        tag.name = [name capitalizedString];
    }
    return tag;
}

@end
