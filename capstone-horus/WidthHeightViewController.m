//
//  WidthHeightViewController.m
//  capstone-horus
//
//  Created by valerie chan on 2015-03-16.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "WidthHeightViewController.h"
#import "GridViewController.h"

@interface WidthHeightViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tv_width;
@property (weak, nonatomic) IBOutlet UITextField *tv_height;

@end

@implementation WidthHeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    GridViewController *gridViewController = segue.destinationViewController;
    gridViewController.gridWidth = [self.tv_width.text intValue];
    gridViewController.gridHeight = [self.tv_height.text intValue];
    
}


@end
