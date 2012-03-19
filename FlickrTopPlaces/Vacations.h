//
//  Vacations.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^completion_block_t)(UIManagedDocument *document);

@interface Vacations : NSObject

+(NSArray*) listVacations;
+(void) addVacationWithName:(NSString*) name usingBlock:(completion_block_t) completionHandler;
+(void) documentForVacationWithName:(NSString*) name 
    usingBlock:(completion_block_t) completionHandler;
@end
