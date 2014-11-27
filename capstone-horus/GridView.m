//
//  BackgroundView.m
//  grid2
//
//  Created by valerie chan on 2014-11-21.
//  Copyright (c) 2014 team281. All rights reserved.
//

#import "GridView.h"
#import <math.h>


@implementation GridView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //get multiple of the height and width from the screen size
    CGFloat temp = CGRectGetWidth(self.bounds); //gives us size of screen
    
    CGFloat width = CGRectGetWidth(self.bounds);    //extract width and height of out view's bounds
    CGFloat height = CGRectGetHeight(self.bounds);
    
    UIBezierPath *path = [UIBezierPath bezierPath]; //draws lines
    path.lineWidth = self.gridLineWidth;          //set the line's width
    
    CGFloat x = self.gridXOffset;
    while (x <= width)                  //create a line every 20 points, both horizontally and vertically
    {
        [path moveToPoint:CGPointMake(x, 0.0)];     //moving cursor to beginning of first line
        [path addLineToPoint:CGPointMake(x, height)];   //adding line to the path
        x += self.gridSpacing;
    }
    
    CGFloat y = self.gridYOffset;
    while (y <= height)
    {
        [path moveToPoint:CGPointMake(0.0, y)];
        [path addLineToPoint:CGPointMake(width, y)];
        y += self.gridSpacing;
    }
    
    [self.gridLineColor setStroke];
    [path stroke];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setDefaults
{
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    
    //spacing for x and y must adjust...
    
    self.gridSpacing = 20.0;    //just change this when we get width and height this was the original...
    //conversion between points and pixels - UIScreen, UIView, UIImage, CALaayer
    //Vector-based drawings - UIBezierPath, CGPathRef
    
    if (self.contentScaleFactor == 2.0)
    {
        self.gridLineWidth = 0.5;
        self.gridXOffset = 0.25;
        self.gridYOffset = 0.25;
    }
    else
    {
        self.gridLineWidth = 1.0;       //1 pixel wide
        self.gridXOffset = 0.5;
        self.gridYOffset = 0.5;
    }
    
    self.gridLineColor = [UIColor lightGrayColor];
}




@end
