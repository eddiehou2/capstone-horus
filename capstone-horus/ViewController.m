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

@implementation ViewController {
    BOOL isAvailable;
}
static NSMutableDictionary * microcarCommands = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDirectionary]; // Creates the direction with instructions to be send
    [self initAccessory]; // Searches and connects to MicroCar-20
    [self initStreams]; // Initializes and opens output and input streams
    [self initGestures];
    [self initStreamThread];
    
    isAvailable = false;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)movePlease:(id)sender {
    int speedIndex = 10;
    int steerIndex = 10;
    float sleepTime = 2.0f;
    
    NSLog(@"Command: move_Please");
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_FRONT"][speedIndex],microcarCommands[@"STEER_RIGHT"][steerIndex]];
    [NSThread sleepForTimeInterval:sleepTime];
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
}

- (IBAction)releasedSteerSlider:(id)sender {
    [self.steerSlider setValue:0.5f];
    NSLog(@"Command: NO_STEER");
    self.sendIntermediate = microcarCommands[@"NO_STEER"];
}

- (IBAction)changedSteerSlider:(id)sender {
    if (self.steerSlider.value > self.steerSlider.maximumValue/2) {
        NSLog(@"Command: STEER_RIGHT");
        self.sendIntermediate = [microcarCommands[@"STEER_RIGHT"] objectAtIndex:10];
    }
    else if (self.steerSlider.value < self.steerSlider.maximumValue/2) {
        NSLog(@"Command: STEER_LEFT");
        self.sendIntermediate = [microcarCommands[@"STEER_LEFT"] objectAtIndex:10];
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
        self.sendIntermediate = [microcarCommands[@"SPEED_FRONT"] objectAtIndex:10];
    }
    else if (self.speedSlider.value < self.speedSlider.maximumValue/2) {
        NSLog(@"Command: SPEED_BACK");
        self.sendIntermediate = [microcarCommands[@"SPEED_BACK"] objectAtIndex:10];
    }
}

-(void) initMoveSequence {
    self.byteLen = 4;//[self.writeData length];
    self.byteData = (Byte*)malloc(4);
    
    // Converting Hex to ASCII
    // NSLog(@"Commencing Sequence: %@", self.sendIntermediate);
    int place = 0;
    NSMutableArray * components = [[self.sendIntermediate componentsSeparatedByString:@" "] mutableCopy];
    for ( NSString * component in components ) {
        int value = 0;
        sscanf([component cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        self.byteData[place] = (Byte) value;
        place ++;
    }
    // NSLog(@"ASCII Equivalent: %s", self.byteData);
    
    [self writeDataStream];
}

-(void) writeDataStream {
    while ((([[self.session outputStream] hasSpaceAvailable]) || isAvailable) && (self.byteLen > 0)) {
        NSInteger bytesWritten = [[self.session outputStream] write:self.byteData maxLength:self.byteLen];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
        }
        else if (bytesWritten >0)
        {
            // NSLog(@"Bytes Written: %ld", (long)bytesWritten);
            self.byteLen = self.byteLen - bytesWritten;
            self.sendIntermediate = nil;
            isAvailable = false;
        }
    }
    
    if (![[self.session outputStream] hasSpaceAvailable]) {
        NSLog(@"Instruction: %s did not get written.",self.byteData);
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
    
    NSArray *steerLeft = @[@"81 7F",@"81 7E",@"81 7D",@"81 7C",@"81 7B",@"81 7A",@"81 79",@"81 78",@"81 77",@"81 76",@"81 75",@"81 74",@"81 73",@"81 72",@"81 71",@"81 70",@"81 6F",@"81 6E",@"81 6D",@"81 6C",@"81 6B",@"81 6A",@"81 69",@"81 68",@"81 67",@"81 66",@"81 65",@"81 64",@"81 63",@"81 62",@"81 61",@"81 60",@"81 5F",@"81 5E",@"81 5D",@"81 5C",@"81 5B",@"81 5A",@"81 59",@"81 58",@"81 57",@"81 56",@"81 55",@"81 54",@"81 53",@"81 52",@"81 51",@"81 50",@"81 4F",@"81 4E",@"81 4D",@"81 4C",@"81 4B",@"81 4A",@"81 49",@"81 48",@"81 47",@"81 46",@"81 45",@"81 44",@"81 43",@"81 42",@"81 41"];
    
    NSArray *steerRight = @[@"81 00",@"81 01",@"81 02",@"81 03",@"81 04",@"81 05",@"81 06",@"81 07",@"81 08",@"81 09",@"81 0A",@"81 0B",@"81 0C",@"81 0D",@"81 0E",@"81 0F",@"81 10",@"81 11",@"81 12",@"81 13",@"81 14",@"81 15",@"81 16",@"81 17",@"81 18",@"81 19",@"81 1A",@"81 1B",@"81 1C",@"81 1D",@"81 1E",@"81 1F",@"81 20",@"81 21",@"81 22",@"81 23",@"81 24",@"81 25",@"81 26",@"81 27",@"81 28",@"81 29",@"81 2A",@"81 2B",@"81 2C",@"81 2D",@"81 2E",@"81 2F",@"81 30",@"81 31",@"81 32",@"81 33",@"81 34",@"81 35",@"81 36",@"81 37",@"81 38",@"81 39",@"81 3A",@"81 3B",@"81 3C",@"81 3D",@"81 3E",@"81 3F"];
    
    microcarCommands[@"STEER_LEFT"] = steerLeft;
    microcarCommands[@"STEER_RIGHT"] = steerRight;
    
    NSArray *speedBack = @[@"82 7F",@"82 7E",@"82 7D",@"82 7C",@"82 7B",@"82 7A",@"82 79",@"82 78",@"82 77",@"82 76",@"82 75",@"82 74",@"82 73",@"82 72",@"82 71",@"82 70",@"82 6F",@"82 6E",@"82 6D",@"82 6C",@"82 6B",@"82 6A",@"82 69",@"82 68",@"82 67",@"82 66",@"82 65",@"82 64",@"82 63",@"82 62",@"82 61",@"82 60",@"82 5F",@"82 5E",@"82 5D",@"82 5C",@"82 5B",@"82 5A",@"82 59",@"82 58",@"82 57",@"82 56",@"82 55",@"82 54",@"82 53",@"82 52",@"82 51",@"82 50",@"82 4F",@"82 4E",@"82 4D",@"82 4C",@"82 4B",@"82 4A",@"82 49",@"82 48",@"82 47",@"82 46",@"82 45",@"82 44",@"82 43",@"82 42",@"82 41"];
    
    NSArray *speedFront = @[@"82 00",@"82 01",@"82 02",@"82 03",@"82 04",@"82 05",@"82 06",@"82 07",@"82 08",@"82 09",@"82 0A",@"82 0B",@"82 0C",@"82 0D",@"82 0E",@"82 0F",@"82 10",@"82 11",@"82 12",@"82 13",@"82 14",@"82 15",@"82 16",@"82 17",@"82 18",@"82 19",@"82 1A",@"82 1B",@"82 1C",@"82 1D",@"82 1E",@"82 1F",@"82 20",@"82 21",@"82 22",@"82 23",@"82 24",@"82 25",@"82 26",@"82 27",@"82 28",@"82 29",@"82 2A",@"82 2B",@"82 2C",@"82 2D",@"82 2E",@"82 2F",@"82 30",@"82 31",@"82 32",@"82 33",@"82 34",@"82 35",@"82 36",@"82 37",@"82 38",@"82 39",@"82 3A",@"82 3B",@"82 3C",@"82 3D",@"82 3E",@"82 3F"];
    
    microcarCommands[@"SPEED_BACK"] = speedBack;
    microcarCommands[@"SPEED_FRONT"] = speedFront;
    
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
