//
//  ViewController.h
//  capstone-horus
//
//  Created by Eddie Hou on 2014-11-22.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ExternalAccessory;

@interface ViewController : UIViewController
@property(nonatomic,strong) EAAccessory *microCar;
@property(nonatomic,strong) EASession *session;
@property(nonatomic,retain) NSArray *deviceList;
@property (weak, nonatomic) IBOutlet UILabel *deviceListLabel;
@property(nonatomic,strong) id streamDelegate;

@property (weak, nonatomic) IBOutlet UISlider *steerSlider;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;

@property(nonatomic,retain) NSString *sendIntermediate;
@property(nonatomic) Byte *byteData;
@property(nonatomic) NSUInteger byteLen;
-(void)writeDataStream;
- (IBAction)movePlease:(id)sender;
- (IBAction)releasedSteerSlider:(id)sender;
- (IBAction)changedSteerSlider:(id)sender;
- (IBAction)releasedSpeedSlider:(id)sender;
- (IBAction)changedSpeedSlider:(id)sender;
@end

