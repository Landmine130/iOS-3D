//
//  PhysicsObject.h
//  Game
//
//  Created by Landon on 12/17/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "CollisionObject.h"

@interface PhysicsObject : CollisionObject

@property (nonatomic, readonly) GLKVector3 netForce;
@property (nonatomic, readonly) GLKVector3 netTorque;
@property (nonatomic) GLKVector3 velocity;
@property (nonatomic) GLKVector3 angularVelocity;
@property (nonatomic) float mass;
@property (nonatomic, readonly) GLKVector3 momentOfInertia;
@property (nonatomic) BOOL physicsEnabled;


- (id)initWithModelName:(NSString *)name andMass:(float)mass;

- (void)applyForce:(GLKVector3)force forDuration:(float)seconds;
- (void)applyForce:(GLKVector3)force forDuration:(float)seconds atPosition:(GLKVector3)offset isRelativeToCenter:(BOOL)isRelative;
- (void)accelerateToVelocity:(GLKVector3)velocity overDuration:(float)seconds;
- (void)removeForce:(GLKVector3)force;
- (void)removeTorque:(GLKVector3)torque;
- (void)removeAllForces;
- (void)stop;

@end
