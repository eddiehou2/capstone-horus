//
//  ViewController.m
//  client
//
//  Created by valerie chan on 2015-01-28.
//  Copyright (c) 2015 team281. All rights reserved.
//

#import "SoundArrayClientViewController.h"
#import "ViewController.h"

@implementation SoundArrayClientViewController

@synthesize joinView, chatView;
@synthesize inputStream;
@synthesize inputIPAddressField, inputPortNumberField;
@synthesize messages;
@synthesize receivingData;

@synthesize ipAddress;
@synthesize portNumber;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *viewController = segue.destinationViewController;
    viewController.soundArrayString = self.soundArrayData;
    viewController.ipAddress = self.ipAddress;
    viewController.portNumber = self.portNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    
}


//Let's start! IkimashO!
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

- (IBAction)connect:(id)sender {
    self.receivingData.text = @"";
    
    self.ipAddress = self.inputIPAddressField.text;
    self.portNumber = [self.inputPortNumberField.text integerValue];
    
    [self.inputIPAddressField resignFirstResponder];    //test
    [self.inputPortNumberField resignFirstResponder];   //test
    
    [self tLog:[NSString stringWithFormat:@"Connecting to IP Address: %@, Port Number: %d", self.ipAddress, self.portNumber]];
    [self initNetworkCommunication];
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %i", streamEvent);
    
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
                            NSLog(@"server said: %@", output);
                            [self tLog:[NSString stringWithFormat:@"> %@", output]];    //prints out received messages
                            self.soundArrayData = output;
                        }
                    }
                }   //while
            }
            break;
            
        case NSStreamEventErrorOccurred:
            [self tLog:@"Can not conenct to the host!"];
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
            
        default:
            [self tLog:@"Unknown event. Mwahahahahaha"];
            NSLog(@"Unknown event");
    }
}


- (void)tLog:(NSString *) msg {
    self.receivingData.text = [@"\r\n\r\n" stringByAppendingString:self.receivingData.text];
    self.receivingData.text= [msg stringByAppendingString:self.receivingData.text];
}



@end
