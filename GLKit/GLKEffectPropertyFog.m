//
//  GLKEffectPropertyFog.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectPropertyFog.h>

@interface GLKEffectProperty ()
@property (nonatomic) bool needShaderUpdate;
@end

@interface GLKEffectPropertyFog ()
- (GLKVector4 *)getFogColor;
- (GLKVector3)getDensityStartEnd;

- (void)initProperties;
@end

@implementation GLKEffectPropertyFog
@synthesize enabled = _enabled;
@synthesize mode = _mode;
@synthesize color = _color;
@synthesize density = _density;
@synthesize start = _start;
@synthesize end = _end;

- (GLKVector4 *)getFogColor {
    return &_color;
}

- (GLKVector3)getDensityStartEnd {
    return GLKVector3Make(_density, _start, _end);
}

- (void)setEnabled:(GLboolean)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    self.needShaderUpdate = true;
}

- (void)initProperties {
    _enabled = GL_TRUE;
    _mode = GLKFogModeExp;
    _color.v[0] = _color.v[1] = _color.v[2] = _color.v[3] = 0.0f;
    _density = 1.0f;
    _start = 0.0f;
    _end = 1.0f;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

@end