//
//  TextureShader.h
//  Game
//
//  Created by Landon on 12/10/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "Shader.h"

typedef struct {
	GLint textureCoordinateAttribute;
	GLint textureUniform;
} TextureIndex;

@interface TextureShader : Shader

@property (nonatomic, readonly) TextureIndex textureIndex;

@end
