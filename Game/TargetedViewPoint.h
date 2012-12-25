//
//  TargetedViewPoint.h
//  Game
//
//  Created by Landon on 12/14/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "ViewPoint.h"

@interface TargetedViewPoint : ViewPoint <WorldObjectMovementObserver>

@property (nonatomic, retain) WorldObject *target;
@property (nonatomic) float distanceFromTarget;

- (id)initWithTarget:(WorldObject *)target distanceFromTarget:(float)distanceFromTarget;

@end
