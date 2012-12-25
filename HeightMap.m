//
//  HeightMap.m
//  Game
//
//  Created by Landon on 12/13/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "HeightMap.h"

@implementation HeightMap

- (id)initWithLength:(int)length width:(int)width resolution:(int)resolution {
	
	if (width * resolution > 1 && length * resolution > 1) {
		
		if (width % 2 || length % 2) {
			
			NSLog(@"Warning: Cannot create height map of odd length or width. Resizing down...");
			width -= width % 2;
			length -= length % 2;
		}
		if (self = [super init]) {
			
			_length = length;
			_width = width;
			_resolution = resolution;
			
			_map = malloc(length * sizeof(float *));
			
			for (int i = 0; i < length; i++) {
				
				_map[i] = malloc(width * sizeof(float));
				
				for (int j = 0; j < width; j++) {
					_map[i][j] = 0.0f;
				}
			}
		}
	}
	else {
		NSLog(@"Warning: Cannot create height map with fewer than 3 dimensions");
	}
	return self;
}

- (VisibleObject *)model {
	
	float *data = malloc(_length * _width * sizeof(float) * 1.5);
	
	int counter = 0;
	
	// Write verticies
	for (int i = 0; i < _length; i += 2) {
		for (int j = 0; i < _width; i += 2) {
			
			// First triangle
			data[counter++] = i / _resolution;
			data[counter++] = _map[i][j];
			data[counter++] = j / _resolution;
			data[counter++] = i / _resolution;
			data[counter++] = _map[i][j + 1];
			data[counter++] = (j + 1) / _resolution;
			data[counter++] = (i + 1) / _resolution;
			data[counter++] = _map[i + 1][j];
			data[counter++] = j / _resolution;
			
			// Second triangle
			data[counter++] = (i + 1) / _resolution;
			data[counter++] = _map[i + 1][j + 1];
			data[counter++] = (j + 1) / _resolution;
			data[counter++] = i / _resolution;
			data[counter++] = _map[i][j + 1];
			data[counter++] = (j + 1) / _resolution;
			data[counter++] = (i + 1) / _resolution;
			data[counter++] = _map[i + 1][j];
			data[counter++] = j / _resolution;
		}
	}
	
	// Write normals
	for (int i = 0; i < counter; i += 9) {
		GLKVector3 a = GLKVector3Make(data[i], data[i + 1], data[i + 2]);
		GLKVector3 b = GLKVector3Make(data[i + 3], data[i + 4], data[i + 5]);
		GLKVector3 c = GLKVector3Make(data[i + 6], data[i + 7], data[i + 8]);

		GLKVector3 u = GLKVector3Subtract(b, a);
		GLKVector3 v = GLKVector3Subtract(c, a);
		
		float x = u.y * v.z - u.z * v.y;
		float y = u.z * v.x - u.x * v.z;
		float z = u.x * v.y - u.y * v.x;
		
		float normalization = (float)sqrt((x * x) + (y * y) + (z * z));
		
		x /= normalization;
		y /= normalization;
		z /= normalization;
		
		data[counter + i] = x;
		data[counter + i + 1] = y;
		data[counter + i + 2] = z;
		data[counter + i + 3] = x;
		data[counter + i + 4] = y;
		data[counter + i + 5] = z;
		data[counter + i + 6] = x;
		data[counter + i + 7] = y;
		data[counter + i + 8] = z;
	}
	
	return [[VisibleObject alloc] initWithVertexArray:data vertexCount:counter normalCount:counter textureMapCount:0 texture:0 shader:[[Shader alloc] init]];
}

- (void)dealloc {
	
	for (int i = 0; i < _length; i++) {
		free(_map[i]);
	}
	free(_map);
	[super dealloc];
}

@end
