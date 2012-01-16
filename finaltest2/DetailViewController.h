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
#import <AVFoundation/AVFoundation.h>
#import "TutorialViewController.h"
@interface DetailViewController : UIViewController 
<CLLocationManagerDelegate,
ASIHTTPRequestDelegate,
MKMapViewDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>{
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
    TutorialViewController *tutorialViewController;
    AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureVideoDataOutput *videoDataOutput;
	BOOL detectFaces;
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureStillImageOutput *stillImageOutput;
	UIView *flashView;
	UIImage *square;
	BOOL isUsingFrontFacingCamera;
	CIDetector *faceDetector;
	CGFloat beginGestureScale;
	CGFloat effectiveScale;
    int faceState;
    int currentView;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *obsInfo;
@property (nonatomic, retain) NSMutableArray *userFeedback;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic) int currentView;
@property (nonatomic, retain) TutorialViewController *tutorialViewController;
@end


