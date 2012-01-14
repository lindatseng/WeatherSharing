//
//  DetailViewController.m
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Annotation.h"
#import "JSONKit.h"
#import "LocationInfo.h"
#define METERS_PER_MILE 1609.344


@interface DetailViewController ()
{
    BOOL isLocated;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)myPosition;
@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize mapView = _mapView;
@synthesize obsInfo;
@synthesize userFeedback;
@synthesize queue;
- (void)dealloc
{
    [_masterPopoverController release];
    [locationManager release];

    [super dealloc];
}



#pragma mark - Managing the detail item



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    id result = [response objectFromJSONString];  
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *temp1 = [response objectFromJSONString];
        NSDictionary *data = [temp1 objectForKey:@"result"];
        NSString *locationName = [data objectForKey:@"locationName"];
        NSString *description = [data objectForKey:@"description"];
        float longitude = [[LocationInfo sharedInfo] longitudeForLocation:locationName];
        float latitude = [[LocationInfo sharedInfo] latitudeForLocation:locationName];NSLog(@"%f,%f",latitude,longitude);
        CLLocationCoordinate2D coordinate = {latitude,longitude};
        Annotation *annotation =[[Annotation alloc]initWithTitle:locationName subTitle:description andCoordinate:coordinate];
        [_mapView addAnnotation:annotation];
        
        
        //data from suitingweather.appspot.com
    }
    else if([result isKindOfClass:[NSArray class]]){
        
        
        //data from sharemyweather.appspot.com
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _mapView.delegate=self;
    [self.view addSubview:_mapView];
    isLocated = NO;
    
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.toolbarHidden=NO;
    UIBarButtonItem *a= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(myPosition)];
    NSArray *items = [[NSArray alloc]initWithObjects:a,b, nil];
    [self setToolbarItems:items];
    
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    queue.maxConcurrentOperationCount=1;
    for(NSUInteger i=0;i<[[LocationInfo sharedInfo].OBSLocations count];i++){
        NSString *temp1 = [NSString stringWithFormat:@"http://suitingweather.appspot.com/obs?location=%@&output=json",
                           [[[LocationInfo sharedInfo].OBSLocations objectAtIndex:i]objectForKey:@"identifier"]];
        NSURL *url = [NSURL URLWithString:temp1];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        //[request startAsynchronous];
        [request setDelegate:self];
        [[self queue] addOperation:request];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mylat = newLocation.coordinate.latitude;
    mylng = newLocation.coordinate.longitude;
    
    if(!isLocated){
        MKCoordinateRegion region;
        region.center.latitude = mylat;
        region.center.longitude = mylng;
        MKCoordinateSpan span;
        span.latitudeDelta = .2;
        span.longitudeDelta = .2;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        isLocated = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateSpan span = _mapView.region.span;
    MKCoordinateRegion region = _mapView.region;
    float x1=region.center.longitude-span.longitudeDelta/2;
    float y1=region.center.latitude-span.latitudeDelta/2;
    float x2=region.center.longitude+span.longitudeDelta/2;
    float y2=region.center.latitude+span.latitudeDelta/2;
    
    NSLog(@"Map View Span: (%f, %f)->(%f, %f)",x1,y1,x2,y2);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) uploadData
{
//    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
//    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
//    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
//    [uploadrequest setPostValue:udid forKey:@"iosUID"];
//    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylat] forKey:@"lat"];
//    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylng] forKey:@"lng"];
//    [uploadrequest setPostValue:@"14" forKey:@"temper"];
//    [uploadrequest setPostValue:@"5" forKey:@"weatherType"];
//    [uploadrequest startSynchronous];
//    NSString *rrr = [uploadrequest responseString];
    //NSLog(@"%@",rrr);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
-(void)myPosition{
    MKCoordinateRegion region;
    region.center.latitude = mylat;
    region.center.longitude = mylng;
    MKCoordinateSpan span;
    span.latitudeDelta = .02;
    span.longitudeDelta = .02;
    region.span = span;
    
    
    [_mapView setRegion:region animated:YES];
}
@end
