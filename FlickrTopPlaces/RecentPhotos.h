//
//  RecentPhotos.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject
+(NSArray*) retrieveList;
+(void) appendPhoto:(NSDictionary*) photo;
@end
