//
//  GridViewController.h
//  capstone-horus
//
//  Created by valerie chan on 2015-03-16.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot-CocoaTouch.h>

@interface GridViewController : UIViewController <CPTAnimationDelegate, CPTAxisDelegate, CPTResponder, CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource>

@property (nonatomic) NSInteger gridWidth;
@property (nonatomic) NSInteger gridHeight;

@property (nonatomic, strong) CPTGraph *graph;
@property (nonatomic, strong) CPTScatterPlot *scatterPlot;
@property (nonatomic, strong) CPTXYPlotSpace *plotSpace;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
