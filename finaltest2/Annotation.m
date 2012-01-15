//
//  Annotation.m
//  WeatherSharing
//
//  Created by Linda Tseng on 11/12/31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation
@synthesize title=_title,subtitle=_subTitle,coordinate=_coordiante2D;
@synthesize weatherState,temperatureState;
-(id) initWithTitle:(NSString *)theTitle subTitle:(NSString *)theSubTitle andCoordinate:(CLLocationCoordinate2D)theCoordinate andWeather:(int)weatherState andTemperature:(int)temperatureState{
    self = [super init];
    if(self){
        _title = [theTitle copy];
        _subTitle = [theSubTitle copy];
        _coordiante2D = theCoordinate;
        self.weatherState=weatherState;
        self.temperatureState=temperatureState;
    }
    return self;
}
@end
