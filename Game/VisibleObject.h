//
//  Object.h
//  TestGame
//
//  Created by Landon on 8/11/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "WorldObject.h"
#import "Shader.h"

typedef union {
	struct {
		GLKVector3 vertex1, vertex2, vertex3;
	};
	float floatArray[9];
} Triangle;

static __inline__ Triangle TriangleMake(GLKVector3 v1, GLKVector3 v2, GLKVector3 v3) {
	Triangle retValue;
	retValue.vertex1 = v1;
	retValue.vertex2 = v2;
	retValue.vertex3 = v3;
	return retValue;
}


@interface VisibleObject : WorldObject {
	GLuint _vertexBuffer;
}

@property (nonatomic, readonly) GLuint vertexArray;
@property (nonatomic, readonly) int vertexCount;
@property (nonatomic, readonly) int normalCount;
@property (nonatomic, readonly) int textureMapCount;
@property (nonatomic, readonly) int totalDataCount;

@property (nonatomic, readonly) float *data;


@property (nonatomic) BOOL hidden;
@property (nonatomic) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

@property (nonatomic) GLuint texture;
@property (nonatomic, retain) Shader *shader;

- (id)initWithModelName:(NSString *)name;
+ (GLuint)textureForFilePath:(NSString *)fileName;

- (id)initWithVertexArray:(GLfloat *)vertices vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount texture:(GLuint)texture shader:(Shader *)shader;

- (void)setVertexArray:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount;


@end
