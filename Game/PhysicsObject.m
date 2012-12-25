//
//  PhysicsObject.m
//  Game
//
//  Created by Landon on 12/17/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "PhysicsObject.h"

@interface PhysicsObject () {
	
	NSMutableArray *_forcesToRemove;
	NSMutableArray *_torquesToRemove;
	NSMutableArray *_secondsUntilRemoval;
}

- (void)calculateMomentOfInertia;

@end


@implementation PhysicsObject

- (id)initWithModelName:(NSString *)name andMass:(float)mass {

	if (self = [super initWithModelName:name]) {
		
		GLKVector3 zeroVector = GLKVector3Make(0, 0, 0);
		_velocity = zeroVector;
		_angularVelocity = zeroVector;
		_netForce = zeroVector;
		_netTorque = zeroVector;
		_forcesToRemove = [[NSMutableArray alloc] init];
		_torquesToRemove = [[NSMutableArray alloc] init];
		_secondsUntilRemoval = [[NSMutableArray alloc] init];
		self.mass = mass;
	}
	return self;
}

- (id)initWithModelName:(NSString *)name {
	
	[self initWithModelName:name andMass:0];
	return self;
}

- (id)initWithVertexArray:(GLfloat *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount texture:(GLuint)texture shader:(Shader *)shader {
	
	if (self = [super initWithVertexArray:data vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount texture:texture shader:shader]) {
		
		_mass = 0;
		GLKVector3 zeroVector = GLKVector3Make(0, 0, 0);
		_velocity = zeroVector;
		_angularVelocity = zeroVector;
		_netForce = zeroVector;
		_netTorque = zeroVector;
		_physicsEnabled = TRUE;
		_forcesToRemove = [[NSMutableArray alloc] init];
		_torquesToRemove = [[NSMutableArray alloc] init];
		_secondsUntilRemoval = [[NSMutableArray alloc] init];

		
	}
	return self;
}


- (void)applyForce:(GLKVector3)force forDuration:(float)seconds {
	if (self.physicsEnabled) {
		[self applyForce:force forDuration:seconds atPosition:GLKVector3Make(0,0,0) isRelativeToCenter:NO];
	}
}

- (void)applyForce:(GLKVector3)force forDuration:(float)seconds atPosition:(GLKVector3)offset isRelativeToCenter:(BOOL)isRelative {
	if (self.physicsEnabled) {
		GLKVector3 torque = GLKVector3CrossProduct(force, offset);
		_netTorque = GLKVector3Add(_netTorque, torque);
		_netForce = GLKVector3Add(_netForce, force);
		
		if (seconds) {
			[_secondsUntilRemoval addObject:[NSNumber numberWithFloat:seconds]];
			[_forcesToRemove addObject:[NSValue value:&force withObjCType:@encode(GLKVector3)]];
			[_torquesToRemove addObject:[NSValue value:&torque withObjCType:@encode(GLKVector3)]];
		}
	}
}

- (void)accelerateToVelocity:(GLKVector3)velocity overDuration:(float)seconds {
	GLKVector3 force = GLKVector3DivideScalar(GLKVector3Subtract(velocity, self.velocity), seconds);
	[self applyForce:force forDuration:seconds];
}

- (void)removeForce:(GLKVector3)force {
	
	if (_physicsEnabled) {
		_netForce = GLKVector3Subtract(self.netForce, force);
	}
}

- (void)removeTorque:(GLKVector3)torque {
	if (_physicsEnabled) {
		_netTorque = GLKVector3Subtract(self.netTorque, torque);
	}
}

- (void)removeAllForces {
	if (_physicsEnabled) {
		
		[_secondsUntilRemoval removeAllObjects];
		[_forcesToRemove removeAllObjects];
		[_torquesToRemove removeAllObjects];

		GLKVector3 zeroVector = GLKVector3Make(0, 0, 0);
		_netTorque = zeroVector;
		_netForce = zeroVector;
	}
}

- (void)stop {
	if (_physicsEnabled) {
		[self removeAllForces];
		GLKVector3 zeroVector = GLKVector3Make(0, 0, 0);
		_velocity = zeroVector;
		_angularVelocity = zeroVector;
	}
}

- (void)setMass:(float)mass {
	
	_mass = mass;
	self.physicsEnabled = mass != 0;
	[self calculateMomentOfInertia];

}

- (void)setPositionMatrix:(GLKMatrix4)positionMatrix {
	
	if (!self.physicsEnabled) {
		[super setPositionMatrix:positionMatrix];
	}
}

- (void)setOrientation:(GLKVector3)orientation {
	
	if (!self.physicsEnabled) {
		[super setOrientation:orientation];
	}
}

- (void)setVertexArray:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount {
	[super setVertexArray:data vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount];
	[self calculateMomentOfInertia];
}

- (void)calculateMomentOfInertia {
	if (_mass) {
		
		float vertexMass = _mass / self.totalDataCount;
		
		for (int i = 0; i < self.vertexCount; i += 3) {
			_momentOfInertia.x += vertexMass * self.data[i + 1] * self.data[i + 1] + self.data[i + 2] * self.data[i + 2];
			_momentOfInertia.y += vertexMass * self.data[i] * self.data[i] + self.data[i + 2] * self.data[i + 2];
			_momentOfInertia.z += vertexMass * self.data[i] * self.data[i] + self.data[i + 1] * self.data[i + 1];
		}
	}
}

- (void)dealloc {
	
	[_forcesToRemove release];
	[_torquesToRemove release];
	[_secondsUntilRemoval release];
	
	[super dealloc];
}



#pragma mark - WorldUpdateObserver Methods

- (void)worldIsUpdating:(World *)world timeSinceLastUpdate:(NSTimeInterval)seconds {

	if (self.physicsEnabled) {
		GLKVector3 acceleration = GLKVector3DivideScalar(self.netForce, self.mass);
		self.velocity = GLKVector3Add(self.velocity, GLKVector3MultiplyScalar(acceleration, seconds));
		
		if (!GLKVector3AllEqualToScalar(self.velocity, 0)) {
			[self move:self.velocity];
		}
		
		GLKVector3 angularAcceleration = GLKVector3Divide(self.netTorque, self.momentOfInertia);
		self.angularVelocity = GLKVector3Add(self.angularVelocity, GLKVector3MultiplyScalar(angularAcceleration, seconds));
		
		if (!GLKVector3AllEqualToScalar(self.angularVelocity, 0)) {
			[self rotate:self.angularVelocity];
		}
		int count = [_secondsUntilRemoval count];
		for (int i = 0; i < count; i++) {
			
			float secondsLeft = [[_secondsUntilRemoval objectAtIndex:i] floatValue];
			secondsLeft -= seconds;
			if (secondsLeft <= 0) {
				
				GLKVector3 force;
				GLKVector3 torque;
				[[_forcesToRemove objectAtIndex:i] getValue:&force];
				[[_torquesToRemove objectAtIndex:i] getValue:&torque];
				[self removeForce:force];
				[self removeTorque:torque];
				[_forcesToRemove removeObjectAtIndex:i];
				[_torquesToRemove removeObjectAtIndex:i];
				[_secondsUntilRemoval removeObjectAtIndex:i];
			}
			else {
				[_secondsUntilRemoval replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:secondsLeft]];
			}
		}
	}
}

@end
