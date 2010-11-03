//
//  GraphView.m
//  GraphinCalculator
//
//  Created by Janis Dancis on 9/8/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import "GraphView.h"
#import "MathExpression.h"


#define HORIZONTAL_TICKS 10
#define VERTICAL_TICKS 10
#define TICK_LENGTH 10
#define LINE_WIDTH 1

@implementation GraphView

@synthesize rangeX, rangeY, graphs, graphColors;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.graphs = [NSMutableDictionary dictionary];
		self.graphColors = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	
	// Drawing code here.
	[[NSColor lightGrayColor] set];
	NSRectFill(dirtyRect);
	
	NSRect frame = self.bounds;
	
	[[NSColor darkGrayColor] set];
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:LINE_WIDTH];
	[thePath moveToPoint:NSMakePoint(frame.size.width/2, 0)];
	[thePath lineToPoint:NSMakePoint(frame.size.width/2, frame.size.height)];
	[thePath stroke];

	[thePath moveToPoint:NSMakePoint(0, frame.size.height/2)];
	[thePath lineToPoint:NSMakePoint(frame.size.width, frame.size.height/2)];
	[thePath stroke];
	
	// draw ticks
	float horStep = frame.size.width / HORIZONTAL_TICKS;
	float horValStep = (rangeX*2) / HORIZONTAL_TICKS;
	for (int i=0; i< HORIZONTAL_TICKS; i++) {
		float x = horStep * i;
		float y = frame.size.height/2 -TICK_LENGTH/2;
		float val = i * horValStep - rangeX;
		
		[thePath moveToPoint:NSMakePoint(x, y)];
		[thePath lineToPoint:NSMakePoint(x, y+TICK_LENGTH)];
		[thePath stroke];
		
		NSString *str = [NSString stringWithFormat:@"%.1f", val]; 
		[str drawAtPoint:NSMakePoint(x-7, y-15) withAttributes:nil];
	}

	float vertStep = frame.size.height / VERTICAL_TICKS;
	float vertValStep = (rangeY*2) / VERTICAL_TICKS;
	for (int i=0; i< VERTICAL_TICKS; i++) {
		float x = frame.size.width/2 -TICK_LENGTH/2;
		float y = vertStep*i; ;
		float val = i * vertValStep - rangeY;
		
		[thePath moveToPoint:NSMakePoint(x, y)];
		[thePath lineToPoint:NSMakePoint(x+TICK_LENGTH, y)];
		[thePath stroke];
		
		NSString *str = [NSString stringWithFormat:@"%.1f", val]; 
		[str drawAtPoint:NSMakePoint(x+10, y) withAttributes:nil];
	}
		
	// draw graphs
	NSString *key = nil;
	NSEnumerator *keyEnumerator = [graphs keyEnumerator];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	while (key = [keyEnumerator nextObject])
	{
		if ([graphs objectForKey:key] && [[graphs objectForKey:key] length]>0) {
			[params setObject:[MathFunction functionWithExpression:[MathExpression expressionWithFormula:[graphs objectForKey:key]]] forKey:key];
		}
	}
	
	// draw functions
	Float32 xStep = rangeX *2 /frame.size.width;
//	NSLog(@"xStep: %f", xStep);
	
	keyEnumerator = [graphs keyEnumerator];
	while (key = [keyEnumerator nextObject])
	{
		if ([graphs objectForKey:key] && [[graphs objectForKey:key] length]>0) {
			[[graphColors objectForKey:key] set];
//			[[NSColor blueColor] set];
			
			MathExpression *expr = [MathExpression expressionWithFormula:[graphs objectForKey:key]];
			[params setObject:[NSNumber numberWithFloat:-rangeX] forKey:@"x"];
			
			NSBezierPath* funcPath = [NSBezierPath bezierPath];
			[funcPath setLineWidth:LINE_WIDTH];

			float exprValue = [(NSNumber*)[expr evaluate:params] floatValue];
			Float32 yValue = frame.size.height/2 + exprValue * frame.size.height/2/rangeY;
			[funcPath moveToPoint:NSMakePoint(-rangeX, yValue)];
			
			for (UInt32 pixel = 0; pixel < frame.size.width; ++pixel) {
				Float32 x = pixel *xStep - rangeX;
				[params setObject:[NSNumber numberWithFloat:x] forKey:@"x"];

				exprValue = [(NSNumber*)[expr evaluate:params] floatValue];
				yValue = frame.size.height/2 + exprValue * frame.size.height/2/rangeY;
				[funcPath lineToPoint:NSMakePoint(pixel, yValue)];
				[funcPath stroke];
				
			}
		}
	}
}

-(void) dealloc {
	[graphs release];
	[graphColors release];
	[super dealloc];
}

@end


