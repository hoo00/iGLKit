//
//  GLKEffectPropertyTransform.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectPropertyTransform.h>

@interface GLKEffectPropertyTransform () {
    BOOL _normalStale;
    BOOL _modelviewProjectionStale;
    
    GLKMatrix4 _modelviewProjectionMatrix;
}
- (GLKMatrix4 *)getModelviewProjectionMatrix;
- (GLKMatrix3 *)getNormalMatrix;
- (GLKMatrix4 *)getModelviewMatrix;

- (void)initProperties;
@end

@implementation GLKEffectPropertyTransform
@synthesize modelviewMatrix = _modelviewMatrix;
@synthesize projectionMatrix = _projectionMatrix;
@synthesize normalMatrix;

- (GLKMatrix4 *)getModelviewProjectionMatrix {
    if (_modelviewProjectionStale) {
        _modelviewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelviewMatrix);
        _modelviewProjectionStale = FALSE;
    }
    return &_modelviewProjectionMatrix;
}

- (GLKMatrix3 *)getNormalMatrix {
    if (_normalStale) {
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelviewMatrix), NULL);
        _normalStale = FALSE;
    }
    return &_normalMatrix;
}

- (GLKMatrix4 *)getModelviewMatrix {
    return &_modelviewMatrix;
}

- (GLKMatrix3)normalMatrix {
    if (_normalStale) {
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelviewMatrix), NULL);
        _normalStale = FALSE;
    }
    return _normalMatrix;
}

- (void)setModelviewMatrix:(GLKMatrix4)modelviewMatrix {
    _modelviewMatrix = modelviewMatrix;
    _normalStale = TRUE;
    _modelviewProjectionStale = TRUE;
}

- (void)setProjectionMatrix:(GLKMatrix4)projectionMatrix {
    _projectionMatrix = projectionMatrix;
    _modelviewProjectionStale = TRUE;
}

- (void)initProperties {
    _normalStale = FALSE;
    _modelviewProjectionStale = FALSE;
    _modelviewProjectionMatrix = GLKMatrix4Identity;
    
    _modelviewMatrix = _projectionMatrix = GLKMatrix4Identity;
    _normalMatrix = GLKMatrix3Identity;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

@end