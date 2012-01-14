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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
@interface DetailViewController : UIViewController 
<CLLocationManagerDelegate,
ASIHTTPRequestDelegate,
MKMapViewDelegate>{
    CLLocationManager *locationManager;
    IBOutlet UILabel *latLabel;
    IBOutlet UILabel *longLabel;
    IBOutlet UILabel *testLabel;
    float mylat;
    float mylng;
    BOOL _doneInitialZoom;
    MKMapView *_mapView;
    NSMutableArray *obsInfo;
    NSMutableArray *userFeedback;
  //  IBOutlet UIButton *testButton;
    NSOperationQueue *queue;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *obsInfo;
@property (nonatomic, retain) NSMutableArray *userFeedback;
@property (nonatomic, retain) NSOperationQueue *queue;
@end


