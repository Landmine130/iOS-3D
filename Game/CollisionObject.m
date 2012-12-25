//
//  CollisionObject.m
//  Game
//
//  Created by Landon on 12/21/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "CollisionObject.h"
#include <math.h>

#define FABS(x) fabs(x)        /* implement as is fastest on your machine */

/* if USE_EPSILON_TEST is true then we do a check:
 if |dv|<EPSILON then dv=0.0;
 else no check is done (which is less robust)
 */
#define USE_EPSILON_TEST TRUE
#define EPSILON 0.000001


/* some macros */
#define CROSS(dest,v1,v2){                     \
	dest[0]=v1[1]*v2[2]-v1[2]*v2[1]; \
	dest[1]=v1[2]*v2[0]-v1[0]*v2[2]; \
	dest[2]=v1[0]*v2[1]-v1[1]*v2[0];}

#define DOT(v1,v2) (v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2])

#define SUB(dest,v1,v2){         \
	dest[0]=v1[0]-v2[0]; \
	dest[1]=v1[1]-v2[1]; \
	dest[2]=v1[2]-v2[2];}

/* sort so that a<=b */
#define SORT(a,b)       \
if(a>b)    \
{          \
	float c; \
	c=a;     \
	a=b;     \
	b=c;     \
}


/* this edge to edge test is based on Franlin Antonio's gem:
 "Faster Line Segment Intersection", in Graphics Gems III,
 pp. 199-202 */
#define EDGE_EDGE_TEST(V0,U0,U1)                      \
Bx=U0[i0]-U1[i0];                                   \
By=U0[i1]-U1[i1];                                   \
Cx=V0[i0]-U0[i0];                                   \
Cy=V0[i1]-U0[i1];                                   \
f=Ay*Bx-Ax*By;                                      \
d=By*Cx-Bx*Cy;                                      \
if((f>0 && d>=0 && d<=f) || (f<0 && d<=0 && d>=f))  \
{                                                   \
	e=Ax*Cy-Ay*Cx;                                    \
	if(f>0)                                           \
	{                                                 \
		if(e>=0 && e<=f) return 1;                      \
	}                                                 \
	else                                              \
	{                                                 \
		if(e<=0 && e>=f) return 1;                      \
	}                                                 \
}

#define EDGE_AGAINST_TRI_EDGES(V0,V1,U0,U1,U2) \
{                                              \
	float Ax,Ay,Bx,By,Cx,Cy,e,d,f;               \
	Ax=V1[i0]-V0[i0];                            \
	Ay=V1[i1]-V0[i1];                            \
	/* test edge U0,U1 against V0,V1 */          \
	EDGE_EDGE_TEST(V0,U0,U1);                    \
	/* test edge U1,U2 against V0,V1 */          \
	EDGE_EDGE_TEST(V0,U1,U2);                    \
	/* test edge U2,U1 against V0,V1 */          \
	EDGE_EDGE_TEST(V0,U2,U0);                    \
}

#define POINT_IN_TRI(V0,U0,U1,U2)           \
{                                           \
	float a,b,c,d0,d1,d2;                     \
	/* is T1 completly inside T2? */          \
	/* check if V0 is inside tri(U0,U1,U2) */ \
	a=U1[i1]-U0[i1];                          \
	b=-(U1[i0]-U0[i0]);                       \
	c=-a*U0[i0]-b*U0[i1];                     \
	d0=a*V0[i0]+b*V0[i1]+c;                   \
	\
	a=U2[i1]-U1[i1];                          \
	b=-(U2[i0]-U1[i0]);                       \
	c=-a*U1[i0]-b*U1[i1];                     \
	d1=a*V0[i0]+b*V0[i1]+c;                   \
	\
	a=U0[i1]-U2[i1];                          \
	b=-(U0[i0]-U2[i0]);                       \
	c=-a*U2[i0]-b*U2[i1];                     \
	d2=a*V0[i0]+b*V0[i1]+c;                   \
	if(d0*d1>0.0)                             \
	{                                         \
		if(d0*d2>0.0) return 1;                 \
	}                                         \
}


#define NEWCOMPUTE_INTERVALS(VV0,VV1,VV2,D0,D1,D2,D0D1,D0D2,A,B,C,X0,X1) \
{ \
	if(D0D1>0.0f) \
	{ \
		/* here we know that D0D2<=0.0 */ \
		/* that is D0, D1 are on the same side, D2 on the other or on the plane */ \
		A=VV2; B=(VV0-VV2)*D2; C=(VV1-VV2)*D2; X0=D2-D0; X1=D2-D1; \
	} \
	else if(D0D2>0.0f)\
	{ \
		/* here we know that d0d1<=0.0 */ \
		A=VV1; B=(VV0-VV1)*D1; C=(VV2-VV1)*D1; X0=D1-D0; X1=D1-D2; \
	} \
	else if(D1*D2>0.0f || D0!=0.0f) \
	{ \
		/* here we know that d0d1<=0.0 or that D0!=0.0 */ \
		A=VV0; B=(VV1-VV0)*D0; C=(VV2-VV0)*D0; X0=D0-D1; X1=D0-D2; \
	} \
	else if(D1!=0.0f) \
	{ \
		A=VV1; B=(VV0-VV1)*D1; C=(VV2-VV1)*D1; X0=D1-D0; X1=D1-D2; \
	} \
	else if(D2!=0.0f) \
	{ \
		A=VV2; B=(VV0-VV2)*D2; C=(VV1-VV2)*D2; X0=D2-D0; X1=D2-D1; \
	} \
	else \
	{ \
		/* triangles are coplanar */ \
		return coplanar_tri_tri(N1,V0,V1,V2,U0,U1,U2); \
	} \
}


int coplanar_tri_tri(float N[3],float V0[3],float V1[3],float V2[3],
					 float U0[3],float U1[3],float U2[3])
{
	float A[3];
	short i0,i1;
	/* first project onto an axis-aligned plane, that maximizes the area */
	/* of the triangles, compute indices: i0,i1. */
	A[0]=FABS(N[0]);
	A[1]=FABS(N[1]);
	A[2]=FABS(N[2]);
	if(A[0]>A[1])
	{
		if(A[0]>A[2])
		{
			i0=1;      /* A[0] is greatest */
			i1=2;
		}
		else
		{
			i0=0;      /* A[2] is greatest */
			i1=1;
		}
	}
	else   /* A[0]<=A[1] */
	{
		if(A[2]>A[1])
		{
			i0=0;      /* A[2] is greatest */
			i1=1;
		}
		else
		{
			i0=0;      /* A[1] is greatest */
			i1=2;
		}
	}
	
	/* test all edges of triangle 1 against the edges of triangle 2 */
	EDGE_AGAINST_TRI_EDGES(V0,V1,U0,U1,U2);
	EDGE_AGAINST_TRI_EDGES(V1,V2,U0,U1,U2);
	EDGE_AGAINST_TRI_EDGES(V2,V0,U0,U1,U2);
	
	/* finally, test if tri1 is totally contained in tri2 or vice versa */
	POINT_IN_TRI(V0,U0,U1,U2);
	POINT_IN_TRI(U0,V0,V1,V2);
	
	return 0;
}

int NoDivTriTriIsect(float V0[3],float V1[3],float V2[3],
					 float U0[3],float U1[3],float U2[3])
{
	float E1[3],E2[3];
	float N1[3],N2[3],d1,d2;
	float du0,du1,du2,dv0,dv1,dv2;
	float D[3];
	float isect1[2], isect2[2];
	float du0du1,du0du2,dv0dv1,dv0dv2;
	short index;
	float vp0,vp1,vp2;
	float up0,up1,up2;
	float bb,cc,max;
	
	/* compute plane equation of triangle(V0,V1,V2) */
	SUB(E1,V1,V0);
	SUB(E2,V2,V0);
	CROSS(N1,E1,E2);
	d1=-DOT(N1,V0);
	/* plane equation 1: N1.X+d1=0 */
	
	/* put U0,U1,U2 into plane equation 1 to compute signed distances to the plane*/
	du0=DOT(N1,U0)+d1;
	du1=DOT(N1,U1)+d1;
	du2=DOT(N1,U2)+d1;
	
	/* coplanarity robustness check */
#if USE_EPSILON_TEST==TRUE
	if(FABS(du0)<EPSILON) du0=0.0;
	if(FABS(du1)<EPSILON) du1=0.0;
	if(FABS(du2)<EPSILON) du2=0.0;
#endif
	du0du1=du0*du1;
	du0du2=du0*du2;
	
	if(du0du1>0.0f && du0du2>0.0f) /* same sign on all of them + not equal 0 ? */
		return 0;                    /* no intersection occurs */
	
	/* compute plane of triangle (U0,U1,U2) */
	SUB(E1,U1,U0);
	SUB(E2,U2,U0);
	CROSS(N2,E1,E2);
	d2=-DOT(N2,U0);
	/* plane equation 2: N2.X+d2=0 */
	
	/* put V0,V1,V2 into plane equation 2 */
	dv0=DOT(N2,V0)+d2;
	dv1=DOT(N2,V1)+d2;
	dv2=DOT(N2,V2)+d2;
	
#if USE_EPSILON_TEST==TRUE
	if(FABS(dv0)<EPSILON) dv0=0.0;
	if(FABS(dv1)<EPSILON) dv1=0.0;
	if(FABS(dv2)<EPSILON) dv2=0.0;
#endif
	
	dv0dv1=dv0*dv1;
	dv0dv2=dv0*dv2;
	
	if(dv0dv1>0.0f && dv0dv2>0.0f) /* same sign on all of them + not equal 0 ? */
		return 0;                    /* no intersection occurs */
	
	/* compute direction of intersection line */
	CROSS(D,N1,N2);
	
	/* compute and index to the largest component of D */
	max=(float)FABS(D[0]);
	index=0;
	bb=(float)FABS(D[1]);
	cc=(float)FABS(D[2]);
	if(bb>max) max=bb,index=1;
	if(cc>max) max=cc,index=2;
	
	/* this is the simplified projection onto L*/
	vp0=V0[index];
	vp1=V1[index];
	vp2=V2[index];
	
	up0=U0[index];
	up1=U1[index];
	up2=U2[index];
	
	/* compute interval for triangle 1 */
	float a,b,c,x0,x1;
	NEWCOMPUTE_INTERVALS(vp0,vp1,vp2,dv0,dv1,dv2,dv0dv1,dv0dv2,a,b,c,x0,x1);
	
	/* compute interval for triangle 2 */
	float d,e,f,y0,y1;
	NEWCOMPUTE_INTERVALS(up0,up1,up2,du0,du1,du2,du0du1,du0du2,d,e,f,y0,y1);
	
	float xx,yy,xxyy,tmp;
	xx=x0*x1;
	yy=y0*y1;
	xxyy=xx*yy;
	
	tmp=a*xxyy;
	isect1[0]=tmp+b*x1*yy;
	isect1[1]=tmp+c*x0*yy;
	
	tmp=d*xxyy;
	isect2[0]=tmp+e*xx*y1;
	isect2[1]=tmp+f*xx*y0;
	
	SORT(isect1[0],isect1[1]);
	SORT(isect2[0],isect2[1]);
	
	if(isect1[1]<isect2[0] || isect2[1]<isect1[0]) return 0;
	return 1;
}


@interface CollisionObject () {
	
	NSMutableOrderedSet *_collidableObjects;
	NSMutableOrderedSet *_collisionObservers;
}

- (BOOL)checkCollisionAtNewPosition:(GLKVector3)position andOrientation:(GLKVector3)orientation;
- (void)notifyObserversOfCollisionWithObject:(CollisionObject *)object betweenPolygon:(Triangle)t1 andPolygon:(Triangle)t2;

@end

@implementation CollisionObject

@synthesize collidableObjects = _collidableObjects;

- (id)init {
	if (self = [super init]) {
		
		_radius = 0;
		_collidableObjects = [[NSMutableOrderedSet alloc] init];
		_collisionObservers = [[NSMutableOrderedSet alloc] init];
	}
	return self;
}

- (id)initWithModelName:(NSString *)name {
	
	if (self = [super initWithModelName:name]) {
		
		_collidableObjects = [[NSMutableOrderedSet alloc] init];
		_collisionObservers = [[NSMutableOrderedSet alloc] init];
	}
	return self;
}

- (id)initWithVertexArray:(GLfloat *)vertices vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount texture:(GLuint)texture shader:(Shader *)shader {
	
	if (self = [super initWithVertexArray:vertices vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount texture:texture shader:shader]) {
		
		_collidableObjects = [[NSMutableOrderedSet alloc] init];
		_collisionObservers = [[NSMutableOrderedSet alloc] init];
	}
	return self;
}

- (void)setVertexArray:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount {
	[super setVertexArray:data vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount];
	
	float largest = 0;
	for (int i = 0; i < self.vertexCount * 3; i += 3) {
		float distance = sqrt(self.data[i] * self.data[i] + self.data[i + 1] * self.data[i + 1] + self.data[i + 2] * self.data[i + 2]);
		if (distance > largest) {
			largest = distance;
		}
	}
	_radius = largest;
}

- (void)addCollidableObject:(CollisionObject *)object {
	[_collidableObjects addObject:object];
}

- (void)removeCollidableObject:(CollisionObject *)object {
	[_collidableObjects removeObject:object];
}

- (void)addCollisionObserver:(id<CollisionObjectCollisionObserver>)object {
	[_collisionObservers addObject:object];
}

- (void)removeCollisionObserver:(id<CollisionObjectCollisionObserver>)object {
	[_collisionObservers removeObject:object];
}

- (BOOL)checkCollisionAtNewPosition:(GLKVector3)position andOrientation:(GLKVector3)orientation {
	
	int count = [_collidableObjects count];
	
	GLKMatrix4 myPositionMatrix = GLKMatrix4MakeTranslation(position.x, position.y, -position.z);
	myPositionMatrix = GLKMatrix4RotateZ(GLKMatrix4RotateY(GLKMatrix4RotateX(myPositionMatrix, orientation.x), orientation.y), orientation.z);
	
	
	for (int i = 0; i < count; i++) {
		
		CollisionObject *object = [_collidableObjects objectAtIndex:i];
		
		GLKVector3 objectPosition = object.position;
		
		if (_radius + object.radius > GLKVector3Distance(position, objectPosition)) {
			
			GLKVector3 objectOrientation = object.orientation;
			GLKMatrix4 objectPositionMatrix = GLKMatrix4MakeTranslation(objectPosition.x, objectPosition.y, -objectPosition.z);
			objectPositionMatrix = GLKMatrix4RotateZ(GLKMatrix4RotateY(GLKMatrix4RotateX(objectPositionMatrix, objectOrientation.x), objectOrientation.y), objectOrientation.z);
			
			int count2 = self.vertexCount * 3;
			for (int j = 0; j < count2; j += 9) {
				
				GLKMatrix4 vertex1Triangel1Matrix = GLKMatrix4MakeTranslation(self.data[j], self.data[j + 1], self.data[j + 2]);
				vertex1Triangel1Matrix = GLKMatrix4Multiply(myPositionMatrix, vertex1Triangel1Matrix);
				GLKMatrix4 vertex2Triangel1Matrix = GLKMatrix4MakeTranslation(self.data[j + 3], self.data[j + 4], self.data[j + 5]);
				vertex2Triangel1Matrix = GLKMatrix4Multiply(myPositionMatrix, vertex2Triangel1Matrix);
				GLKMatrix4 vertex3Triangel1Matrix = GLKMatrix4MakeTranslation(self.data[j + 6], self.data[j + 7], self.data[j + 8]);
				vertex3Triangel1Matrix = GLKMatrix4Multiply(myPositionMatrix, vertex3Triangel1Matrix);
				
				GLKVector3 vertex1Triangel1 = GLKVector3TranslationFromMatrix4(vertex1Triangel1Matrix);
				GLKVector3 vertex2Triangel1 = GLKVector3TranslationFromMatrix4(vertex2Triangel1Matrix);
				GLKVector3 vertex3Triangel1 = GLKVector3TranslationFromMatrix4(vertex3Triangel1Matrix);
				
				int count3 = object.vertexCount * 3;
				for (int k = 0; k < count3; k += 9) {
					
					GLKMatrix4 vertex1Triangel2Matrix = GLKMatrix4MakeTranslation(object.data[k], object.data[k + 1], object.data[k + 2]);
					vertex1Triangel2Matrix = GLKMatrix4Multiply(objectPositionMatrix, vertex1Triangel2Matrix);
					GLKMatrix4 vertex2Triangel2Matrix = GLKMatrix4MakeTranslation(object.data[k + 3], object.data[k + 4], object.data[k + 5]);
					vertex2Triangel2Matrix = GLKMatrix4Multiply(objectPositionMatrix, vertex2Triangel2Matrix);
					GLKMatrix4 vertex3Triangel2Matrix = GLKMatrix4MakeTranslation(object.data[k + 6], object.data[k + 7], object.data[k + 8]);
					vertex3Triangel2Matrix = GLKMatrix4Multiply(objectPositionMatrix, vertex3Triangel2Matrix);
					
					GLKVector3 vertex1Triangel2 = GLKVector3TranslationFromMatrix4(vertex1Triangel2Matrix);
					GLKVector3 vertex2Triangel2 = GLKVector3TranslationFromMatrix4(vertex2Triangel2Matrix);
					GLKVector3 vertex3Triangel2 = GLKVector3TranslationFromMatrix4(vertex3Triangel2Matrix);
					
					if (NoDivTriTriIsect(vertex1Triangel1.v, vertex2Triangel1.v, vertex3Triangel1.v, vertex1Triangel2.v, vertex2Triangel2.v, vertex3Triangel2.v)) {
						
						Triangle t1 = TriangleMake(vertex1Triangel1, vertex2Triangel1, vertex3Triangel1);
						Triangle t2 = TriangleMake(vertex1Triangel2, vertex2Triangel2, vertex3Triangel2);
						
						[self notifyObserversOfCollisionWithObject:object betweenPolygon:t1 andPolygon:t2];
						[object notifyObserversOfCollisionWithObject:object betweenPolygon:t2 andPolygon:t1];
						return TRUE;
					}
				}
			}
		}
	}
	return FALSE;
}

- (void)notifyObserversOfCollisionWithObject:(CollisionObject *)object betweenPolygon:(Triangle)t1 andPolygon:(Triangle)t2 {

	int count = [_collisionObservers count];
	for (int i = 0; i < count; i++) {
		[[_collisionObservers objectAtIndex:i] object:self collidedWithObject:object betweenPolygon:t1 andPolygon:t2];
	}
	[self collidedWithObject:object :t1 andPolygon:t2];
}

- (void)setPositionMatrix:(GLKMatrix4)positionMatrix {
	
	
	GLKVector3 position = GLKVector3TranslationFromMatrix4(positionMatrix);
	
	if (!GLKVector3AllEqualToVector3(self.position, position)) {
		[self checkCollisionAtNewPosition:position andOrientation:self.orientation];
	}
	[super setPositionMatrix:positionMatrix];
	
}

- (void)setOrientation:(GLKVector3)orientation {
	

	if (!GLKVector3AllEqualToVector3(self.orientation, orientation)) {
		[self checkCollisionAtNewPosition:self.position andOrientation:orientation];
	}
	[super setOrientation:orientation];
}


- (void)collidedWithObject:(CollisionObject *) betweenPolygon:(Triangle)triangle1 andPolygon:(Triangle)triangle2 {

}


- (void)dealloc {
	[_collidableObjects release];
	[_collisionObservers release];
	[super dealloc];
}

@end
