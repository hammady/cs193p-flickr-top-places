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
#define PLACE_DICT_LAT @"latitude"
#define PLACE_DICT_LNG @"longitude"

#define PHOTO_DICT_TITLE @"title"
#define PHOTO_DICT_DESCR_PATH @"description._content"
#define PHOTO_DICT_ID   @"id"
#define PHOTO_DICT_LAT @"latitude"
#define PHOTO_DICT_LNG @"longitude"
#define PHOTO_DICT_TAGS @"tags"
#define PHOTO_DICT_PLACE  @"place"

#define COUNTRIES_DICT_COUNTRYNAME @"CountryName"
#define COUNTRIES_DICT_PLACES @"Places"

@interface FlickrFetcherHelper : FlickrFetcher

+(NSString*) cityNameForPlaceWithName:(NSString*) name;
+(NSString*) countryNameForPlaceWithName:(NSString*) name;
+(NSString*) restOfPlaceNameForPlaceWithName:(NSString*) name;
+(NSString*) restOfPlaceNameAndCountryForPlaceWithName:(NSString*) name;
+(NSArray*) photoTitleAndDescriptionForPhoto:(NSDictionary*) photo; 
+(NSArray*) topPlacesPerCountry;

@end
