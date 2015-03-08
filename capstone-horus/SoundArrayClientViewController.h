//
//  ViewController.h
//  client
//
//  Created by valerie chan on 2015-01-28.
//  Copyright (c) 2015 team281. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface SoundArrayClientViewController : UIViewController <NSStreamDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIView			*joinView;
    UIView			*chatView;
    
    NSInputStream	*inputStream;
    
    UITextField		*inputIPAddressField;
    UITextField		*inputPortNumberField;
    
    UITableView		*tView;     //yes
    NSMutableArray	*messages;  //yes
}
@property (nonatomic) NSString *soundArrayData;

@property (nonatomic, retain) IBOutlet UIView *joinView;
@property (nonatomic, retain) IBOutlet UIView *chatView;

@property (nonatomic, retain) NSInputStream *inputStream;

@property (nonatomic, retain) IBOutlet UITextField *inputIPAddressField;
@property (nonatomic, retain) IBOutlet UITextField *inputPortNumberField;
@property (nonatomic, retain) IBOutlet UIButton *connect;

@property (weak, nonatomic) IBOutlet UITextView *receivingData;
@property (nonatomic, retain) NSMutableArray *messages; //data

@property (nonatomic) NSString *ipAddress;
@property (nonatomic) NSInteger *portNumber;

- (IBAction)connect:(id)sender;

- (void) initNetworkCommunication;
- (void) tLog:(NSString *) msg;
- (void) messageReceived: (NSString *)message;

@end





