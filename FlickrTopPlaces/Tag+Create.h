//
//  Tag+Create.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/14/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+(Tag *) storedTagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+(Tag *) tagWithName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
