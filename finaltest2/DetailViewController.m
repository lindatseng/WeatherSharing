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
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize mapView = _mapView;

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
    UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:nil];
    NSArray *items = [[NSArray alloc]initWithObjects:a,b, nil];
    [self setToolbarItems:items];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mylat = newLocation.coordinate.latitude;
    int degrees = newLocation.coordinate.latitude;
    NSLog(@"%lf", newLocation.coordinate.latitude);
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                     degrees, minutes, seconds];
    latLabel.text = lat;
    mylng = newLocation.coordinate.longitude;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                       degrees, minutes, seconds];
    longLabel.text = longt;
    NSString *testtext = [NSString stringWithFormat:@"%d23456",2];
    testLabel.text = testtext;
    
    //[self uploadData];
    
    MKCoordinateRegion region;
    region.center.latitude = mylat;
    region.center.longitude = mylng;
    MKCoordinateSpan span;
    span.latitudeDelta = .002;
    span.longitudeDelta = .002;
    region.span = span;
    
    
    [_mapView setRegion:region animated:YES];
    
   /* UIImage *redButtonImage = [UIImage imageNamed:@"pic123.png"];
    
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redButton.frame = CGRectMake(280.0, 10.0, 29.0, 29.0);
    [redButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    */
    
   // [[testButton layer] setCorner
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
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    MKCoordinateRegion region;
    region.center.latitude = 0;
    region.center.longitude = 0;
    MKCoordinateSpan span;
    span.latitudeDelta = .002;
    span.longitudeDelta = .002;
    region.span = span;
    [_mapView setRegion:region animated:YES];
    [self.view addSubview:_mapView];
    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    [uploadrequest setPostValue:udid forKey:@"iosUID"];
    [uploadrequest setPostValue:@"23.5" forKey:@"lat"];
    [uploadrequest setPostValue:@"121.0" forKey:@"lng"];
    [uploadrequest setPostValue:@"14" forKey:@"temper"];
    [uploadrequest setPostValue:@"5" forKey:@"weatherType"];
    [uploadrequest startSynchronous];
    NSString *rrr = [uploadrequest responseString];
    NSLog(@"%@",rrr);
    
    
    NSURL *url = [NSURL URLWithString:@"http://sharemyweather.appspot.com/download"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        
        id result = [response objectFromJSONString];        
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *array = [response objectFromJSONString];        
            NSDictionary *dict = [array objectAtIndex:0];
            NSString *_lat = [dict objectForKey:@"lat"];
            NSString *_lng = [dict objectForKey:@"lng"];
            NSString *_temper = [dict objectForKey:@"temper"];
            NSString *_weatherType = [dict objectForKey:@"weatherType"];
            
            float lat = [_lat floatValue];
            float lng = [_lng floatValue];
            int temper = [_temper intValue];
            int weatherType = [_weatherType intValue];
            
        

            
        }
        else {
            //TODO        
        }
        
    
    }
    else {
        //TODO
    }
    
    CLLocationCoordinate2D location0 = {25.044423,121.52673};
    Annotation *myAnnotation0 = [[Annotation alloc]initWithTitle:@"title1" subTitle:@"subtitle1" andCoordinate:location0];
    CLLocationCoordinate2D location1 = {25.04411,121.52534};
    Annotation *myAnnotation1 = [[Annotation alloc] initWithTitle:@"遠東國際商業銀行"
                                                         subTitle:@"電話：02-2327-8898"
                                                    andCoordinate:location1];
    [_mapView addAnnotations:[NSArray arrayWithObjects:myAnnotation0, myAnnotation1, nil]];
    
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
    NSLog(@"%@",rrr);
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

@end
