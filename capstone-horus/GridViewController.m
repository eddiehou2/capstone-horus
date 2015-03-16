//
//  GridViewController.m
//  capstone-horus
//
//  Created by valerie chan on 2015-03-16.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController

@synthesize graph;
@synthesize scatterPlot;
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //At this point, self.gridWidth and self.gridHeight are set to the values the user has inputted
    NSLog(@"width: %d - height: %d\n", self.gridWidth, self.gridHeight);
    
    
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:hostView];
    
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    graph.paddingLeft = 20.0;
    graph.paddingTop = 20.0;
    graph.paddingRight = 20.0;
    graph.paddingBottom = 20.0;
    
    self.plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    if(self.gridWidth %2 != 0)
        self.gridWidth++;
    if(self.gridHeight %2 != 0)
        self.gridHeight++;
    
    float minX = (self.gridWidth/2)*(-1);
    float minY = (self.gridHeight/2)*(-1);
    NSLog(@"minX: %lf, minY: %lf\n", minX, minY);
    
    [self.plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minX) length:CPTDecimalFromFloat(self.gridWidth)]]; //change
    [self.plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(self.gridHeight)]];  //change
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTMutableLineStyle *lineStyle = [CPTLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    axisSet.xAxis.majorIntervalLength = [[NSDecimalNumber decimalNumberWithString:@"5"] decimalValue];
    axisSet.xAxis.minorTicksPerInterval = 4;        //change
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    
    axisSet.yAxis.majorIntervalLength = [[NSDecimalNumber decimalNumberWithString:@"5"] decimalValue];
    axisSet.yAxis.minorTicksPerInterval = 4;        //change
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    
    self.scatterPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    [graph addPlot:self.scatterPlot toPlotSpace:graph.defaultPlotSpace];
    
    [self.scatterPlot setDelegate:self];
    [self.scatterPlot setDataSource:self];
    [self.plotSpace setDelegate:self];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - CPTScatterPlotDataSource Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    return 100;      //change
    
}


//don't plot anything
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    
    return nil;
    
}



//http://stackoverflow.com/questions/10406539/core-plot-how-to-convert-touch-point-to-plot-point-in-a-plot-space-with-log-ax

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(UIEvent *)event atPoint:(CGPoint)point {
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)space;
    
    CPTScatterPlot *scatterPlot = [[[plotSpace graph] allPlots] objectAtIndex:0];
    CGPoint plotAreaPoint = [[plotSpace graph] convertPoint:point toLayer:scatterPlot];
    
    NSLog(@"PlotAreaPoint : %.1f, %.1f", plotAreaPoint.x, plotAreaPoint.y);
    
    NSDecimal dataPoint[2];
    NSDecimalNumber *xCoordinate, *yCoordinate;
    
    [plotSpace plotPoint:dataPoint forPlotAreaViewPoint:plotAreaPoint];
    
    xCoordinate = [NSDecimalNumber decimalNumberWithDecimal:dataPoint[0]];
    yCoordinate = [NSDecimalNumber decimalNumberWithDecimal:dataPoint[1]];
    
    NSLog(@"DataPoint : %.1f, %.1f", [xCoordinate floatValue], [yCoordinate floatValue]);
    
    //draw the symbol
    CGPoint plotPoint;
    plotPoint.x = [xCoordinate floatValue];
    plotPoint.y = [yCoordinate floatValue];
    
    CPTPlotSymbol *greenCirclePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    greenCirclePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    self.scatterPlot.plotSymbol = greenCirclePlotSymbol;
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //[greenCirclePlotSymbol renderAsVectorInContext:<#(CGContextRef)#> atPoint:<#(CGPoint)#> scale:<#(CGFloat)#>]
    //[greenCirclePlotSymbol renderAsVectorInContext:context atPoint:plotPoint scale:1.0f];
    
    return YES;
    
}

@end


//animation
//(CPTAnimationOperation *) 	+ animate:property:fromPoint:toPoint:duration:withDelay:animationCurve:delegate:
//(CPTAnimationOperation *) 	+ animate:property:fromPoint:toPoint:duration:animationCurve:delegate:
//(CPTAnimationOperation *) 	+ animate:property:fromPoint:toPoint:duration:

