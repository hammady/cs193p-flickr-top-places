//
//  FlickrFetcherHelper.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/21/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrFetcherHelper.h"

@implementation FlickrFetcherHelper

+(NSString*) cityNameForPlaceWithName:(NSString*) name
{
    NSRange commaRange = [name rangeOfString:@", "];
    return [name substringToIndex:commaRange.location];
}

+(NSString*) restOfPlaceNameForPlaceWithName:(NSString*) name
{
    NSRange commaRange = [name rangeOfString:@", "];
    return [name substringFromIndex:commaRange.location + commaRange.length];
}

+(NSArray*) photoTitleAndDescriptionForPhoto:(NSDictionary *)photo
{
    NSString* title = [photo objectForKey:PHOTO_DICT_TITLE];
    NSString* descr = [photo valueForKeyPath:PHOTO_DICT_DESCR_PATH];
    if ([title isEqualToString:@""])
        title = descr;
    if ([title isEqualToString:@""])
        title = @"Unknown";
    
    return [NSArray arrayWithObjects:title, descr, nil];
}
@end
