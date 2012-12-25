//
//  CollisionObject.h
//  Game
//
//  Created by Landon on 12/21/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "VisibleObject.h"

@class CollisionObject;

@protocol CollisionObjectCollisionObserver <NSObject>

- (void)object:(CollisionObject *)object collidedWithObject:(CollisionObject *)object2 betweenPolygon:(Triangle)triangle1 andPolygon:(Triangle)triangle2;

@end


@interface CollisionObject : VisibleObject

@property (nonatomic, readonly) NSOrderedSet *collidableObjects;
@property (nonatomic, readonly) float radius;

- (void)addCollidableObject:(CollisionObject *)object;
- (void)removeCollidableObject:(CollisionObject *)object;

- (void)addCollisionObserver:(id<CollisionObjectCollisionObserver>)object;
- (void)removeCollisionObserver:(id<CollisionObjectCollisionObserver>)object;

- (void)collidedWithObject:(CollisionObject *) betweenPolygon:(Triangle)triangle1 andPolygon:(Triangle)triangle2;

@end
