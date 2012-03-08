//
//  FlickrImage.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/26/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrImage.h"
#define CACHE_SUBDIR            @"images"
#define CACHE_SUBDIR_SQUARE     @"square"
#define CACHE_SUBDIR_LARGE      @"large"
#define CACHE_SUBDIR_THUMBNAIL  @"thumbnail"
#define CACHE_SUBDIR_SMALL      @"small"
#define CACHE_SUBDIR_MEDIUM     @"medium"
#define CACHE_SUBDIR_ORIGINAL   @"original"
#define CACHE_SUBDIR_UNDEFINED  @"undefined"
#define CACHE_SIZE_MAX        (10*1024*1024)
#define CACHE_SIZE_MIN        (7*1024*1024)

@interface FlickrImage()

@end

@implementation FlickrImage

static NSFileManager* _fileManager;
static NSString* _cacheSubdir;
static UInt64 _cacheSize;

+(NSFileManager*) fileManager
{
    if (_fileManager == nil)
        _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

+(NSString*) cacheSubdir
{
    if (_cacheSubdir == nil) 
        _cacheSubdir = [[[[[self fileManager] URLsForDirectory:NSCachesDirectory 
                                  inDomains:NSUserDomainMask]
              lastObject] path] stringByAppendingPathComponent:CACHE_SUBDIR];
    return _cacheSubdir;
}

+(void) createCacheSubdir
{
    [[self fileManager] createDirectoryAtPath:[self cacheSubdir] 
                  withIntermediateDirectories:NO attributes:nil error:nil];
}

+(UInt64) sizeOfDirectoryAtPath:(NSString*) path
{
    // very expensive function, rarely call
    NSFileManager *fileManager = [self fileManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:path error:nil];
    UInt64 totalSize = 0;
    for (NSString *file in files) {
        NSDictionary* attribs = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
        totalSize += [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
    }
    return totalSize;
}

+(UInt64) cacheSize
{
    if (_cacheSize == 0)
        _cacheSize = [self sizeOfDirectoryAtPath:[self cacheSubdir]];
    return _cacheSize;
}

+(void) setCachSize:(UInt64) size
{
    _cacheSize = size;
}

+(NSString*) cacheSuffixForFormat:(FlickrFetcherPhotoFormat) format
{
    switch (format) {
        case FlickrFetcherPhotoFormatLarge:
            return CACHE_SUBDIR_LARGE;
        case FlickrFetcherPhotoFormatMedium:
            return CACHE_SUBDIR_MEDIUM;
        case FlickrFetcherPhotoFormatOriginal:
            return CACHE_SUBDIR_ORIGINAL;
        case FlickrFetcherPhotoFormatSmall:
            return CACHE_SUBDIR_SMALL;
        case FlickrFetcherPhotoFormatSquare:
            return CACHE_SUBDIR_SQUARE;
        case FlickrFetcherPhotoFormatThumbnail:
            return CACHE_SUBDIR_THUMBNAIL;
        default:
            return CACHE_SUBDIR_UNDEFINED;
    }
}

+(id) cachedImageData:(NSDictionary*) info format:(FlickrFetcherPhotoFormat) format
{
    NSString* imageFilePath = [[[self cacheSubdir] stringByAppendingPathComponent:
                               [info objectForKey:PHOTO_DICT_ID]] 
                               stringByAppendingString:[self cacheSuffixForFormat:format]];
    BOOL cached = [[self fileManager] isReadableFileAtPath:imageFilePath];
    
    if (cached) {
        NSData* imageData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        return imageData;
    } else {
        return imageFilePath;
    }
}

+(void) cacheImageWithData:(NSData*) data filePath:(NSString*) path
{
    [self createCacheSubdir];

    [data writeToFile:path atomically:YES];

    NSFileManager *fileManager = [self fileManager];
    NSString* cacheDir = [self cacheSubdir];
    UInt64 cacheSize = [self cacheSize];
    
    NSDictionary* attribs = [fileManager attributesOfItemAtPath:path error:nil];
    UInt64 newFilesize = [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
    cacheSize += newFilesize;
    [self setCachSize: cacheSize];
    
    // limit cache size
    if (cacheSize > CACHE_SIZE_MAX) {
        NSMutableArray *files = [[fileManager subpathsOfDirectoryAtPath:cacheDir error:nil] mutableCopy];
        // sort from newest to oldest
        [files sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* file1 = [cacheDir stringByAppendingPathComponent:obj1];
            NSString* file2 = [cacheDir stringByAppendingPathComponent:obj2];
            NSDictionary* attribs1 = [fileManager attributesOfItemAtPath:file1 error:nil];
            NSDictionary* attribs2 = [fileManager attributesOfItemAtPath:file2 error:nil];
            NSDate* date1 = [(NSDictionary*) attribs1 objectForKey:NSFileCreationDate];
            NSDate* date2 = [(NSDictionary*) attribs2 objectForKey:NSFileCreationDate];
            return [date1 compare:date2];  
        }];
        UInt64 filesize;
        for (NSString *file in files) {
            NSString* filename = [cacheDir stringByAppendingPathComponent:file];
            NSDictionary* attribs = [fileManager attributesOfItemAtPath:filename error:nil];
            filesize = [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
            [fileManager removeItemAtPath:filename error:nil];
            cacheSize -= filesize;
            if (cacheSize <= CACHE_SIZE_MIN)
                break;
            // continue evacuating till min is reached so that there is room
            // for several images to come in again and not trigger this 
            // expensive function on each cached image
        }
        [self setCachSize:cacheSize];
    }
}

+(UIImage*) imageWithInfo:(NSDictionary *)info format:(FlickrFetcherPhotoFormat)format
useCache:(BOOL) useCache
{
    NSData* imageData;

    // check if image is in cache, load it, else request it from Flickr
    id cacheResult;
    if (useCache) cacheResult = [self cachedImageData:info format:format];
    
    if (!useCache || [cacheResult isKindOfClass:[NSString class]]) {
        // cache miss, fetch it
        
        // simulate slow connection
        // sleep(5);

        imageData = [FlickrFetcherHelper 
                 imageDataForPhotoWithFlickrInfo:info 
                 format:format];
        NSLog(@"Cache miss, fetched image with data length: %x", imageData.length);
        // store it back into cache
        if (useCache) [self cacheImageWithData:imageData filePath:cacheResult];
    } else {
        // cache hit, use it
        imageData = (NSData*) cacheResult;
        NSLog(@"Cache hit");
    }

    return [[UIImage alloc] initWithData:imageData];
}

@end
