//
//  GraphinCalculatorAppDelegate.m
//  GraphinCalculator
//
//  Created by Janis Dancis on 9/8/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import "GraphinCalculatorAppDelegate.h"

#import "GraphView.h"

@implementation GraphinCalculatorAppDelegate

@synthesize window, graphView, rangeX, rangeY, graph1, graph2, graph3, graphColor1, graphColor2, graphColor3;
@synthesize graph1Visible,graph2Visible,graph3Visible;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newGraph:nil];
}

-(void) dealloc {
	[graphView release];
	
	[rangeX release];
	[rangeY release];
	
	[graph1 release];
	[graph2 release];
	[graph3 release];
	
	[graphColor1 release];
	[graphColor2 release];
	[graphColor3 release];
	
	[graph1Visible release];
	[graph2Visible release];
	[graph3Visible release];
	
	[super dealloc];
}

-(IBAction) newGraph:(id)sender {
	// reset fields
	[rangeX setFloatValue:5];
	[rangeY setFloatValue:2];
	
	[graph1 setStringValue:@""];
	[graph2 setStringValue:@""];
	[graph3 setStringValue:@""];
	
	[self graph:nil];
}

-(IBAction) graph:(id)sender {
	NSLog(@"redrawing graph");
	
	// update graph
	graphView.rangeX = [rangeX floatValue];
	graphView.rangeY = [rangeY floatValue];
	
	[graphView.graphs removeAllObjects];
	[graphView.graphs setObject:[graph1 stringValue] forKey:@"y1"];
	[graphView.graphs setObject:[graph2 stringValue] forKey:@"y2"];
	[graphView.graphs setObject:[graph3 stringValue] forKey:@"y3"];

	[graphView.graphColors setObject:[graphColor1 color] forKey:@"y1"];
	[graphView.graphColors setObject:[graphColor2 color] forKey:@"y2"];
	[graphView.graphColors setObject:[graphColor3 color] forKey:@"y3"];
	
	graphView.graph1Visible = (graph1Visible.state==NSOnState);
	graphView.graph2Visible = (graph2Visible.state==NSOnState);
	graphView.graph3Visible = (graph3Visible.state==NSOnState);
	
	[graphView setNeedsDisplay:YES];
}

-(IBAction) openGraph:(id)sender {
	UInt32 filePos = 0;
	NSOpenPanel *op;
	int runResult;
	
	op = [NSOpenPanel openPanel];
	/* set up new attributes */
	[op setRequiredFileType:@"hgc"];
	
	runResult = [op runModalForDirectory:NSHomeDirectory() file:@""];
	if (runResult == NSOKButton) {
		NSData *data = [NSData dataWithContentsOfFile:[op filename]]; 
		// read data range
		Float32 fRangeX = 0;
		Float32 fRangeY = 0;
		[data getBytes:&fRangeX range:NSMakeRange(filePos, sizeof(Float32))];
		filePos += sizeof(Float32);
		[data getBytes:&fRangeY range:NSMakeRange(filePos, sizeof(Float32))];
		filePos += sizeof(Float32);
		[rangeX setFloatValue:fRangeX];
		[rangeY setFloatValue:fRangeY];
		
		// read formulas header
		UInt32 formulaLengths[3];
		memset(formulaLengths, 0, sizeof(formulaLengths));
		[data getBytes:formulaLengths range:NSMakeRange(filePos, sizeof(formulaLengths))];
		filePos += sizeof(formulaLengths);
		
		// read formulas
		for (int i=0; i< 3; ++i) {
			UInt32 dataLength = formulaLengths[i];
			if (dataLength==0)
				continue;
			char *bytes = malloc(dataLength);
			[data getBytes:bytes range:NSMakeRange(filePos, dataLength)];
//			NSString *formula = [NSString stringWithCharacters:bytes length:dataLength];
			NSString *formula = [NSString stringWithUTF8String:bytes];
			NSLog(@"%d, read formula:%@ ", i, formula);
			
			switch(i) {
				case 0: [graph1 setStringValue:formula]; break;
				case 1: [graph2 setStringValue:formula]; break;
				case 2: [graph3 setStringValue:formula]; break;
			}
			filePos += formulaLengths[i];
			free(bytes);
		}
		[data release];
	}
	
	[self graph:nil];
}



-(IBAction) saveGraph:(id)sender {
	NSSavePanel *sp;
	int runResult;
	
	/* create or get the shared instance of NSSavePanel */
	sp = [NSSavePanel savePanel];
	/* set up new attributes */
	[sp setRequiredFileType:@"hgc"];
	
	runResult = [sp runModalForDirectory:NSHomeDirectory() file:@""];
	
	//	[outArr 
	NSMutableData *outContents = [NSMutableData data];
	Float32 fRangeX = rangeX.floatValue;
	Float32 fRangeY = rangeY.floatValue;
	[outContents appendBytes:&fRangeX length:sizeof(Float32)];
	[outContents appendBytes:&fRangeY length:sizeof(Float32)];
	
	NSArray *arr = [NSArray arrayWithObjects:[graph1 stringValue], [graph2 stringValue], [graph3 stringValue], nil];
	NSEnumerator *objEnum = [arr objectEnumerator];
	NSString *formula = nil;
	UInt32 formulaLengths[3];
	memset(formulaLengths, 0, sizeof(formulaLengths));
	NSMutableData *formulaData = [NSMutableData data];
	UInt32 idx = 0;
	while (formula = [objEnum nextObject]) {
		// write formula to file
		formulaLengths[idx] = strlen([formula UTF8String]);
		[formulaData appendBytes:[formula UTF8String] length:formulaLengths[idx]];
		++idx;
	}	
	
	[outContents appendBytes:formulaLengths length:sizeof(formulaLengths)];
	[outContents appendData:formulaData];
	
	/* if successful, save file under designated name */
	if (runResult == NSOKButton) {
		if (![outContents writeToFile:[sp filename] atomically:YES])
			NSBeep();
	}
	
	[self graph:nil];
}

-(IBAction) closeWindow:(id)sender {
	// terminate app
}

@end
