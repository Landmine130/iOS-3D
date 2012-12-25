//
//  ViewPoint.m
//  TestGame
//
//  Created by Landon on 8/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "ViewPoint.h"

@implementation ViewPoint

- (id)init {
	if (self = [super init]) {
		self.fieldOfView = GLKMathDegreesToRadians(65);
		self.minimumSightDistance = .1f;
		self.maximumSightDistance = 200.0f;
	}
	return self;
}

@end
