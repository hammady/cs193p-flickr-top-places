//
//  RecentPhotos.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "RecentPhotos.h"
#define RECENTS_KEY  @"Recents"
#define RECENTS_MAX  20

@implementation RecentPhotos

/*+(void) setList:(NSOrderedSet *)list
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:list forKey:RECENTS_KEY];
    [defaults synchronize];
}*/

+(NSArray*) retrieveList
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* list = [defaults objectForKey:RECENTS_KEY];
    return list;
}

+(void) appendPhoto:(NSDictionary*) photo
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* originalList = [defaults objectForKey:RECENTS_KEY];
    if (!originalList) originalList = [NSArray array];
        
    NSMutableArray* newList = [originalList mutableCopy];
    
    // remove photo if it exists so that it gets appended at the end
    if ([newList containsObject:photo])
        [newList removeObject:photo];
    [newList addObject:photo];
    
    // delete oldest if exceeding max
    if (newList.count > RECENTS_MAX)
        [newList removeObjectAtIndex:0];
    
    [defaults setObject:newList forKey:RECENTS_KEY];
    [defaults synchronize];
}

@end
