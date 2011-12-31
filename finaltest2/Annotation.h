//
//  Annotation.h
//  WeatherSharing
//
//  Created by Linda Tseng on 11/12/31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>{
    NSString *_title;
    NSString *_subTitle;
    CLLocationCoordinate2D _coordiante2D;
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *)theTitle subTitle:(NSString *)theSubTitle andCoordinate:(CLLocationCoordinate2D) theCoordinate;

@end

