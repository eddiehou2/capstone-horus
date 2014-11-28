//
//  GridViewController.m
//  grid2
//
//  Created by valerie chan on 2014-11-21.
//  Copyright (c) 2014 team281. All rights reserved.
//

#import "GridViewController.h"
#import "GridView.h"

@interface GridViewController ()

@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet GridView *gridView;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    //At this point, self.gridWidth and self.gridHeight are set to the values the user has inputted
    NSLog(@"width: %d - height: %d", self.gridWidth, self.gridHeight);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint location = [tapGestureRecognizer locationInView:self.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat pixelsPerPointX = screenWidth/self.gridWidth;
    CGFloat pixelsPerPointY = screenHeight/self.gridHeight;
    CGFloat pointX = location.x/ pixelsPerPointX;
    CGFloat pointY = location.y/ pixelsPerPointY;
    
    NSLog(@"x-coordinate: %.3f\n", pointX);
    NSLog(@"y-coordinate: %.3f\n", pointY);
    
    self.xLabel.text = [NSString stringWithFormat:@"x: %.3f", pointX];
    self.yLabel.text = [NSString stringWithFormat:@"y: %.3f", pointY];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

