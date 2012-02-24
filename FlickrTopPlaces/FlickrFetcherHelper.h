//
//  FlickrFetcherHelper.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/21/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrFetcher.h"

#define PLACE_DICT_NAME @"_content"
#define PLACE_DICT_PLACEID @"place_id"

#define PHOTO_DICT_TITLE @"title"
#define PHOTO_DICT_DESCR_PATH @"description._content"

#define COUNTRIES_DICT_COUNTRYNAME @"CountryName"
#define COUNTRIES_DICT_PLACES @"Places"

@interface FlickrFetcherHelper : FlickrFetcher

+(NSString*) cityNameForPlaceWithName:(NSString*) name;
+(NSString*) countryNameForPlaceWithName:(NSString*) name;
+(NSString*) restOfPlaceNameForPlaceWithName:(NSString*) name;
+(NSArray*) photoTitleAndDescriptionForPhoto:(NSDictionary*) photo; 
+(NSArray*) topPlacesPerCountry;

@end
