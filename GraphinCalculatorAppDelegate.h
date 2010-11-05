//
//  GraphinCalculatorAppDelegate.h
//  GraphinCalculator
//
//  Created by Janis Dancis on 9/8/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GraphView;

@interface GraphinCalculatorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	IBOutlet GraphView *graphView;
	
	IBOutlet NSTextField *rangeX;
	IBOutlet NSTextField *rangeY;
	
	IBOutlet NSTextField *graph1;
	IBOutlet NSTextField *graph2;
	IBOutlet NSTextField *graph3;
	
	IBOutlet NSColorWell *graphColor1;
	IBOutlet NSColorWell *graphColor2;
	IBOutlet NSColorWell *graphColor3;
	
	IBOutlet NSButton *graph1Visible;
	IBOutlet NSButton *graph2Visible;
	IBOutlet NSButton *graph3Visible;
}


@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) IBOutlet GraphView *graphView;

@property (nonatomic, retain) IBOutlet NSTextField *rangeX;
@property (nonatomic, retain) IBOutlet NSTextField *rangeY;

@property (nonatomic, retain) IBOutlet NSTextField *graph1;
@property (nonatomic, retain) IBOutlet NSTextField *graph2;
@property (nonatomic, retain) IBOutlet NSTextField *graph3;

@property (nonatomic, retain) IBOutlet NSColorWell *graphColor1;
@property (nonatomic, retain) IBOutlet NSColorWell *graphColor2;
@property (nonatomic, retain) IBOutlet NSColorWell *graphColor3;

@property (nonatomic, retain) IBOutlet NSButton *graph1Visible, *graph2Visible, *graph3Visible;

-(IBAction) graph:(id)sender;

-(IBAction) newGraph:(id)sender;
-(IBAction) openGraph:(id)sender;
-(IBAction) saveGraph:(id)sender;

-(IBAction) closeWindow:(id)sender;

@end
