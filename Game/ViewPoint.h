//
//  ViewPoint.h
//  TestGame
//
//  Created by Landon on 8/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorldObject.h"

@interface ViewPoint : WorldObject

@property (nonatomic) float fieldOfView;
@property (nonatomic) float minimumSightDistance;
@property (nonatomic) float maximumSightDistance;

@end
