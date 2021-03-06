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

@synthesize inputStream;
@synthesize ipAddress;
@synthesize portNumber;

static NSMutableDictionary * microcarCommands = nil;

/*
- (IBAction)teststeerAngle:(id)sender {
    int turnRight = 1;
    int steeringIndex = 4;
    NSString *turn;
    
    if (turnRight == 1) turn = @"STEER_RIGHT";
    else turn = @"STEER_LEFT";
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_FRONT"][16], microcarCommands[turn][steeringIndex]];
    
    [NSThread sleepForTimeInterval:1.0f];   //move for 2 sec = 23 cm
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
    
    
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDirectionary]; // Creates the direction with instructions to be send
    [self initAccessory]; // Searches and connects to MicroCar-20
    [self initStreams]; // Initializes and opens output and input streams
    [self initGestures];
    [self initStreamThread];
    [self initHelperThread];
    
    isAvailable = false;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.movementBit = 0;
    self.reverseBit = 1;
    
    self.aX = 0.0f;
    self.aY = 10.0f;
    self.bX = 0.0f;
    self.bY = 0.0f;
    self.currentX = 0.0f;
    self.currentY = 0.0f;
    
    self.referencePoint = @"0.0 10.0";
    
    //At this point, self.ipAddress and self.portNumber are set to the values the user has inputted
    [self tLog:[NSString stringWithFormat:@"At View Controller: Connecting to IP Address: %@, Port Number: %d", self.ipAddress, self.portNumber]];
    [self initNetworkCommunication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//speed = 16, steer = 63, time = 1.8, radius = 6.3cm
//speed = 16, steer = 48, time = 1.8, radius = 6.3cm
//speed = 16, steer = 32, time = 2.0, radius = 7.5cm
//speed = 16, steer = 16, time = 3.6, radius = 13.9cm
//speed = 16, steer = 12, time = 5.0, radius = 16.8cm
//speed = 16, steer = 8, time = 8.0, radius = 26.75cm
//speed = 16, steer = 6, time = 12.0, radius = 42.8cm
//speed = 16, steer = 4, time = 18.0, radius = 61.9cm

//speed = 32, steer = 63, time = 1.0, radius = 8.2cm
//speed = 32, steer = 48, time = 1.0, radius = 8.6cm
//speed = 32, steer = 32, time = 1.1, radius = 8.9cm
//speed = 32, steer = 16, time = 1.8, radius = 13.6cm
//speed = 32, steer = 12, time = 2.4, radius = 16.8cm
//speed = 32, steer = 8, time = 3.6, radius = 5.0cm
//speed = 32, steer = 6, time = 6.0, radius = 41.0cm
//speed = 32, steer = 4, time = 9.0, radius = 62.4cm

- (IBAction)movePlease:(id)sender {
    self.movementBit = 1;
}

- (void)simpleMove {
    int speedIndex = 8;
    int steerIndex;

    if (self.reverseBit == 1) {
        self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_FRONT"][speedIndex], microcarCommands[@"NO_STEER"]];
    } else {
        self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_BACK"][speedIndex], microcarCommands[@"STEER_LEFT"][2]];
    }
    
    [NSThread sleepForTimeInterval:3.8f];   //move for 2 sec = 23 cm
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
}

- (void)adjustedMoveWithSteeringIndex:(int)steeringIndex turnRight:(int)turnRight {
    NSString *turn;
    
    if (turnRight == 1) turn = @"STEER_RIGHT";
    else turn = @"STEER_LEFT";
    
    if (self.reverseBit == 1) {
        self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_FRONT"][8], microcarCommands[turn][steeringIndex]];
    } else {
        self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_BACK"][8], microcarCommands[turn][steeringIndex]];
    }
    
    NSLog(@"Changed the steering of the car to: %@ with an index of %d", turn, steeringIndex);
}

- (void)stop {
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
}

//This method spends 10 seconds to build a reference point for the car
- (void)buildReferencePoint {
    CFTimeInterval targetTime = CACurrentMediaTime() + 10.0f;
    CFTimeInterval currentTime;
    
    int frequencyArrayX[200] = {0};
    int frequencyArrayY[200] = {0};
    int maxX = 0;
    int maxY = 0;
    int maxIndexX = 0;
    int maxIndexY = 0;
    
    do {
        NSMutableArray * components = [[self.soundArrayString componentsSeparatedByString:@" "] mutableCopy];
        int currentX = [components[1] intValue];
        int currentY = [components[2] intValue];
        
        frequencyArrayX[currentX + 100]++;
        frequencyArrayY[currentY + 100]++;
        
        currentTime = CACurrentMediaTime();
    } while (currentTime < targetTime);
    
    for (int i = 0; i < 200; i ++) {
        if (maxX < frequencyArrayX[i]) {
            maxX = frequencyArrayX[i];
            maxIndexX = i;
        }
        
        if (maxY < frequencyArrayY[i]) {
            maxY = frequencyArrayY[i];
            maxIndexY = i;
        }
    }
    
    self.referencePoint = [NSString stringWithFormat:@"%@ %@",[@(maxIndexX - 100) stringValue], [@(maxIndexY - 100) stringValue]];
}

- (BOOL)referenceCheckWithArrayData:(NSString *)arrayData {
    BOOL success = false;
    
    NSMutableArray * components = [[self.referencePoint componentsSeparatedByString:@" "] mutableCopy];
    int currentX = [components[0] intValue];
    int currentY = [components[1] intValue];
    
    NSMutableArray * components2 = [[arrayData componentsSeparatedByString:@" "] mutableCopy];
    int currentX2 = [components2[1] intValue];
    int currentY2 = [components2[2] intValue];
    
    if (abs(currentX2 - currentX) < 5 && abs(currentY2 - currentY) < 5) {
        success = true;
    }
    
    return success;
}

/*
- (void)moveCycle {
    int speedIndex;
    int steerIndex;
    float sleepTime;
    
    int xDirection = 0;
    int yDirection = 20;
    
    if (self.reverseBit == -1) {
        yDirection = -20;
    }
    
    if (self.reverseBit == 1 && self.bX != 0.0f) {
        xDirection = self.bX - self.currentX;
    } else if (self.reverseBit == 1 && self.bY != 0.0f) {
        yDirection = self.bY - self.currentY;
    } else if (self.reverseBit == -1 && self.aX != 0.0f) {
        xDirection = self.aX - self.currentX;
    } else if (self.reverseBit == -1 && self.aY != 0.0f) {
        yDirection = self.aY - self.currentY;
    }
    
    NSLog(@"xDirection is: %d" ,xDirection);
    NSLog(@"yDirection is: %d" ,yDirection);
    
    NSMutableDictionary * commands = [self generateCommandsWithDeltaX:xDirection deltaY:yDirection];
    
    speedIndex = [commands[@"SPEED_INDEX"] intValue];
    steerIndex = [commands[@"STEER_INDEX"] intValue];
    sleepTime = [commands[@"SLEEP_TIME"] floatValue];
    
    NSLog(@"Command: move_Please");
    
    NSString * frontOrBack = @"SPEED_FRONT";
    NSString * leftOrRight = @"STEER_RIGHT";
    
    if (speedIndex < 0) {
        speedIndex *= -1;
        frontOrBack = @"SPEED_BACK";
    }
    if (steerIndex < -2) {
        steerIndex += 3; //For calibration purposes, as the car leans towards the left
        steerIndex *= -1;
        leftOrRight = @"STEER_LEFT";
    } else if (steerIndex == -2 || steerIndex == 1) steerIndex = 0;
    
    if (self.reverseBit == -1) {
        leftOrRight = @"STEER_LEFT";
        steerIndex += 1; //Also for calibration purposes
    }
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[frontOrBack][speedIndex],microcarCommands[leftOrRight][steerIndex]];
    
    [NSThread sleepForTimeInterval:sleepTime];
    
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
} */

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
        else if (bytesWritten > 0)
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

-(void) streamThreadMain {
    // Check whether current thread is externally terminated or not.
    while([[NSThread currentThread] isCancelled] == NO) {
        if (self.sendIntermediate != nil) {
            [self initMoveSequence];
        }
        [NSThread sleepForTimeInterval:0.1f];
    }
}

-(void) initHelperThread {
    NSThread *helperThread = [[NSThread alloc] initWithTarget:self selector:@selector(helperThreadMain) object:nil];
    [helperThread start];
}

-(void) helperThreadMain {
    while([[NSThread currentThread] isCancelled] == NO) {
        
        //Execute movement: The movementBit is triggered by a UIButton
        if (self.movementBit == 1) {
            self.sendIntermediate = microcarCommands[@"HORN_ON"];
            
            int cycles = 20;    //no of interations
            
            for (int i = 0; i < cycles; i++) {  //i is the iteration no.
                
                //Sleep for six seconds to let the array detect position
                //In the first iteration of the loop, the six seconds are used to build a reference point
                if (i == 0) [self buildReferencePoint];
                else [NSThread sleepForTimeInterval:10.0f];
                
                //Log the reference point
                NSLog(@"The reference point is: %@", self.referencePoint);
                
                //Print out global destination positions
                NSLog(@"aX is: %f", self.aX);
                NSLog(@"aY is: %f", self.aY);
                NSLog(@"bX is: %f", self.bX);
                NSLog(@"bY is: %f", self.bY);
                
                
                //If there is array data in soundArrayString, execute adjusted movement scripts. Otherwise, default simpleMove
                if (self.soundArrayString != nil) {
                    
                    //On the first iteration, create a reference position that follows the car. Execute simpleMove.
                    if (i == 0) {
                        //NSMutableArray * components = [[self.soundArrayString componentsSeparatedByString:@" "] mutableCopy];
                        //self.aX = [components[1] floatValue];   //The starting position is now hard-coded to (0, 10)
                        //self.aY = [components[2] floatValue];
                        
                        [self simpleMove];
                        
                        //[NSThread sleepForTimeInterval:1.5f];
                        
                        //[self stop];
                        
                    //On the second iteration, save where the car stopped
                    } else if (i == 1) {
                        NSMutableArray * components = [[self.soundArrayString componentsSeparatedByString:@" "] mutableCopy];
                        //self.bX = [components[1] floatValue];     //The end position is hardcoded to 0 on the x axis
                        self.bY = [components[2] floatValue];
                        
                        [self simpleMove];
                        
                        //[NSThread sleepForTimeInterval:1.5f];
                        
                        //[self stop];
                        
                    //From the third iteration on, the car begins to adjust it's movement
                    } else {
                        NSDate *start = [NSDate date];
                        CFTimeInterval startTime = CACurrentMediaTime();
                        
                        NSString *prevString = self.soundArrayString;
                        
                        //Start loop to continuously check position
                        while (1) {
                            //Boolean to determine whether the data extracted from the sound array should be used or not
                            BOOL referenceCheck = false;
                            
                            //Start default value for steering: no steer.
                            int steerIndex = 0;
                            int rightTurn = 1;
                            
                            //Extract data from sound array
                            NSString *currentString = self.soundArrayString;
                            
                            if (![currentString isEqualToString:prevString]) {
                                NSMutableArray * components = [[currentString componentsSeparatedByString:@" "] mutableCopy];
                                //NSLog(@"Components array - x:%@, y:%@", components[1], components[2]);
                                self.currentX = [components[1] floatValue];
                                self.currentY = [components[2] floatValue];
                                
                                //Perform the check against the reference point
                                referenceCheck = [self referenceCheckWithArrayData:currentString];
                                NSLog(@"Reference Check returned: %hhd", referenceCheck);
                                
                                NSLog(@"The Reference Point is currently: %@", self.referencePoint);
                                
                                if (referenceCheck) self.referencePoint = [NSString stringWithFormat:@"%f %f", self.currentX, self.currentY];
                                
                                //If the car is moving forwards
                                if (self.reverseBit == 1 && referenceCheck) {
                                    if ((self.currentX - self.bX) > 0 && (self.currentX - self.bX) <= 4) {
                                        steerIndex = 0; rightTurn = 1;  //2,0, 0,1
                                    } else if ((self.currentX - self.bX) > 4 && (self.currentX - self.bX) <= 8) {
                                        steerIndex = 0; rightTurn = 1;  //2,0, 0,1
                                    } else if ((self.currentX - self.bX) > 8 && (self.currentX - self.bX) <= 12) {
                                        steerIndex = 1; rightTurn = 0;
                                    } else if ((self.currentX - self.bX) > 12 && (self.currentX - self.bX) <= 16) {
                                        steerIndex = 1; rightTurn = 0;
                                    } else if ((self.currentX - self.bX) > 16) {
                                        steerIndex = 2; rightTurn = 0;
                                    } else if ((self.currentX - self.bX) < 0 && (self.currentX - self.bX) >= -4) {
                                        steerIndex = 0; rightTurn = 0;
                                    } else if ((self.currentX - self.bX) < -4 && (self.currentX - self.bX) >= -8) {
                                        steerIndex = 1; rightTurn = 1;
                                    } else if ((self.currentX - self.bX) < -8 && (self.currentX - self.bX) >= -12) {
                                        steerIndex = 2; rightTurn = 1;
                                    } else if ((self.currentX - self.bX) < -12 && (self.currentX - self.bX) >= -16) {
                                        steerIndex = 2; rightTurn = 1;
                                    } else if ((self.currentX - self.bX) < -16) {
                                        steerIndex = 2; rightTurn = 1;
                                    } else if (self.currentX == self.bX) {
                                        steerIndex = 0; rightTurn = 1;
                                    }
                                    /*
                                     if (self.currentX > self.bX) {
                                     steerIndex = 2;
                                     rightTurn = 0;
                                     } else if (self.currentX < self.bX) {
                                     steerIndex = 2;
                                     rightTurn = 1;
                                     } else if (self.currentX == self.bX) {
                                     steerIndex = 0;
                                     rightTurn = 1;
                                     }
                                     */
                                    //if (self.currentY >= self.bY) stopCheck = 0;
                                    //NSLog(@"bY is: %f", self.bY);
                                    
                                    //If the car is moving backwards
                                } else if (self.reverseBit == -1 && referenceCheck) {
                                    if ((self.currentX - self.aX) > 0 && (self.currentX - self.aX) <= 4) {
                                        steerIndex = 2; rightTurn = 0;  //0,0, 1,0 but move more to the left...
                                    } else if ((self.currentX - self.aX) > 4 && (self.currentX - self.aX) <= 8) {
                                        steerIndex = 1; rightTurn = 0;  //0,0
                                    } else if ((self.currentX - self.aX) > 8 && (self.currentX - self.aX) <= 12) {
                                        steerIndex = 0; rightTurn = 0;
                                    } else if ((self.currentX - self.aX) > 12 && (self.currentX - self.aX) <= 16) {
                                        steerIndex = 1; rightTurn = 1;
                                    } else if ((self.currentX - self.aX) > 16) {
                                        steerIndex = 1; rightTurn = 1;
                                    } else if ((self.currentX - self.aX) < 0 && (self.currentX - self.aX) >= -4) {
                                        steerIndex = 0; rightTurn = 1;  //2 //change this lower...
                                    } else if ((self.currentX - self.aX) < -4 && (self.currentX - self.aX) >= -8) {
                                        steerIndex = 1.; rightTurn = 1;
                                    } else if ((self.currentX - self.aX) < -8 && (self.currentX - self.aX) >= -12) {
                                        steerIndex = 1; rightTurn = 1;
                                    } else if ((self.currentX - self.aX) < -12 && (self.currentX - self.aX) >= -16) {
                                        steerIndex = 1; rightTurn = 0;
                                    } else if ((self.currentX - self.aX) < -16) {
                                        steerIndex = 1; rightTurn = 0;
                                    } else if (self.currentX == self.aX) {
                                        steerIndex = 0; rightTurn = 0;
                                    }
                                    /*
                                     if (self.currentX > self.aX) {
                                     steerIndex = 4;
                                     rightTurn = 0;
                                     } else if (self.currentX < self.aX) {
                                     steerIndex = 0;
                                     rightTurn = 1;
                                     } else if (self.currentX == self.aX) {
                                     steerIndex = 2;
                                     rightTurn = 0;
                                     }
                                     */
                                    //if (self.currentY <= self.aY) stopCheck = 0;
                                    //NSLog(@"aY is: %f", self.aY);
                                }
                                
                                //Call function, which affects steering only
                                [self adjustedMoveWithSteeringIndex:steerIndex turnRight:rightTurn];
                                
                                prevString = currentString;
                            }
                            
                            //Calculate elapsed time
                            CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
                            //NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n");
                            //NSLog(@"NSDATE elapsedTime: %lf", elapsedTime);
                            //if ([start timeIntervalSinceNow] >= 1.9) {
                            
                            //Extract sound array data AGAIN, for break conditions (see below)
                            NSMutableArray * components1 = [[self.soundArrayString componentsSeparatedByString:@" "] mutableCopy];
                            NSLog(@"Components array - x:%@, y:%@\n", components1[1], components1[2]);
                            self.currentX = [components1[1] floatValue];
                            self.currentY = [components1[2] floatValue];
                            
                            //Calculate differences. Note: this is currently unused
                            float dbX = fabs(self.currentX - self.bX);
                            float dbY = fabs(self.currentY - self.bY);
                            float daX = fabs(self.currentX - self.aX);
                            float daY = fabs(self.currentY - self.aY);
                            
                            //Break conditions
                            if(self.reverseBit == 1  && self.currentY >= self.bY) break;
                            if(self.reverseBit == -1 && self.currentY <= self.aY) break;
                            //if(self.reverseBit == 1  && (dbX > 0 && dbX <= 4) && (dbY > 0 && dbY <= 4)) break;  //tolerate errors within 4cm
                            //if(self.reverseBit == -1 && (daX > 0 && daX <= 4) && (daY > 0 && daY <= 4)) break;
                            
                            if(elapsedTime >= 5.0)
                                break;
                            
                        } //while
                        self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"NO_SPEED"],microcarCommands[@"NO_STEER"]];
                    }
                } else {
                    NSLog(@"Homo erectus");
                    [self simpleMove];
                }
                
                self.reverseBit*=-1;
            }
            
            self.movementBit = 0;
        }
    }
}

-(NSMutableDictionary *) generateCommandsWithDeltaX:(float)deltaX deltaY:(float)deltaY {
    //Return values needed to add to array
    int steerIndex = 0;
    int speedIndex = 16; //Fixed for now, speed only modifies controlability, turn sharpness is mostly governed by the steerIndex
    float sleepTime = 0.0f;
    
    //Movement flags
    int rightTurnFlag = 1;
    int forwardFlag = 1;
    
    //Find distance to destination
    float displacement = sqrtf(powf(deltaX, 2) + powf(deltaY, 2));
    
    //Calculate the turning angle
    float turningAngle = 0.0;
    
    //No movement
    if (0 == deltaX && 0 == deltaY) turningAngle = 0;
    //Forward
    else if (0 == deltaX && 0 < deltaY) turningAngle = 0;
    //Turn Right
    else if (0 < deltaX && 0 < deltaY) turningAngle = atanf(fabsf(deltaX)/fabsf(deltaY)) * 180.0 / M_PI;
    //Sharp Right
    else if (0 < deltaX && 0 == deltaY) turningAngle = 89;
    //Turn Left
    else if (0 > deltaX && 0 < deltaY) {
        turningAngle = (atanf(fabsf(deltaX)/fabsf(deltaY)) * 180.0 / M_PI);
        rightTurnFlag = 0;
    }
    //Sharp Left
    else if (0 > deltaX && 0 == deltaY) {
        turningAngle = 89;
        rightTurnFlag = 0;
    }
    //Backwards
    else if (0 == deltaX && 0 > deltaY) {
        turningAngle = 0;
        forwardFlag = 0;
    }
    //Backwards Right
    else if (0 < deltaX && 0 > deltaY) {
        turningAngle = (atanf(fabsf(deltaX)/fabsf(deltaY)) * 180.0 / M_PI);
        forwardFlag = 0;
    }
    //Backwards Left
    else if (0 > deltaX && 0 > deltaY) {
        turningAngle = (atanf(fabsf(deltaX)/fabsf(deltaY)) * 180.0 / M_PI);
        forwardFlag = 0;
        rightTurnFlag = 0;
    }
    
    NSLog(@"Turning Angle is: %f", turningAngle);
    
    //Calculate radius of curvature
    
    float radius = 0.0;
    int closeEnough = 1;
    
    while (closeEnough) {
        if (fabsf((sqrtf(powf((deltaX - radius), 2) + powf((deltaY - 0), 2))) - radius) < 1.0) {
            closeEnough = 0;
        }
        radius = radius+0.4;
    }
    
    //Calculate steerIndex
    if (radius > 80.0) {
        NSLog(@"No steering: Radius of curvature is too large!");
        steerIndex = 0.0;
    }
    else {
        NSLog(@"The radius of curvature is: %f", radius);
        steerIndex = (int)(roundf(160/(radius - 4)));
        NSLog(@"The steerIndex is: %d", steerIndex);
    }
    
    //Calculate sleepTime
    //First calculate theta -> the 'slice' of the semicircle the car travels
    if (steerIndex > 0.0) {
        float fractionOfCircle = ((360.0/M_PI) * asinf((displacement/2)/radius))/(180.0);
        
        //It takes radius/3.4 to for the car to travel 1 semicircle. We multiply that by the arc:semicircle ratio
        sleepTime = fractionOfCircle * (radius/3.4);
    } else {
        //Speed 16 is about 14cm/s
        sleepTime = displacement/14.0;
    }
    
    NSMutableDictionary * createdInstructions;
    createdInstructions = [[NSMutableDictionary alloc] init];
    
    if (!forwardFlag) speedIndex = -1*speedIndex;
    NSNumber * speedInd = [NSNumber numberWithInt:(speedIndex)];
    createdInstructions[@"SPEED_INDEX"] = speedInd;
    
    if (!rightTurnFlag) steerIndex = -1*steerIndex;
    NSNumber * steerInd = [NSNumber numberWithInt:(steerIndex)];
    createdInstructions[@"STEER_INDEX"] = steerInd;
    
    NSNumber * time = [NSNumber numberWithFloat:(sleepTime)];
    createdInstructions[@"SLEEP_TIME"] = time;
    
    return createdInstructions;
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


//Sound Array Stuff
- (void) initNetworkCommunication {
    
    NSLog(@"At initNetwork Communication\n");
    CFReadStreamRef readStream;
    
    //HELP!
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.ipAddress, self.portNumber, &readStream, NULL);
    
    inputStream = (__bridge NSInputStream *)readStream;
    [inputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    //NSLog(@"stream event %i", streamEvent);
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            [self tLog:@"Connected!"];
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    
                    if (len > 0) {
                        //output contains the following format: array: distance, angle
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            //[self tLog:[NSString stringWithFormat:@"> %@", output]];    //prints out received messages
                            self.soundArrayString = output;
                            //NSLog(@"soundArrayString %@", self.soundArrayString);
                        }
                    }
                }   //while
            }
            break;
            
        case NSStreamEventErrorOccurred:
            [self tLog:@"Can not conenct to the host!"];
            NSLog(@"Can not connect to the host!"); // why?
            break;
            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
            
        default:
            [self tLog:@"Unknown event. Mwahahahahaha"];
            NSLog(@"Unknown event. At sound array");
    }
}


- (void)tLog:(NSString *) msg {
    self.testTextView.text = [@"\r\n\r\n" stringByAppendingString:self.testTextView.text];
    self.testTextView.text= [msg stringByAppendingString:self.testTextView.text];
}

@end
