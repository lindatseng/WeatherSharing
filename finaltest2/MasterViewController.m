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
@synthesize startButton = _startButton3;
@synthesize testButton = _testButton;
@synthesize testButton2 = _testButton2;
@synthesize testButton3 = _testButton3;
@synthesize testButton4 = _testButton4;
@synthesize testButton5 = _testButton5;
@synthesize testButton6 = _testButton6;

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
    
    UIImage *backgroundImage = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton2 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton3 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton4 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton5 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton6 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    _rainState = 0;
    _temperatureState = 0;
    _getPosition = FALSE;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];

	// Do any additional setup after loading the view, typically from a nib.
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mylat = newLocation.coordinate.latitude;
    mylng = newLocation.coordinate.longitude;
    _getPosition = TRUE;

    
    
    /* UIImage *redButtonImage = [UIImage imageNamed:@"pic123.png"];
     
     UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
     redButton.frame = CGRectMake(280.0, 10.0, 29.0, 29.0);
     [redButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
     */
    
    // [[testButton layer] setCorner
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
}

-(IBAction)buttonClicked{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton2 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton3 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    _rainState = 1;
    
    
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}

-(IBAction)buttonClicked2{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton2 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton3 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    _rainState = 2;
    
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}

-(IBAction)buttonClicked3{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    
    [_testButton setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton2 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton3 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    _rainState = 3;
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}

-(IBAction)buttonClicked4{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton4 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton5 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton6 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    _temperatureState = 1;
    
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}

-(IBAction)buttonClicked5{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton4 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton5 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton6 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    _temperatureState = 2;
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}

-(IBAction)buttonClicked6{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    
    [_testButton4 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton5 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton6 setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    _temperatureState = 3;
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;    
}


-(IBAction)startClicked{
    NSLog(@"startClicked");
    [self uploadData];

    LocationInfo *_locationInfo = [[LocationInfo alloc] initOBSLocations];
    NSArray *locations = [_locationInfo OBSLocations];
    
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
    }
    if(!self.detailViewController.obsInfo){
        self.detailViewController.obsInfo = [[NSMutableArray alloc]initWithCapacity:0];
    }
    if(!self.detailViewController.userFeedback){
        self.detailViewController.userFeedback = [[NSMutableArray alloc]initWithCapacity:0];
    }
    
    for(NSUInteger i=0;i<[locations count];i++){
        NSString *temp1 = [NSString stringWithFormat:@"http://suitingweather.appspot.com/obs?location=%@&output=json",
                       [[locations objectAtIndex:i]objectForKey:@"identifier"]];
    NSURL *url = [NSURL URLWithString:temp1];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
         
        NSString *response = [request responseString];
        
        id result = [response objectFromJSONString];        
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = [response objectFromJSONString];
            NSDictionary *_dictTwo = [dict objectForKey:@"result"];
            
            //NSString *_time = [_dictTwo objectForKey:@"time"];

           // float lat = [_lat floatValue];
            
            
            NSString *rain = [_dictTwo objectForKey:@"rain"];
            NSString *temperature = [_dictTwo objectForKey:@"temperature"];
            NSString *name = [_dictTwo objectForKey:@"locationName"];
            NSString *description = [_dictTwo objectForKey:@"description"];
            NSString *_time = [_dictTwo objectForKey:@"time"];
            [self.detailViewController.obsInfo addObject:[[NSDictionary alloc]initWithObjectsAndKeys:rain ,@"rain",
                                                        temperature,@"temperature",
                                                        name, @"locationName",
                                                        description,@"description",
                                                        _time,@"time",
                                                        [[locations objectAtIndex:i]objectForKey:@"longt"],@"longt",
                                                        [[locations objectAtIndex:i]objectForKey:@"lat"],@"lat",
                                                          nil ]];
        }
        else {
             //TODO        
        }
        
        
    }
    else {
        //TODO
    }
    }
    //part two
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://sharemyweather.appspot.com/download"]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        
        NSString *response = [request responseString];
        
        id result = [response objectFromJSONString];        
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *data = [NSArray arrayWithArray:result];
            for (NSUInteger i=0; i<[data count]; i++) {
                NSDictionary *feedback = [data objectAtIndex:i];
                //for temporary use only(demo)
                NSString *rain = @"123";
                NSString *temperature = @"123";
                NSString *name = [feedback objectForKey:@"date"];
                NSString *description = [feedback objectForKey:@"weatherType"];
                NSString *_time = @"123";
                [self.detailViewController.userFeedback addObject:[[NSDictionary alloc]initWithObjectsAndKeys:rain ,@"rain",
                                                              temperature,@"temperature",
                                                              name, @"locationName",
                                                              description,@"description",
                                                              _time,@"time",
                                                              [feedback objectForKey:@"lng"],@"longt",
                                                              [feedback objectForKey:@"lat"],@"lat",
                                                              nil ]];

                //for temporary use only(demo)
                if (i>5) {
                    break;
                }
                
            }
        
        
        
        
        }
        else {
            //TODO        
        }
        
        
    }
    else {
        //TODO
    }
    
    
    
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
}




@end
