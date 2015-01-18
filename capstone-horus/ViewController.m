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
    NSLog(@"Command: move_Please");
    self.sendIntermediate = [NSString stringWithFormat:@"%@ %@",microcarCommands[@"SPEED_FRONT"][10],microcarCommands[@"STEER_RIGHT"][10]];
    [NSThread sleepForTimeInterval:2.0f];
    
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
        self.sendIntermediate = microcarCommands[@"STEER_RIGHT"][10];
    }
    else if (self.steerSlider.value < self.steerSlider.maximumValue/2) {
        NSLog(@"Command: STEER_LEFT");
        self.sendIntermediate = microcarCommands[@"STEER_LEFT"][10];
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
        self.sendIntermediate = microcarCommands[@"SPEED_FRONT"][10];
    }
    else if (self.speedSlider.value < self.speedSlider.maximumValue/2) {
        NSLog(@"Command: SPEED_BACK");
        self.sendIntermediate = microcarCommands[@"SPEED_BACK"][10];
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
    
    NSArray *steerLeft = @[@"817F",@"817E",@"817D",@"817C",@"817B",@"817A",@"8179",@"8178",@"8177",@"8176",@"8175",@"8174",@"8173",@"8172",@"8171",@"8170",@"816F",@"816E",@"816D",@"816C",@"816B",@"816A",@"8169",@"8168",@"8167",@"8166",@"8165",@"8164",@"8163",@"8162",@"8161",@"8160",@"815F",@"815E",@"815D",@"815C",@"815B",@"815A",@"8159",@"8158",@"8157",@"8156",@"8155",@"8154",@"8153",@"8152",@"8151",@"8150",@"814F",@"814E",@"814D",@"814C",@"814B",@"814A",@"8149",@"8148",@"8147",@"8146",@"8145",@"8144",@"8143",@"8142",@"8141"];
    
    NSArray *steerRight = @[@"8100",@"8101",@"8102",@"8103",@"8104",@"8105",@"8106",@"8107",@"8108",@"8109",@"810A",@"810B",@"810C",@"810D",@"810E",@"810F",@"8110",@"8111",@"8112",@"8113",@"8114",@"8115",@"8116",@"8117",@"8118",@"8119",@"811A",@"811B",@"811C",@"811D",@"811E",@"811F",@"8120",@"8121",@"8122",@"8123",@"8124",@"8125",@"8126",@"8127",@"8128",@"8129",@"812A",@"812B",@"812C",@"812D",@"812E",@"812F",@"8130",@"8131",@"8132",@"8133",@"8134",@"8135",@"8136",@"8137",@"8138",@"8139",@"813A",@"813B",@"813C",@"813D",@"813E",@"813F"];
    
    microcarCommands[@"STEER_LEFT"] = steerLeft;
    microcarCommands[@"STEER_RIGHT"] = steerRight;
    
    NSArray *speedBack = @[@"827F",@"827E",@"827D",@"827C",@"827B",@"827A",@"8279",@"8278",@"8277",@"8276",@"8275",@"8274",@"8273",@"8272",@"8271",@"8270",@"826F",@"826E",@"826D",@"826C",@"826B",@"826A",@"8269",@"8268",@"8267",@"8266",@"8265",@"8264",@"8263",@"8262",@"8261",@"8260",@"825F",@"825E",@"825D",@"825C",@"825B",@"825A",@"8259",@"8258",@"8257",@"8256",@"8255",@"8254",@"8253",@"8252",@"8251",@"8250",@"824F",@"824E",@"824D",@"824C",@"824B",@"824A",@"8249",@"8248",@"8247",@"8246",@"8245",@"8244",@"8243",@"8242",@"8241"];
    
    NSArray *speedFront = @[@"8200",@"8201",@"8202",@"8203",@"8204",@"8205",@"8206",@"8207",@"8208",@"8209",@"820A",@"820B",@"820C",@"820D",@"820E",@"820F",@"8210",@"8211",@"8212",@"8213",@"8214",@"8215",@"8216",@"8217",@"8218",@"8219",@"821A",@"821B",@"821C",@"821D",@"821E",@"821F",@"8220",@"8221",@"8222",@"8223",@"8224",@"8225",@"8226",@"8227",@"8228",@"8229",@"822A",@"822B",@"822C",@"822D",@"822E",@"822F",@"8230",@"8231",@"8232",@"8233",@"8234",@"8235",@"8236",@"8237",@"8238",@"8239",@"823A",@"823B",@"823C",@"823D",@"823E",@"823F"];
    
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
