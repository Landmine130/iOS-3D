//
//  WorldObject.m
//  TestGame
//
//  Created by Landon on 8/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//


#import "WorldObject.h"

static GLKVector3 ZERO_VECTOR;
static GLKVector3 ONE_VECTOR;

@interface WorldObject () {
	
	NSMutableOrderedSet *_movementObservers;
}

@end

@implementation WorldObject

+ (void)initialize {
	ZERO_VECTOR = GLKVector3Make(0,0,0);
	ONE_VECTOR = GLKVector3Make(1,1,1);
}

- (id)init {
	if (self = [super init]) {
		
		self.position = ZERO_VECTOR;
		self.orientation = ZERO_VECTOR;
		
		_movementObservers = [[NSMutableOrderedSet alloc] init];
	}
	return self;
}

- (GLKVector3)vectorToObject:(WorldObject *)o {
	return [self vectorToPosition:o.position];
}

- (GLKVector3)vectorToPosition:(GLKVector3)p {
	return [WorldObject vectorFromPosition:self.position ToPosition:p];
}

+ (GLKVector3)vectorFromPosition:(GLKVector3)source ToPosition:(GLKVector3)target {
	return GLKVector3Subtract(target, source);
}

- (float)distanceToObject:(WorldObject *)o {
	return [self distanceToPosition:o.position];
}

- (float)distanceToPosition:(GLKVector3)p {
	return GLKVector3Distance(self.position, p);
}

- (void)addMovementObserver:(id<WorldObjectMovementObserver>)object {
	[_movementObservers addObject:object];
}

- (void)removeMovementObserver:(id<WorldObjectMovementObserver>)object {
	[_movementObservers removeObject:object];
}

- (void)move:(GLKVector3)vector {
	
	self.positionMatrix = GLKMatrix4Translate(_positionMatrix, vector.x, vector.y, vector.z);
	
	for (int i = 0; i < [_movementObservers count]; i++) {
		[[_movementObservers objectAtIndex:i] locationChanged:self];
	}
}

- (GLKVector3)position {
	return GLKVector3TranslationFromMatrix4(_positionMatrix);
}


- (void)setPosition:(GLKVector3)position {
	
	self.positionMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
	
	for (int i = 0; i < [_movementObservers count]; i++) {
		[[_movementObservers objectAtIndex:i] locationChanged:self];
	}
}

- (void)rotate:(GLKVector3)magnitude {
	
	self.orientation = GLKVector3Add(self.orientation, magnitude);
	
	for (int i = 0; i < [_movementObservers count]; i++) {
		[[_movementObservers objectAtIndex:i] orientationChanged:self];
	}
}

- (void)setOrientation:(GLKVector3)orientation {
	
	_orientation = orientation;
	
	for (int i = 0; i < [_movementObservers count]; i++) {
		[[_movementObservers objectAtIndex:i] orientationChanged:self];
	}
}

- (void)dealloc {
	
	[_movementObservers release];
	
	[super dealloc];
}

#pragma mark - WorldUpdateDelegate Methods

- (void)worldIsUpdating:(World *)world timeSinceLastUpdate:(NSTimeInterval)seconds {

}

@end
