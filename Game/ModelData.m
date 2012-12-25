//
//  ModelLoader.m
//  Game
//
//  Created by Landon on 11/29/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "ModelData.h"
#include <CoreFoundation/CoreFoundation.h>
@interface ModelData ()

@end


@implementation ModelData

static NSMutableDictionary *models;

+ (void)initialize {
	
	models = [[NSMutableDictionary alloc] init];
}

+ (void)loadModelDataForName:(NSString *)name synchronized:(BOOL)synchronized {
	ModelData *modelData = [models objectForKey:name];
	if (!modelData) {
		
		if (synchronized) {
			[ModelData readFileForName:name];
		}
		else {
			[NSThread detachNewThreadSelector:@selector(readFileForName:) toTarget:[ModelData class] withObject:name];
		}
	}
}

+ (ModelData *)modelDataForName:(NSString *)name {
	
	return [models objectForKey:name];
}

+ (void)readFileForName:(NSString *)name {
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@".modeldata"];
	if (filePath) {
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
		if (fileHandle) {
			
			int vertexCount = CFSwapInt32LittleToHost(*(int32_t *)[[fileHandle readDataOfLength:sizeof(int32_t)] bytes]);
			int normalCount = CFSwapInt32LittleToHost(*(int32_t *)[[fileHandle readDataOfLength:sizeof(int32_t)] bytes]);
			int textureMapCount = CFSwapInt32LittleToHost(*(int32_t *)[[fileHandle readDataOfLength:sizeof(int32_t)] bytes]);
			
			long totalSize = vertexCount * 3 + normalCount * 3 + textureMapCount * 2;
			long totalBytes = totalSize * sizeof(float_t);
			
			NSData *dataObject = [[fileHandle readDataOfLength:totalBytes] retain];
			
			CFSwappedFloat32 *swappedData = (CFSwappedFloat32 *)[dataObject bytes];
			float *data = (float *)swappedData;
			if (CFByteOrderGetCurrent() != CFByteOrderLittleEndian) {
				for (int i = 0; i < totalSize; i++) {
					float temp = CFConvertFloat32SwappedToHost(swappedData[i]);
					data[i] = temp;
				}
			}
			// Sanity check
			
			if ([dataObject length] != totalBytes) {
				NSLog(@"Warning: Modeldata file contains invalid length declarations. Declares size as %ld, but file is size %lu", totalBytes + sizeof(int32_t) * 3, [dataObject length] + sizeof(int32_t) * 3);
			}
			
			ModelData *newData = [[ModelData alloc] initWithData:data vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount];
			
			[models setObject:newData forKey:name];
			
		}
		else {
			NSLog(@"Warning: Modeldata file could not be opened for reading");
		}
	}
	else {
		NSLog(@"Warning: File of .modeldata format could not be found");
	}
}

- (id)initWithData:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount {
	
	if (self = [super init]) {
		_data = data;
		_vertexCount = vertexCount;
		_normalCount = normalCount;
		_textureMapCount = textureMapCount;
	}
	return self;
}

+ (void)unloadModelDataForName:(NSString *)name {
	
}

@end
