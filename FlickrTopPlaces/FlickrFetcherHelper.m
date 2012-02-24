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
    NSArray* comp = [name componentsSeparatedByString:@", "];
    return [comp objectAtIndex:0];
}

+(NSString*) countryNameForPlaceWithName:(NSString *)name
{
    NSArray* comp = [name componentsSeparatedByString:@", "];
    return [comp lastObject];
}

+(NSString*) restOfPlaceNameForPlaceWithName:(NSString*) name
{
    NSArray* comp = [name componentsSeparatedByString:@", "];
    NSMutableArray* mutableComp = [comp mutableCopy];
    [mutableComp removeObjectAtIndex:0];    // city name
    [mutableComp removeLastObject];         // country name
    return [mutableComp componentsJoinedByString:@", "];
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

+(NSArray*) topPlacesPerCountry
{
    NSMutableDictionary* countriesDict = [[NSMutableDictionary alloc] init];
    
    NSArray* topPlaces = [self topPlaces];
    
    // categorize places into countries
    NSString *placeName, *countryName;
    NSMutableDictionary* oneCountryDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* countryPlaces;
    for (NSDictionary* place in topPlaces) {
        placeName = [place objectForKey:PLACE_DICT_NAME];
        countryName = [self countryNameForPlaceWithName:placeName];
        oneCountryDict = [countriesDict objectForKey:countryName];
        
        if (!oneCountryDict) {
            oneCountryDict = [[NSMutableDictionary alloc] init];
            [oneCountryDict setObject:countryName forKey:COUNTRIES_DICT_COUNTRYNAME];
            countryPlaces = [[NSMutableArray alloc] init];
            [oneCountryDict setObject:countryPlaces forKey:COUNTRIES_DICT_PLACES];
            [countriesDict setObject:oneCountryDict forKey:countryName];
        }
        else
            countryPlaces = [oneCountryDict objectForKey:COUNTRIES_DICT_PLACES];
        
        [countryPlaces addObject:place];        
    }
    
    // convert countries dictionary into countries array
    NSMutableArray* countriesArray = [[NSMutableArray alloc] initWithCapacity:countriesDict.count];
    [countriesDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [countriesArray addObject:value];
    }];
    // sort countries array by country name
    [countriesArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* name1 = [(NSDictionary*) obj1 objectForKey:COUNTRIES_DICT_COUNTRYNAME];
        NSString* name2 = [(NSDictionary*) obj2 objectForKey:COUNTRIES_DICT_COUNTRYNAME];
        return [name1 compare:name2];
    }];
    // sort places in each country dict (in the countries array) by place name
    for (NSDictionary* countryDict in countriesArray) {
        [[countryDict objectForKey:COUNTRIES_DICT_PLACES] sortUsingComparator:
        ^NSComparisonResult(id obj1, id obj2) {
            NSString* place1 = [(NSDictionary*) obj1 objectForKey:PLACE_DICT_NAME];
            NSString* place2 = [(NSDictionary*) obj2 objectForKey:PLACE_DICT_NAME];
            return [place1 compare:place2];
        }];
    }
    return countriesArray;
}

@end
