//
//  TargetedViewPoint.m
//  Game
//
//  Created by Landon on 12/14/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "TargetedViewPoint.h"

@interface TargetedViewPoint ()

- (void)updatePosition;

@end


@implementation TargetedViewPoint

- (id)initWithTarget:(WorldObject *)target distanceFromTarget:(float)distanceFromTarget {
	
	if (self = [super init]) {
		
		self.target = target;
		self.distanceFromTarget = distanceFromTarget;
	}
	return self;
}

- (void)setTarget:(WorldObject *)target {
	
	if (target != self.target) {
		
		[self.target release];
		_target = target;
		[_target retain];
		
		if (target) {
			[target addMovementObserver:self];
			[self updatePosition];
		}
	}
}

- (void)setDistanceFromTarget:(float)distanceFromTarget {
	
	_distanceFromTarget = distanceFromTarget;
	
	[self updatePosition];
}

- (void)rotate:(GLKVector3)magnitude {
	[super rotate:magnitude];
	
	[self updatePosition];
}

- (void)setOrientation:(GLKVector3)orientation {
	[super setOrientation:orientation];
	
	[self updatePosition];
}

- (void)updatePosition {
	
	
	GLKMatrix4 newLocation = GLKMatrix4MakeTranslation(0, 0, self.distanceFromTarget);
	
	//newLocation = GLKMatrix4MakeRotation(self.orientation.x, 1.0f, 0, 0);
	
	newLocation = GLKMatrix4RotateX(newLocation, -self.orientation.x);
	newLocation = GLKMatrix4RotateY(newLocation, -self.orientation.y);
	newLocation = GLKMatrix4RotateZ(newLocation, self.orientation.z);

	//newLocation = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, -self.distanceFromTarget), newLocation);
	newLocation = GLKMatrix4Invert(newLocation, NULL);
	
	newLocation = GLKMatrix4Multiply(self.target.positionMatrix, newLocation);
	
	super.position = GLKVector3TranslationFromMatrix4(newLocation);
}

// No effect when target is set
- (void)move:(GLKVector3)vector {
	
	if (!self.target) {
		[super move:vector];
	}
}

// No effect when target is set
- (void)setPosition:(GLKVector3)position {
	
	if (!self.target) {
		[super setPosition:position];
	}
}

#pragma mark - WorldObjectMovementDelegate Methods

- (void)locationChanged:(WorldObject *)sender {
	[self updatePosition];
}

- (void)orientationChanged:(WorldObject *)sender {
	[self updatePosition];
}

- (void)dealloc {
	self.target = nil;
	
	[super dealloc];
}
@end
