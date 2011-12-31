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
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize mapView = _mapView;
@synthesize changeButton = _changeButton;


- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [locationManager release];

    [super dealloc];
}



#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

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
    [self configureView];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    

    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                     degrees, minutes, seconds];
    latLabel.text = lat;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                       degrees, minutes, seconds];
    longLabel.text = longt;
    NSString *testtext = [NSString stringWithFormat:@"%d23456",2];
    testLabel.text = testtext;
    
   /* UIImage *redButtonImage = [UIImage imageNamed:@"pic123.png"];
    
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redButton.frame = CGRectMake(280.0, 10.0, 29.0, 29.0);
    [redButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    */
    
   // [[testButton layer] setCorner
}

-(IBAction)changeClicked{
  if(_mapView.mapType == MKMapTypeStandard)
  {_mapView.mapType = MKMapTypeSatellite;}
    else if(_mapView.mapType == MKMapTypeSatellite)
    {_mapView.mapType = MKMapTypeHybrid;}
    else
    {_mapView.mapType = MKMapTypeStandard;}
    
    
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
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 25.04;
    zoomLocation.longitude = 121.53;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5*METERS_PER_MILE, 5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];                
    // 4
    [_mapView setRegion:adjustedRegion animated:YES];       
    _mapView.mapType = MKMapTypeStandard;
    
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
            NSString *lat = [dict objectForKey:@"lat"];
            NSString *lng = [dict objectForKey:@"lng"];
            
        
            NSLog(@"%@ %@", name, column);
            
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
