//
//  GLKEffectProperty.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <GLKit/GLKEffectProperty.h>

@interface GLKEffectProperty ()
@property (nonatomic) bool needShaderUpdate;
@end

@implementation GLKEffectProperty
@synthesize needShaderUpdate = _needShaderUpdate;

- (id)init {
    self = [super init];
    if (self) {
        _needShaderUpdate = false;
        _location = -1;
        _nameString = 0;
    }
    return self;
}

@end