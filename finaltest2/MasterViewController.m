//
//  MasterViewController.m
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "LocationInfo.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize startButton;
@synthesize control1;
@synthesize control2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
          }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [super dealloc];
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
    
    
    
    _rainState = 0;
    _temperatureState = 0;
    _getPosition = FALSE;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    [startButton setBackgroundColor:[UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1]];
    
//    startButton.titleLabel.backgroundColor=[UIColor redColor];
	// Do any additional setup after loading the view, typically from a nib.
    [[startButton layer] setCornerRadius:8.0f];
    [[startButton layer] setMasksToBounds:YES];
    [[startButton layer] setBorderWidth:1.0f];
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
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    } else {
//        return YES;
//    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mylat = newLocation.coordinate.latitude;
    mylng = newLocation.coordinate.longitude;
    _getPosition = TRUE;
}


- (void) uploadData
{
    NSString *rainType = [NSString stringWithFormat:@"%d",control1.selectedSegmentIndex];
    NSString *temperatureType = [NSString stringWithFormat:@"%d",control2.selectedSegmentIndex];
    
    
    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    [uploadrequest setPostValue:udid forKey:@"iosUID"];
    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylat] forKey:@"lat"];
    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylng] forKey:@"lng"];
    [uploadrequest setPostValue:temperatureType forKey:@"temper"];
    [uploadrequest setPostValue:rainType forKey:@"weatherType"];
    [uploadrequest startSynchronous];
    
}



-(IBAction)startClicked{
    
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
    }
    if(control1.selectedSegmentIndex!=-1&&control2.selectedSegmentIndex!=-1){
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
    [self uploadData];
    }
    
}




@end
