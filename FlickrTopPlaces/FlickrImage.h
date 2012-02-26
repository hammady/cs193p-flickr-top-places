//
//  FlickrImage.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/26/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrFetcherHelper.h"

@interface FlickrImage : UIImage

+(UIImage*) imageWithInfo:(NSDictionary*) info format:(FlickrFetcherPhotoFormat)format;

@end
