//
//  GLKEffectPropertyMaterial.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectPropertyMaterial.h>

@interface GLKEffectPropertyMaterial ()
- (GLKVector4 *)getAmbientColor;
- (GLKVector4 *)getDiffuseColor;
- (GLKVector4 *)getSpecularColor;
- (GLKVector4 *)getEmissiveColor;

- (void)initProperties;
@end

@implementation GLKEffectPropertyMaterial
@synthesize ambientColor = _ambientColor;
@synthesize diffuseColor = _diffuseColor;
@synthesize specularColor = _specularColor;
@synthesize emissiveColor = _emissiveColor;
@synthesize shininess = _shininess;

- (GLKVector4 *)getAmbientColor {
    return &_ambientColor;
}
- (GLKVector4 *)getDiffuseColor {
    return &_diffuseColor;
}
- (GLKVector4 *)getSpecularColor {
    return &_specularColor;
}
- (GLKVector4 *)getEmissiveColor {
    return &_emissiveColor;
}

- (void)initProperties {
    _ambientColor.v[0] = _ambientColor.v[1] = _ambientColor.v[2] = 0.2f; _ambientColor.v[3] = 1.0f;
    _diffuseColor.v[0] = _diffuseColor.v[1] = _diffuseColor.v[2] = 0.8f; _diffuseColor.v[3] = 1.0f;
    _specularColor.v[0] = _specularColor.v[1] = _specularColor.v[2] = 0.0f; _specularColor.v[3] = 1.0f;
    _emissiveColor.v[0] = _emissiveColor.v[1] = _emissiveColor.v[2] = 0.0f; _emissiveColor.v[3] = 1.0f;
    _shininess = 0.0f;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

@end