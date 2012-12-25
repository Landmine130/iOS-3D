//
//  HeightMap.h
//  Game
//
//  Created by Landon on 12/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VisibleObject.h"


@interface HeightMap : NSObject

@property (nonatomic, readonly) int length;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int resolution;
@property (nonatomic) float **map;

- (id)initWithLength:(int)length width:(int)width resolution:(int)resolution;

- (VisibleObject *)model;

@end
