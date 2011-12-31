//
//  MasterViewController.m
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

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

-(IBAction)buttonClicked{
    UIImage *backgroundImage = [UIImage imageNamed:@"pic123.png"];
    UIImage *backgroundImage2 = [UIImage imageNamed:@"apple_ex.png"];
    [_testButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_testButton2 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    [_testButton3 setBackgroundImage:backgroundImage2 forState:UIControlStateNormal];
    _rainState = 1;
    
    
    NSString *situation = [NSString stringWithFormat:@"rain %d;temperature%d",_rainState,_temperatureState];
    situationLabel.text = situation;
    NSLog(@"123");
    
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
    NSLog(@"123");
    
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
    NSLog(@"123");
    
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
    NSLog(@"123");
    
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
    NSLog(@"123");
    
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
    NSLog(@"123");
    
}


-(IBAction)startClicked{
 
    NSLog(@"123");
 
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
    }
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
}




@end
