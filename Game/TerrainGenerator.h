//
//  TerrainGenerator.h
//  Game
//
//  Created by Landon on 12/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeightMap.h"
#import "Rectangle.h"

@interface TerrainGenerator : NSObject

+ (void)addHillsToArea:(Rectangle)area inHeightMap:(HeightMap *)map;
+ (void)addHillOfHeight:(float)height ToArea:(Rectangle)area inHeightMap:(HeightMap *)heightMap;

@end
