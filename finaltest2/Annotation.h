//
//  Annotation.h
//  WeatherSharing
//
//  Created by Linda Tseng on 11/12/31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
enum {
    Sunny,
    Cloudy,
    Rainy
}WeatherState;
enum {
    Cold,
    Normal,
    Hot
}TemperatureState;
@interface Annotation : NSObject <MKAnnotation>{
    NSString *_title;
    NSString *_subTitle;
    CLLocationCoordinate2D _coordiante2D;
    int weatherState;
    int temperatureState;
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) int weatherState;
@property (nonatomic) int temperatureState;

-(id) initWithTitle:(NSString *)theTitle subTitle:(NSString *)theSubTitle andCoordinate:(CLLocationCoordinate2D)theCoordinate andWeather:(int)weatherState andTemperature:(int)weatherState;

@end

