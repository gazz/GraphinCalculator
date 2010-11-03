//
//  MathExpression.m
//  FunctionParser
//
//  Created by Janis Dancis on 9/9/10.
//  Copyright 2010 Twizt. All rights reserved.
//

#import "MathExpression.h"


@implementation MathExpression

+(id) expressionWithFormula:(NSString*)formula {
	return [[[MathExpression alloc] initWithFormula:formula] autorelease];
}


+(id) expressionWithTokens:(NSArray*)tokens {
	return [[[MathExpression alloc] initWithTokens:tokens] autorelease];
}

-(id) initWithFormula:(NSString*)formula {
	if ([super init]) {
		NSMutableArray *tokens = [NSMutableArray array];
		
		CFRange range = CFRangeMake(0, [formula length]);
		CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, 
																 (CFStringRef)formula, range, kCFStringTokenizerUnitWordBoundary, CFLocaleCopyCurrent());
		CFStringTokenizerAdvanceToNextToken(tokenizer);
		
		while (1) {
			CFRange r = CFStringTokenizerGetCurrentTokenRange(tokenizer);
			if (r.location == kCFNotFound && r.length == 0) 
				break;
			NSString *token = [formula substringWithRange: NSMakeRange(r.location, r.length)];
			token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
			if ([token length]!=0) 
				[tokens addObject:token];				
			CFStringTokenizerAdvanceToNextToken(tokenizer);
		}
		
		[self initWithTokens:tokens];
	}	
	return self;
}

-(id) initWithTokens:(NSArray*)tokens {
	if ([super init]) {
		NSMutableArray *_members = [NSMutableArray array];
		BOOL isComplex = NO;
		// parse tokens
		for (int i=0; i< tokens.count; ++i) {
			NSString *token = [tokens objectAtIndex:i];
			UInt32 blockStartIndex = 0;
			UInt32 blocksOpen = 0;
			if ([token isEqualToString:@"("]) {
				// there is subrange
				blockStartIndex = i;
				// search for end
				for (int j = blockStartIndex; j < tokens.count; j++) {
					NSString *token = [tokens objectAtIndex:j];
					if ([token isEqualToString:@"("])
						++blocksOpen;
					else if ([token isEqualToString:@")"])
						--blocksOpen;
					// check if we have closed block
					if (blocksOpen==0) {
						// remove parenthesis
						NSArray *subBlockTokens = [tokens subarrayWithRange:NSMakeRange(blockStartIndex+1, j-blockStartIndex-1)];
						[_members addObject:[MathExpression expressionWithTokens:subBlockTokens]];
						break;
					}
					++i;
				}
			} 
			else if ([token isEqualToString:@","]) {
				isComplex = YES;
			}
			else {
				[_members addObject:token];
			}
		}
		// move all items to complex param
		if (isComplex) {
			members = [NSArray arrayWithObject:[ComplexParam paramWithItems:_members]];
		} else {
			members = _members;
		}
	}
	return self;
}

-(NSObject*) evaluate:(NSDictionary*)_parameters {
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:_parameters];
	[parameters setObject:[MathFunction sine] forKey:@"sin"];
	[parameters setObject:[MathFunction cosine] forKey:@"cos"];
	[parameters setObject:[MathFunction tangent] forKey:@"tan"];
	[parameters setObject:[MathFunction cotangent] forKey:@"ctan"];
	[parameters setObject:[MathFunction abs] forKey:@"abs"];
	[parameters setObject:[MathFunction min] forKey:@"min"];
	[parameters setObject:[MathFunction max] forKey:@"max"];
	
	if ([members count]==1 && [[members objectAtIndex:0] isKindOfClass:[ComplexParam class]]) {
		//		NSLog(@"this is complex param");
		return [[members objectAtIndex:0] items];
	}
	
	
	NSObject *value = nil;
	// turn around expressions
	NSEnumerator *memberEnum = [members reverseObjectEnumerator];
	NSObject *member = nil;
	NSString *operand = nil;
	while (member = [memberEnum nextObject]) {
		NSObject *memberValue = nil;
		
		if ([member isKindOfClass:[NSString class]]) {
			NSString *strMember = (NSString*)member;
			if ([strMember isEqualToString:@"+"] || [strMember isEqualToString:@"-"]
				|| [strMember isEqualToString:@"*"] || [strMember isEqualToString:@"/"]) {
				operand = strMember;
				continue;
			}
			else {
				// either number or parameter or function
				// check dictionary for parameter
				if ([parameters objectForKey:strMember]) {
					NSObject *paramsMember = [parameters objectForKey:strMember];
					// member exists in dictionary
//					NSLog(@"Member: %@ exists in dictionary: %@", strMember, paramsMember);
					
					if ([paramsMember isKindOfClass:[NSNumber class]]) {
						memberValue = paramsMember;
					} 
					else if ([paramsMember isKindOfClass:[MathFunction class]]) {
						// pass current value to the function
						memberValue = [(MathFunction*)paramsMember evaluate:value withParams:parameters];
						//						NSLog(@"Calculating for: %f, withParams: %@", value, parameters);
					}
					
				} else {
					// try to scan value
					memberValue = [NSNumber numberWithFloat:[self scanFloat:strMember]];
				}
			}
		} else if ([member isKindOfClass:[MathExpression class]] ) {
			NSObject *eval = [(MathExpression*)member evaluate:parameters];
			//			if ([eval isKindOfClass:[NSArray class]])
			//				return eval;
			//			else
			//			memberValue = [(NSNumber*)eval floatValue];
			memberValue = eval;
		}
		
		if (operand!=nil) {
			value = [self performOperand:operand withA:memberValue andB:value];
			operand = nil;
		} else {
			value = memberValue;
		}
		
	}
	if (operand!=nil) {
		// perform operand with 1
		value = [self performOperand:operand withA:[NSNumber numberWithFloat:0] andB:value];
	}
	return value;
}

-(NSObject*) performOperand:(NSString*)operand withA:(NSObject*)_a andB:(NSObject*)_b {
	if ([_a isKindOfClass:[NSArray class]] || [_b isKindOfClass:[NSArray class]]) {
		// don't deal with complex numbers yet
		return _b;
	}
	Float32 a = [(NSNumber*)_a floatValue];
	Float32 b = [(NSNumber*)_b floatValue];
	
	Float32 result = 0.;
	if ([operand isEqualToString:@"+"]) {
		result = a + b;
	} 
	else if ([operand isEqualToString:@"-"]) {
		result = a - b;
	}
	else if ([operand isEqualToString:@"/"]) {
		result = a / b;
	}
	else if ([operand isEqualToString:@"*"]) {
		result = a * b;
	}
	return [NSNumber numberWithFloat:result];
}

-(Float32) scanFloat:(NSString*)input {
	Float32 output = 0;
	NSScanner *scanner = [NSScanner scannerWithString:input];
	[scanner scanFloat:&output];
	return output;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"MathExpression: %@", members] ;
}

@end


@implementation MathFunction

@synthesize expression;

+(MathFunction*) functionWithType:(MathFunctionType)type {
	return [[[MathFunction alloc] initWithType:type] autorelease];
}

+(MathFunction*) functionWithExpression:(MathExpression*)expression {
	return [[[MathFunction alloc] initWithExpression:expression] autorelease];
}


+(MathFunction*) sine {
	return [MathFunction functionWithType:Sine];
}

+(MathFunction*) cosine {
	return [MathFunction functionWithType:Cosine];
}

+(MathFunction*) tangent {
	return [MathFunction functionWithType:Tangent];
}

+(MathFunction*) cotangent {
	return [MathFunction functionWithType:Cotangent];
}

+(MathFunction*) abs {
	return [MathFunction functionWithType:Abs];
}
+(MathFunction*) min {
	return [MathFunction functionWithType:Min];
}
+(MathFunction*) max {
	return [MathFunction functionWithType:Max];
}

-(id) initWithType:(MathFunctionType)_type {
	if ([super init]) {
		type = _type;
	}
	return self;
}

-(id) initWithExpression:(MathExpression*)_expression {
	if ([super init]) {
		type = Expression;
		self.expression = _expression;
	}
	return self;
}


-(NSObject*) evaluate:(NSObject*)_input withParams:(NSDictionary*)params {
	
	if (type==Expression) {
		return [expression evaluate:params];
	}
	
	if ([_input isKindOfClass:[NSNumber class]]) {
		Float32 input = [(NSNumber*)_input floatValue];
		switch (type) {
			case Sine: return [NSNumber numberWithFloat:sin(input)];
			case Cosine: return [NSNumber numberWithFloat:cos(input)];
			case Tangent: return [NSNumber numberWithFloat:tan(input)];
			case Cotangent: return [NSNumber numberWithFloat:1.0f/tan(input)];
			case Abs: return [NSNumber numberWithFloat:fabsf(input)];
			default: break;
		}
	} else if ([_input isKindOfClass:[NSArray class]]) {
		NSArray *attribs = (NSArray*)_input;
		// kapēc šeit tiek padots abs?, vienā levelā rodas komplex+fnc?
		NSObject *aVal = [attribs objectAtIndex:0];
		NSObject *bVal = [attribs objectAtIndex:1];
		if ([aVal isKindOfClass:[MathExpression class]]) 
			aVal = [(MathExpression*)aVal evaluate:params];
		if ([bVal isKindOfClass:[MathExpression class]]) 
			bVal = [(MathExpression*)bVal evaluate:params];
		Float32 a = [(NSNumber*)aVal floatValue];
		Float32 b = [(NSNumber*)bVal floatValue];
//		NSLog(@"function with more than 1 param: %@, using only 2", attribs);
		switch (type) {
			case Min: return [NSNumber numberWithFloat:MIN(a,b)];
			case Max: return [NSNumber numberWithFloat:MAX(a,b)];
		};
	}
	
	return [NSNumber numberWithFloat:0];
}

@end


@implementation ComplexParam

@synthesize items;

+(id) paramWithItems:(NSArray*)_items {
	return [[[ComplexParam alloc] initWithItems:_items] autorelease];
}

-(id) initWithItems:(NSArray*)_items {
	if ([super init]) {
		self.items = _items;
	}
	return self;
}


-(NSString*) description {
	return [NSString stringWithFormat:@"ComplexParam: %@", items] ;
}

-(void) dealloc {
	[items release];
	[super dealloc];
}

@end

