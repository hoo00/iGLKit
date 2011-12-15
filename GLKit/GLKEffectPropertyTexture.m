//
//  GLKEffectPropertyTexture.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectPropertyTexture.h>

@interface GLKEffectProperty ()
@property (nonatomic) bool needShaderUpdate;
@end

@interface GLKEffectPropertyTexture ()
- (void)initProperties;
@end

@implementation GLKEffectPropertyTexture
@synthesize enabled = _enabled;
@synthesize name = _name;
@synthesize target = _target;
@synthesize envMode = _envMode;

- (void)setEnabled:(GLboolean)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    self.needShaderUpdate = true;
}

- (void)setEnvMode:(GLint)envMode {
    if (_envMode == envMode) {
        return;
    }
    _envMode = envMode;
    self.needShaderUpdate = true;
}

- (void)setTarget:(GLKTextureTarget)target {
    if (_target == target) {
        return;
    }
    _target = target;
    self.needShaderUpdate = true;
}

- (void)initProperties {
    _enabled = GL_TRUE;
    _name = 0;
    _target = GLKTextureTarget2D;
    _envMode = GLKTextureEnvModeModulate;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

@end