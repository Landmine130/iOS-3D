//
//  ModelLoader.h
//  Game
//
//  Created by Landon on 11/29/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelData : NSObject

@property (nonatomic, readonly) float *data;
@property (nonatomic, readonly) int vertexCount;
@property (nonatomic, readonly) int normalCount;
@property (nonatomic, readonly) int textureMapCount;

+ (id)modelDataForName:(NSString *)name;

+ (void)loadModelDataForName:(NSString *)name synchronized:(BOOL)synchronized;

- (id)initWithData:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount;

@end
