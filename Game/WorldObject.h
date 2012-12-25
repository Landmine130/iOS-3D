//
//  WorldObject.h
//  TestGame
//
//  Created by Landon on 8/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "World.h"

// GLKit Extensions

// Undefined before initalization of WorldObject class

static __inline__ GLKVector3 GLKVector3ScaleFromMatrix4(GLKMatrix4 m) {
    
    GLKVector3 v = GLKVector3Make(sqrt(m.m00*m.m00 + m.m01*m.m01 +m.m02*m.m02),
                                  sqrt(m.m10*m.m10 + m.m11*m.m11 +m.m12*m.m12),
                                  sqrt(m.m20*m.m20 + m.m21*m.m21 +m.m22*m.m22));
    
    return v;
}

static __inline__ GLKMatrix4 GLKMatrix4RotationFromMatrix4(GLKMatrix4 m) {
    
    GLKVector3 s = GLKVector3ScaleFromMatrix4(m);
    
    GLKMatrix4 n_matrix;
    n_matrix.m00 = m.m00/s.x;
    n_matrix.m01 = m.m01/s.x;
    n_matrix.m02 = m.m02/s.x;
    n_matrix.m03 = 0;
    
    n_matrix.m10 = m.m10/s.y;
    n_matrix.m11 = m.m11/s.y;
    n_matrix.m12 = m.m12/s.y;
    n_matrix.m13 = 0;
    
    n_matrix.m20 = m.m20/s.z;
    n_matrix.m21 = m.m21/s.z;
    n_matrix.m22 = m.m22/s.z;
    n_matrix.m23 = 0;
	
    n_matrix.m30 = 0;
    n_matrix.m31 = 0;
    n_matrix.m32 = 0;
    n_matrix.m33 = 1;
	
    return n_matrix;
}


static __inline__ GLKVector3 GLKVector3RotationFromMatrix4(GLKMatrix4 matrix) {
    
    GLKVector3 rotate;
    
    // decompose main matrix and take just rotation matrix
    GLKMatrix4 rMatrix = GLKMatrix4RotationFromMatrix4(matrix);
    
    rotate.x = atan2f(rMatrix.m21, rMatrix.m22);
    rotate.y = atan2f(-rMatrix.m20, sqrtf(rMatrix.m21*rMatrix.m21 + rMatrix.m22*rMatrix.m22) );
    rotate.z = atan2f(rMatrix.m10, rMatrix.m00);
    
    return rotate;
}

static __inline__ GLKVector3 GLKVector3TranslationFromMatrix4(GLKMatrix4 matrix) {
    
    GLKVector3 translate = GLKVector3Make(matrix.m30, matrix.m31, matrix.m32);
    
    return translate;
}

@class WorldObject;

@protocol WorldObjectMovementObserver <NSObject>

- (void)locationChanged:(WorldObject *)sender;
- (void)orientationChanged:(WorldObject *)sender;

@end


@interface WorldObject : NSObject <WorldUpdateObserver>

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKMatrix4 positionMatrix;
@property (nonatomic) GLKVector3 orientation;

+ (GLKVector3)vectorFromPosition:(GLKVector3)source ToPosition:(GLKVector3)target;
- (GLKVector3)vectorToPosition:(GLKVector3)p;
- (GLKVector3)vectorToObject:(WorldObject *)o;
- (float)distanceToObject:(WorldObject *)o;
- (float)distanceToPosition:(GLKVector3)p;
- (void)move:(GLKVector3)magnitude;
- (void)rotate:(GLKVector3)magnitude;

- (void)addMovementObserver:(id<WorldObjectMovementObserver>)observer;
- (void)removeMovementObserver:(id<WorldObjectMovementObserver>)observer;

@end
