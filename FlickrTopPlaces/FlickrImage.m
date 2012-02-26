//
//  FlickrImage.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/26/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "FlickrImage.h"
#define CACHE_SUBDIR_SQUARE     @"square"
#define CACHE_SUBDIR_LARGE      @"large"
#define CACHE_SUBDIR_THUMBNAIL  @"thumbnail"
#define CACHE_SUBDIR_SMALL      @"small"
#define CACHE_SUBDIR_MEDIUM     @"medium"
#define CACHE_SUBDIR_ORIGINAL   @"original"
#define CACHE_SUBDIR_UNDEFINED  @"undefined"


@implementation FlickrImage

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
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSString* imageCacheDir = [[[fileManager URLsForDirectory:NSCachesDirectory 
                                                   inDomains:NSUserDomainMask]
                               lastObject] path];
    NSString* imageFilePath = [[imageCacheDir stringByAppendingPathComponent:
                               [info objectForKey:PHOTO_DICT_ID]] 
                               stringByAppendingString:[self cacheSuffixForFormat:format]];
    BOOL cached = [fileManager isReadableFileAtPath:imageFilePath];
    
    if (cached) {
        NSData* imageData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        return imageData;
    } else {
        return imageFilePath;
    }
}

+(void) cacheImageWithData:(NSData*) data filePath:(NSString*) path
{
    [data writeToFile:path atomically:YES];
}

+(UIImage*) imageWithInfo:(NSDictionary *)info format:(FlickrFetcherPhotoFormat)format
{
    NSData* imageData;

    // check if image is in cache, load it, else request it from Flickr
    id cacheResult = [self cachedImageData:info format:format];
    
    if ([cacheResult isKindOfClass:[NSString class]]) {
        // cache miss, fetch it
        imageData = [FlickrFetcherHelper 
                 imageDataForPhotoWithFlickrInfo:info 
                 format:format];
        NSLog(@"Cache miss, fetched image with data length: %x", imageData.length);
        // store it back into cache
        [self cacheImageWithData:imageData filePath:cacheResult];
    } else {
        // cache hit, use it
        imageData = (NSData*) cacheResult;
        NSLog(@"Cache hit");
    }

    return [[UIImage alloc] initWithData:imageData];
}

@end
