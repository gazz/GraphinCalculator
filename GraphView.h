//
//  GraphView.h
//  GraphinCalculator
//
//  Created by Janis Dancis on 9/8/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GraphView : NSView {
	float rangeX, rangeY;
	
	NSMutableDictionary *graphs;
	NSMutableDictionary *graphColors;
	
	BOOL graph1Visible,graph2Visible,graph3Visible;
}

@property float rangeX, rangeY;
@property BOOL graph1Visible, graph2Visible, graph3Visible;
@property (nonatomic, retain) NSMutableDictionary *graphs;
@property (nonatomic, retain) NSMutableDictionary *graphColors;

@end
