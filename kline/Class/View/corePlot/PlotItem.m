//
//  PlotItem.m
//  CorePlotGallery
//

#import "PlotGallery.h"


#import <tgmath.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
// For IKImageBrowser
#import <Quartz/Quartz.h>
#endif

NSString *const kDemoPlots      = @"Demos";
NSString *const kPieCharts      = @"Pie Charts";
NSString *const kLinePlots      = @"Line Plots";
NSString *const kBarPlots       = @"Bar Plots";
NSString *const kFinancialPlots = @"Financial Plots";

@interface PlotItem()

@property (nonatomic, readwrite, strong) CPTNativeImage *cachedImage;

@end

#pragma mark -

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize section;
@synthesize title;
@synthesize cachedImage;
@dynamic titleSize;


-(id)init
{
    
    if ( (self = [super init]) ) {
        
        defaultLayerHostingView = nil;
        graphs  = [[NSMutableArray alloc] init];
        section = nil;
        title   = nil;
        
    }

    return self;
}


-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)hostingView
{
    
    [self.graphs addObject:graph];

    if ( hostingView ) {
        hostingView.hostedGraph = graph;
    }
}

-(void)addGraph:(CPTGraph *)graph
{
    [self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
    
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];

    // Remove the CPTLayerHostingView
    CPTGraphHostingView *hostingView = self.defaultLayerHostingView;
    if ( hostingView ) {
        [hostingView removeFromSuperview];

        hostingView.hostedGraph      = nil;
        self.defaultLayerHostingView = nil;
    }

    self.cachedImage = nil;

    [self.graphs removeAllObjects];
}

-(void)dealloc
{
    [self killGraph];
}

// override to generate data for the plot if needed
-(void)generateData
{

    
}

-(NSComparisonResult)titleCompare:(PlotItem *)other
{
    
    
    NSComparisonResult comparisonResult = [self.section caseInsensitiveCompare:other.section];

    if ( comparisonResult == NSOrderedSame ) {
        comparisonResult = [self.title caseInsensitiveCompare:other.title];
    }

    return comparisonResult;
}

-(CGFloat)titleSize
{
    
    
    CGFloat size;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    switch ( UI_USER_INTERFACE_IDIOM() ) {
        case UIUserInterfaceIdiomPad:
            size = 24.0;
            break;

        case UIUserInterfaceIdiomPhone:
            size = 16.0;
            break;

        default:
            size = 12.0;
            break;
    }
#else
    size = 24.0;
#endif

    return size;
}

-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph
{
    
    
    CGFloat boundsPadding = self.titleSize;

    graph.paddingLeft = boundsPadding;

    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * CPTFloat(2.0);
    }
    else {
        graph.paddingTop = boundsPadding;
    }

    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}

-(void)formatAllGraphs
{

    CGFloat graphTitleSize = self.titleSize;

    for ( CPTGraph *graph in self.graphs ) {
        // Title
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color    = [CPTColor grayColor];
        textStyle.fontName = @"Helvetica-Bold";
        textStyle.fontSize = graphTitleSize;

        graph.title                    = (self.graphs.count == 1 ? self.title : nil);
        graph.titleTextStyle           = textStyle;
        graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

        // Padding
        CGFloat boundsPadding = graphTitleSize;
        graph.paddingLeft = boundsPadding;

        if ( graph.title.length > 0 ) {
            graph.paddingTop = MAX(graph.titleTextStyle.fontSize * CPTFloat(2.0), boundsPadding)+5;
        }
        else {
            graph.paddingTop = boundsPadding;
        }

        graph.paddingRight  = boundsPadding;
        graph.paddingBottom = boundsPadding;

        // Axis labels
        CGFloat axisTitleSize = graphTitleSize * CPTFloat(0.75);
        CGFloat labelSize     = graphTitleSize * CPTFloat(0.5);

        for ( CPTAxis *axis in graph.axisSet.axes ) {
            // Axis title
            textStyle           = [axis.titleTextStyle mutableCopy];
            textStyle.fontSize  = axisTitleSize;

            axis.titleTextStyle = textStyle;

            // Axis labels
            textStyle           = [axis.labelTextStyle mutableCopy];
            textStyle.fontSize  = labelSize;

            axis.labelTextStyle = textStyle;

            textStyle           = [axis.minorTickLabelTextStyle mutableCopy];
            textStyle.fontSize  = labelSize;

            axis.minorTickLabelTextStyle = textStyle;
        }

        // Plot labels
        for ( CPTPlot *plot in graph.allPlots ) {
            textStyle          = [plot.labelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;

            plot.labelTextStyle = textStyle;
        }

        // Legend
        CPTLegend *theLegend = graph.legend;
        textStyle            = [theLegend.textStyle mutableCopy];
        textStyle.fontSize   = labelSize;

        theLegend.textStyle  = textStyle;
        theLegend.swatchSize = CGSizeMake( labelSize * CPTFloat(1.5), labelSize * CPTFloat(1.5) );

        theLegend.rowMargin    = labelSize * CPTFloat(0.75);
        theLegend.columnMargin = labelSize * CPTFloat(0.75);

        theLegend.paddingLeft   = labelSize * CPTFloat(0.375);
        theLegend.paddingTop    = labelSize * CPTFloat(0.375);
        theLegend.paddingRight  = labelSize * CPTFloat(0.375);
        theLegend.paddingBottom = labelSize * CPTFloat(0.375);
    }
}


-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size
{
    
}
#endif

-(void)renderInView:(PlotGalleryNativeView *)inView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    
    [self killGraph];

    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 64, inView.frame.size.width, inView.frame.size.height-64)];
    [inView addSubview:hostingView];

    
    [self generateData];
    [self renderInGraphHostingView:hostingView withTheme:theme animated:animated];

    [self formatAllGraphs];

    self.defaultLayerHostingView = hostingView;
}

- (void)panGesture
{
    [self killGraph];
    
    [self generateData];
    
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
    
    for ( CPTGraph *graph in self.graphs ) {
        [graph reloadData];
    }
}

#pragma mark -
#pragma mark IKImageBrowserItem methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(NSString *)imageUID
{
    return self.title;
}

-(NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

-(id)imageRepresentation
{
    return [self image];
}

-(NSString *)imageTitle
{
    return self.title;
}
#endif

@end
