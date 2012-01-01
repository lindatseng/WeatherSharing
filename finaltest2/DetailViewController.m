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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
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
    
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.toolbarHidden=NO;
    UIBarButtonItem *a= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(myPosition)];
    NSArray *items = [[NSArray alloc]initWithObjects:a,b, nil];
    [self setToolbarItems:items];
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
        span.latitudeDelta = .02;
        span.longitudeDelta = .02;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        isLocated = YES;
    }
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 1
    isLocated = NO;
    
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    [self.view addSubview:_mapView];
    
    NSMutableArray *annotation = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSUInteger i=0; i<[obsInfo count]; i++) {
        float lat = [[[obsInfo objectAtIndex:i] objectForKey:@"lat"] floatValue];
        float longt = [[[obsInfo objectAtIndex:i] objectForKey:@"longt"] floatValue];
        NSString *name = [[obsInfo objectAtIndex:i] objectForKey:@"locationName"];
        NSString *description = [[obsInfo objectAtIndex:i] objectForKey:@"description"];
        CLLocationCoordinate2D location0 = {lat,longt};
        Annotation *myAnnotation0 = [[Annotation alloc]initWithTitle:name subTitle:description andCoordinate:location0];
        [annotation addObject:myAnnotation0];
    }
    
    for (NSUInteger i=0; i<[userFeedback count]; i++) {
        float lat = [[[userFeedback objectAtIndex:i] objectForKey:@"lat"] floatValue];
        float longt = [[[userFeedback objectAtIndex:i] objectForKey:@"longt"] floatValue];
        NSString *name = [[userFeedback objectAtIndex:i] objectForKey:@"locationName"];
        NSString *description = [[userFeedback objectAtIndex:i] objectForKey:@"description"];
        NSLog(@"%@,%@",name,description);
        CLLocationCoordinate2D location0 = {lat,longt};
        Annotation *myAnnotation0 = [[Annotation alloc]initWithTitle:name subTitle:name andCoordinate:location0];
        [annotation addObject:myAnnotation0];
    }
    _mapView.showsUserLocation = YES;
    [_mapView addAnnotations:[NSArray arrayWithArray:annotation]];
    
    
//    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
//    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
//    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
//    [uploadrequest setPostValue:udid forKey:@"iosUID"];
//    [uploadrequest setPostValue:@"23.5" forKey:@"lat"];
//    [uploadrequest setPostValue:@"121.0" forKey:@"lng"];
//    [uploadrequest setPostValue:@"14" forKey:@"temper"];
//    [uploadrequest setPostValue:@"5" forKey:@"weatherType"];
//    [uploadrequest startSynchronous];
//    NSString *rrr = [uploadrequest responseString];

    
}

- (void) uploadData
{
    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    [uploadrequest setPostValue:udid forKey:@"iosUID"];
    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylat] forKey:@"lat"];
    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylng] forKey:@"lng"];
    [uploadrequest setPostValue:@"14" forKey:@"temper"];
    [uploadrequest setPostValue:@"5" forKey:@"weatherType"];
    [uploadrequest startSynchronous];
    NSString *rrr = [uploadrequest responseString];
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
