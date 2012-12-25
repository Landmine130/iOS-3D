//
//  TerrainGenerator.m
//  Game
//
//  Created by Landon on 12/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "TerrainGenerator.h"

@interface TerrainGenerator ()

//+ (NSNumber *)makeSelectionFromArray:(NSArray *)choices withProbabilites:(NSArray *)probabilities;

@end

@implementation TerrainGenerator

+ (void)initialize {
	
	long systemTime = time(NULL);
	srandom(systemTime);
	NSLog(@"Seed: %ld", systemTime);
}

+ (void)addHillsToArea:(Rectangle)area inHeightMap:(HeightMap *)map {
	
}

+ (void)addHillOfHeight:(float)height ToArea:(Rectangle)area inHeightMap:(HeightMap *)heightMap {
	
	area.x *= heightMap.resolution;
	area.y *= heightMap.resolution;
	area.width *= heightMap.resolution;
	area.length *= heightMap.resolution;

	for (int x = area.x; x < area.length + area.x; x++) {
		
		float previous = heightMap.map[x][0];
		for (int y = area.y; y < area.width + area.y; y++) {
			
			int range = (int)(area.width * heightMap.resolution);
			heightMap.map[x][y] = previous + random() % range - range / 2;
			
			
			
		}
	}
}
/*
+ (NSNumber *)makeSelectionFromArray:(NSArray *)choices withProbabilites:(NSArray *)probabilities {
	
}
*/
@end
