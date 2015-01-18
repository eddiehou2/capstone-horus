//
//  ViewController.m
//  capstone-horus
//
//  Created by Eddie Hou on 2014-11-22.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "ViewController.h"
@import ExternalAccessory;

@interface ViewController () <EAAccessoryDelegate,NSStreamDelegate>

@end

@implementation ViewController
static NSMutableDictionary * microcarCommands = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDirectionary]; // Creates the direction with instructions to be send
    [self initAccessory]; // Searches and connects to MicroCar-20
    [self initStreams]; // Initializes and opens output and input streams
    [self initGestures];
    [self initStreamThread];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)movePlease:(id)sender {
    NSLog(@"Command: NO_STEER");
    self.sendIntermediate = microcarCommands[@"NO_STEER"];
    [self initMoveSequence];
}

- (IBAction)releasedSteerSlider:(id)sender {
    [self.steerSlider setValue:0.5f];
    NSLog(@"Command: NO_STEER");
    self.sendIntermediate = microcarCommands[@"NO_STEER"];
}

- (IBAction)changedSteerSlider:(id)sender {
    if (self.steerSlider.value > self.steerSlider.maximumValue/2) {
        NSLog(@"Command: STEER_RIGHT");
        self.sendIntermediate = microcarCommands[@"STEER_RIGHT"];
    }
    else if (self.steerSlider.value < self.steerSlider.maximumValue/2) {
        NSLog(@"Command: STEER_LEFT");
        self.sendIntermediate = microcarCommands[@"STEER_LEFT"];
    }
}

- (IBAction)releasedSpeedSlider:(id)sender {
    [self.speedSlider setValue:0.5f];
    NSLog(@"Command: NO_SPEED");
    self.sendIntermediate = microcarCommands[@"NO_SPEED"];
}

- (IBAction)changedSpeedSlider:(id)sender {
    if (self.speedSlider.value > self.speedSlider.maximumValue/2) {
        NSLog(@"Command: SPEED_FRONT");
        self.sendIntermediate = microcarCommands[@"SPEED_FRONT"];
    }
    else if (self.speedSlider.value < self.speedSlider.maximumValue/2) {
        NSLog(@"Command: SPEED_BACK");
        self.sendIntermediate = microcarCommands[@"SPEED_BACK"];
    }
}

-(void) initMoveSequence {
    self.byteLen = 2;//[self.writeData length];
    self.byteData = (Byte*)malloc(2);
    
    // Converting Hex to ASCII
    NSLog(@"Commencing Sequence: %@", self.sendIntermediate);
    int place = 0;
    NSArray * components = [self.sendIntermediate componentsSeparatedByString:@" "];
    for ( NSString * component in components ) {
        int value = 0;
        sscanf([component cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        self.byteData[place] = (Byte) value;
        place ++;
    }
    NSLog(@"ASCII Equivalent: %s", self.byteData);
    
    [self writeDataStream];
    free(self.byteData);
}

-(void) writeDataStream {
    while (([[self.session outputStream] hasSpaceAvailable]) && (self.byteLen > 0)) {
        NSInteger bytesWritten = [[self.session outputStream] write:self.byteData maxLength:self.byteLen];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
        }
        else if (bytesWritten >0)
        {
            NSLog(@"Bytes Written: %ld", (long)bytesWritten);
            self.byteLen = self.byteLen - bytesWritten;
        }
    }
}

-(void)createDirectionary {
    //    NSArray *objectives = [[NSArray alloc] initWithObjects:@"86 01",@"82 2E", nil];
    //    NSArray *keys = [[NSArray alloc] initWithObjects:@"HORN",@"MOVE", nil];
    microcarCommands = [[NSMutableDictionary alloc] init];
    microcarCommands[@"HORN_OFF"] = @"86 00";
    microcarCommands[@"HORN_ON"] = @"86 01";
    microcarCommands[@"LIGHTS_OFF"] = @"85 00";
    microcarCommands[@"LIGHTS_SOFT"] = @"85 01";
    microcarCommands[@"LIGHTS"] = @"85 02";
    microcarCommands[@"FAULT"] = @"83 04";
    microcarCommands[@"FAULT_OFF"] = @"83 00";
    microcarCommands[@"STEER_LEFT"] = @"81 4F";
    microcarCommands[@"STEER_RIGHT"] = @"81 30";
    microcarCommands[@"SPEED_BACK"] = @"82 6F";
    microcarCommands[@"SPEED_FRONT"] = @"82 10";
    microcarCommands[@"NO_SPEED"] = @"82 00";
    microcarCommands[@"NO_STEER"] = @"81 00";
}

-(void) initAccessory {
    self.deviceList = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    NSString *resultList = [self.deviceList componentsJoinedByString:@"\n"];
    self.deviceListLabel.text = resultList;
    for (EAAccessory *accessory in self.deviceList) {
        if ([[accessory name] isEqual:@"MicroCar-20"]){
            self.microCar = accessory;
            NSLog(@"I SET IT UP!");
            [self.microCar setDelegate:self];
            self.session = [[EASession alloc] initWithAccessory:self.microCar forProtocol: [[self.microCar protocolStrings] objectAtIndex:0]];
        }
    }
}

-(void) initStreams {
    [[self.session outputStream] setDelegate:self];
    [[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                           forMode:NSDefaultRunLoopMode];
    [[self.session outputStream] open];
    
    [[self.session inputStream] setDelegate:self];
    [[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                          forMode:NSDefaultRunLoopMode];
    [[self.session inputStream] open];
}

-(void) initStreamThread {
    NSThread *streamThread = [[NSThread alloc] initWithTarget:self selector:@selector(streamThreadMain) object:nil];
    [streamThread start];
}

-(void)streamThreadMain {
    // Check whether current thread is externally terminated or not.
    while([[NSThread currentThread] isCancelled] == NO)
    {
        if (self.sendIntermediate != nil){
            [self initMoveSequence];
        }
        [NSThread sleepForTimeInterval:0.1f];
    }
}

-(void) initGestures {
    UISwipeGestureRecognizer *swipeleft=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer *swiperight=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    UISwipeGestureRecognizer *swipeup=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeup:)];
    swipeup.direction=UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeup];
    
    UISwipeGestureRecognizer *swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedown:)];
    swipedown.direction=UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipedown];
    
    UITapGestureRecognizer *doubletapstop=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapstop:)];
    doubletapstop.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubletapstop];
    
}

-(void) swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"Command: STEER_LEFT");
    self.sendIntermediate = microcarCommands[@"STEER_LEFT"];
    [self initMoveSequence];
}

-(void) swiperight:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"Command: STEER_RIGHT");
    self.sendIntermediate = microcarCommands[@"STEER_RIGHT"];
    [self initMoveSequence];
}

-(void) swipeup:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"Command: SPEED_FRONT");
    self.sendIntermediate = microcarCommands[@"SPEED_FRONT"];
    [self initMoveSequence];
}

-(void) swipedown:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"Command: SPEED_BACK");
    self.sendIntermediate = microcarCommands[@"SPEED_BACK"];
    [self initMoveSequence];
}

-(void) doubletapstop:(UITapGestureRecognizer*)gestureRecognizer {
    NSLog(@"Command: NO_SPEED");
    self.sendIntermediate = microcarCommands[@"NO_SPEED"];
    [self initMoveSequence];
}

@end
