//
//  LocationInfo.h
//  WeatherSharing
//
//  Created by admin on 12/1/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationInfo : NSObject
{
NSMutableArray *_OBSLocations;

}

- (void)addToArray:(NSMutableArray *)array name:(char *)name identifier:(NSString *)identifier longt:(NSString *)longt lat:(NSString *)lat;
- (NSArray *)OBSLocations;
- (LocationInfo *)initOBSLocations;
@end
