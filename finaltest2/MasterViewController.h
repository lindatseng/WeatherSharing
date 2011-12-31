//
//  MasterViewController.h
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UIViewController{

IBOutlet UILabel *situationLabel;
    int _rainState;
    int _temperatureState;

}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *testButton;
@property (nonatomic, retain) IBOutlet UIButton *testButton2;
@property (nonatomic, retain) IBOutlet UIButton *testButton3;
@property (nonatomic, retain) IBOutlet UIButton *testButton4;
@property (nonatomic, retain) IBOutlet UIButton *testButton5;
@property (nonatomic, retain) IBOutlet UIButton *testButton6;

-(IBAction) startClicked;
-(IBAction) buttonClicked;
-(IBAction) buttonClicked2;
-(IBAction) buttonClicked3;
-(IBAction) buttonClicked4;
-(IBAction) buttonClicked5;
-(IBAction) buttonClicked6;

@end
