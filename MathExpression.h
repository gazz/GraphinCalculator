//
//  MathExpression.h
//  FunctionParser
//
//  Created by Janis Dancis on 9/9/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum {
	Sine = 0,
	Cosine,
	Tangent,
	Cotangent,
	Expression,
	Abs,
	Min,
	Max
} typedef MathFunctionType;


@interface MathExpression : NSObject {
	NSArray *members;	// can contain variable, value, operand or subexpression
}

+(id) expressionWithFormula:(NSString*)formula;
+(id) expressionWithTokens:(NSArray*)tokens;

-(id) initWithFormula:(NSString*)formula;
-(id) initWithTokens:(NSArray*)tokens;

//-(float) evaluate:(NSDictionary*)parameters;
-(NSObject*) evaluate:(NSDictionary*)parameters;
-(NSObject*) performOperand:(NSString*)operand withA:(NSObject*)a andB:(NSObject*)b;
-(Float32) scanFloat:(NSString*)input;

@end


@interface MathFunction : NSObject {
	MathFunctionType type;
	MathExpression *expression;
}

@property (nonatomic, retain) MathExpression *expression;

+(MathFunction*) functionWithExpression:(MathExpression*)expression;
+(MathFunction*) functionWithType:(MathFunctionType)type;
+(MathFunction*) sine;
+(MathFunction*) cosine;
+(MathFunction*) tangent;
+(MathFunction*) cotangent;
+(MathFunction*) abs;
+(MathFunction*) min;
+(MathFunction*) max;

-(id) initWithType:(MathFunctionType)type;
-(id) initWithExpression:(MathExpression*)expression;

-(NSObject*) evaluate:(NSObject*)input withParams:(NSDictionary*)params;

@end



@interface ComplexParam : NSObject {
	NSArray *items;
}

@property (nonatomic, retain) NSArray *items;

+(id) paramWithItems:(NSArray*)values;
-(id) initWithItems:(NSArray*)values;

@end
