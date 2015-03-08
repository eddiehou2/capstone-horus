//
//  AppDelegate.h
//  client
//
//  Created by valerie chan on 2015-01-28.
//  Copyright (c) 2015 team281. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoundArrayClientViewController;

@interface SoundArrayClientAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    SoundArrayClientViewController *viewController;
}

//@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SoundArrayClientViewController *viewController;

@end