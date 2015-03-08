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
//@property (nonatomic, retain) IBOutlet UIButton *test;
//- (IBAction)teststeerAngle:(id)sender;

//Sound Array Stuff
@property (weak, nonatomic) IBOutlet UITextView *testTextView;
@property (nonatomic) NSString *soundArrayString;
@property (nonatomic) NSString *ipAddress;
@property (nonatomic) NSInteger portNumber;
@property (nonatomic, retain) NSInputStream *inputStream;

- (void) initNetworkCommunication;
- (void) tLog:(NSString *) msg;


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

@property(nonatomic) NSInteger movementBit;
@property(nonatomic) NSInteger reverseBit;

@property(nonatomic) float aX;
@property(nonatomic) float aY;

@property(nonatomic) float bX;
@property(nonatomic) float bY;

@property(nonatomic) float currentX;
@property(nonatomic) float currentY;

- (void)writeDataStream;
- (IBAction)movePlease:(id)sender;
- (IBAction)releasedSteerSlider:(id)sender;
- (IBAction)changedSteerSlider:(id)sender;
- (IBAction)releasedSpeedSlider:(id)sender;
- (IBAction)changedSpeedSlider:(id)sender;
@end

