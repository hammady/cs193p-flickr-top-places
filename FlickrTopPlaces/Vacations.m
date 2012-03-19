//
//  Vacations.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "Vacations.h"
#import "Place.h"
#import "Photo.h"
#import "Tag+Create.h"

#define VACATIONS_SUBDIR  @"vacations"

@interface Vacations()
+(void) createVacationsSubdir;
@end

@implementation Vacations

static NSString* _vacationsSubdir;
static NSMutableDictionary* _documents;

+(NSString*) vacationsSubdir
{
    if (_vacationsSubdir == nil) 
        _vacationsSubdir = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                     inDomains:NSUserDomainMask]
                          lastObject] path] stringByAppendingPathComponent:VACATIONS_SUBDIR];
    return _vacationsSubdir;
}

+(NSMutableDictionary*) documents
{
    if (!_documents)
        _documents = [[NSMutableDictionary alloc] init];
    return _documents;
}

+(void) createVacationsSubdir
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    [fileManager createDirectoryAtPath:[self vacationsSubdir] 
                  withIntermediateDirectories:NO attributes:nil error:nil];
}

+(NSArray*) listVacations
{    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* files = [fileManager contentsOfDirectoryAtPath:[self vacationsSubdir] error:nil];
    return files;
}

+(void) addVacationWithName:(NSString *)name usingBlock:(completion_block_t)completionHandler
{
    [self createVacationsSubdir];
    //NSString *filename = [[self vacationsSubdir] stringByAppendingPathComponent:name];
    //[@"test content" writeToFile:filename atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    [self documentForVacationWithName:name usingBlock:^(UIManagedDocument *document) {
        completionHandler(document);
    }];
}

+(void) documentForVacationWithName:(NSString *)name 
                                       usingBlock:(completion_block_t)completionHandler
{
    UIManagedDocument* document = [[self documents] objectForKey:name];
    if (document) {
        completionHandler(document);
        return;
    }
    
    NSString *urlString = [[self vacationsSubdir] stringByAppendingPathComponent:name];
    NSURL* documentURL = [NSURL fileURLWithPath:urlString];
    document = [[UIManagedDocument alloc] initWithFileURL:documentURL];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentURL.path]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [[self documents] setObject:document forKey:name];
                completionHandler(document);
            }
            else
                NSLog(@"Failed to open vacation document at path %@", documentURL.path);
        }];
    } else {
        [document saveToURL:documentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [[self documents] setObject:document forKey:name];
                // insert test data
                // TODO: remove test data
                /*Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                             inManagedObjectContext:document.managedObjectContext];
                place.name = @"Test Place 1, city, country";
                place.unique = [NSNumber numberWithInt:1];
                [document saveToURL:document.fileURL 
                   forSaveOperation:UIDocumentSaveForOverwriting
                  completionHandler:^(BOOL success) {
                      
                      Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                               inManagedObjectContext:document.managedObjectContext];
                      tag.name = @"Tag X";
                      [document saveToURL:document.fileURL 
                         forSaveOperation:UIDocumentSaveForOverwriting
                        completionHandler:^(BOOL success) {
                            completionHandler(document);
                        }];
                  }];*/
                 completionHandler(document);
            }
            else
                NSLog(@"Failed to create vacation document at path %@", documentURL.path);

        }];
    }
}
@end
