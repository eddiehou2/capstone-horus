//
//  BackgroundView.h
//  grid2
//
//  Created by valerie chan on 2014-11-21.
//  Copyright (c) 2014 team281. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView

@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;

@property (assign, nonatomic) CGFloat gridSpacing;
@property (assign, nonatomic) CGFloat gridLineWidth;
@property (assign, nonatomic) CGFloat gridXOffset;
@property (assign, nonatomic) CGFloat gridYOffset;
@property (strong, nonatomic) UIColor *gridLineColor;

- (id)initWithGridWidth:(NSString *)width initWithGridHeight:(NSString *)height;

@end


