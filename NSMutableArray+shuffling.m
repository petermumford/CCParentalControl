//
//  NSMutableArray+shuffling.m
//  Myro
//
//  Created by Peter Mumford on 25/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+shuffling.h"


@implementation NSMutableArray (Shuffling)

- (void)shuffleArray
{
	NSUInteger count = [self count];
	for (uint i = 0; i < count; ++i)
	{
		// Select a random element between i and end of array to swap with.
		int nElements = count - i;
		int n = arc4random_uniform(nElements) + i;
		[self exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

@end
