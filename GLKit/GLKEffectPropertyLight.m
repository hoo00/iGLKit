//
//  GLKEffectPropertyLight.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectPropertyLight.h>

@interface GLKEffectProperty ()
@property (nonatomic) bool needShaderUpdate;
@end

@interface GLKEffectPropertyLight () {
    GLKVector4 _eyeSpacePosition;
}

- (GLKVector4 *)getEyeSpacePosition;
- (GLKVector4 *)getAmbientColor;
- (GLKVector4 *)getDiffuseColor;
- (GLKVector4 *)getSpecularColor;
- (GLKVector4)getSpotdirectionExponent;
- (GLKVector4)getAttenuationCutoff;

- (void)initProperties;
@end

@implementation GLKEffectPropertyLight
@synthesize enabled = _enabled;
@synthesize position = _position;
@synthesize ambientColor = _ambientColor;
@synthesize diffuseColor = _diffuseColor;
@synthesize specularColor = _specularColor;
@synthesize spotDirection = _spotDirection;
@synthesize spotExponent = _spotExponent;
@synthesize spotCutoff = _spotCutoff;
@synthesize constantAttenuation = _constantAttenuation;
@synthesize linearAttenuation = _linearAttenuation;
@synthesize quadraticAttenuation = _quadraticAttenuation;
@synthesize transform = _transform;

- (void)setEnabled:(GLboolean)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    self.needShaderUpdate = true;
}

- (GLKVector4 *)getEyeSpacePosition {
    return &_eyeSpacePosition;
}
- (GLKVector4 *)getAmbientColor {
    return &_ambientColor;
}
- (GLKVector4 *)getDiffuseColor {
    return &_diffuseColor;
}
- (GLKVector4 *)getSpecularColor {
    return &_specularColor;
}

- (GLKVector4)getSpotdirectionExponent {
    return GLKVector4MakeWithVector3(_spotDirection, _spotExponent);
}

- (GLKVector4)getAttenuationCutoff {
    return GLKVector4Make(_constantAttenuation, _linearAttenuation, _quadraticAttenuation, _spotCutoff);
}

- (void)setSpotCutoff:(GLfloat)spotCutoff {
    if (spotCutoff >= 180.0f) {
        _spotCutoff = 2.0f;
    }
    _spotCutoff = cosf(spotCutoff * M_PI / 180.0f);
}

- (GLfloat)spotCutoff {
    if (_spotCutoff < 0.0f) {
        return 180.0f;
    }
    return acosf(_spotCutoff) * 180.0f * M_1_PI;
}

- (void)setPosition:(GLKVector4)position {
    _position = position;
    if (_position.v[3] != 0.0f && _position.v[3] != 1.0f) {
        _position.v[0] /= _position.v[3];
        _position.v[1] /= _position.v[3];
        _position.v[2] /= _position.v[3];
        _position.v[3] = 1.0f;
    }
    _eyeSpacePosition = GLKMatrix4MultiplyVector4(_transform.modelviewMatrix, _position);
}

- (void)initProperties {
    _enabled = GL_TRUE;
    _position.v[0] = _position.v[1] = _position.v[3] = 0.0f; _position.v[2] = 1.0f;
    _ambientColor.v[0] = _ambientColor.v[1] = _ambientColor.v[2] = 0.0f; _ambientColor.v[3] = 1.0f;
    _diffuseColor.v[0] = _diffuseColor.v[1] = _diffuseColor.v[2] = _diffuseColor.v[3] = 1.0f;
    _specularColor.v[0] = _specularColor.v[1] = _specularColor.v[2] = _specularColor.v[3] = 1.0f;
    _spotDirection.v[0] = _spotDirection.v[1] = 0.0f; _spotDirection.v[2] = -1.0f;
    _spotExponent = 0.0f;
    _spotCutoff = 2.0f;
    _constantAttenuation = 1.0f;
    _linearAttenuation = 0.0f;
    _quadraticAttenuation = 0.0f;
    _transform = nil;
    _eyeSpacePosition = _position;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (void)dealloc
{
    [_transform release];
    [super dealloc];
}

@end