//
//  DetailViewController.h
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController : UIViewController 
<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    IBOutlet UILabel *latLabel;
    IBOutlet UILabel *longLabel;
    IBOutlet UILabel *testLabel;
    float mylat;
    float mylng;
    BOOL _doneInitialZoom;
    MKMapView *_mapView;
  //  IBOutlet UIButton *testButton;
   
}

@property (nonatomic, retain) MKMapView *mapView;

@end


