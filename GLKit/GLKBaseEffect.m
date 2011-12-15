//
//  GLKBaseEffect.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.
//

#import <GLKit/GLKBaseEffect.h>

// Uniform index
enum {
    UNIFORM_MODELVIEWPROJECTION,
    UNIFORM_MODELVIEW,
    UNIFORM_NORMAL,
    UNIFORM_CONSTANT_COLOR,
    UNIFORM_COLOR_AMBIENT,
    
    UNIFORM_LIGHT0_POSITION,
    UNIFORM_LIGHT0_AMBIENT,
    UNIFORM_LIGHT0_DIFFUSE,
    UNIFORM_LIGHT0_SPECULAR,
    UNIFORM_LIGHT0_SPOTDIRECTION_EXPONENT,
    UNIFORM_LIGHT0_ATTENUATION_CUTOFF,
    
    UNIFORM_LIGHT1_POSITION,
    UNIFORM_LIGHT1_AMBIENT,
    UNIFORM_LIGHT1_DIFFUSE,
    UNIFORM_LIGHT1_SPECULAR,
    UNIFORM_LIGHT1_SPOTDIRECTION_EXPONENT,
    UNIFORM_LIGHT1_ATTENUATION_CUTOFF,

    UNIFORM_LIGHT2_POSITION,
    UNIFORM_LIGHT2_AMBIENT,
    UNIFORM_LIGHT2_DIFFUSE,
    UNIFORM_LIGHT2_SPECULAR,
    UNIFORM_LIGHT2_SPOTDIRECTION_EXPONENT,
    UNIFORM_LIGHT2_ATTENUATION_CUTOFF,

    UNIFORM_MATERIAL_AMBIENT,
    UNIFORM_MATERIAL_DIFFUSE,
    UNIFORM_MATERIAL_SPECULAR,
    UNIFORM_MATERIAL_EMISSIVE,
    UNIFORM_MATERIAL_SHININESS,
    
    UNIFORM_SAMPLER0,
    UNIFORM_SAMPLER1,
    
    UNIFORM_FOG_COLOR,
    UNIFORM_DENSITY_START_END,

    NUM_UNIFORMS
};
// Attribute index
enum {
    ATTRIB_POSITION,
    ATTRIB_NORMAL,
    ATTRIB_COLOR,
    ATTRIB_TEXCOORD0,
    ATTRIB_TEXCOORD1,
    NUM_ATTRIBUTES
};

@interface GLKEffectPropertyFog ()
- (GLKVector4 *)getFogColor;
- (GLKVector3)getDensityStartEnd;
@end
@interface GLKEffectPropertyMaterial ()
- (GLKVector4 *)getAmbientColor;
- (GLKVector4 *)getDiffuseColor;
- (GLKVector4 *)getSpecularColor;
- (GLKVector4 *)getEmissiveColor;
@end

@interface GLKEffectPropertyLight ()
- (GLKVector4 *)getEyeSpacePosition;
- (GLKVector4 *)getAmbientColor;
- (GLKVector4 *)getDiffuseColor;
- (GLKVector4 *)getSpecularColor;
- (GLKVector4)getSpotdirectionExponent;
- (GLKVector4)getAttenuationCutoff;
@end

@interface GLKEffectPropertyTransform ()
- (GLKMatrix4 *)getModelviewProjectionMatrix;
- (GLKMatrix3 *)getNormalMatrix;
- (GLKMatrix4 *)getModelviewMatrix;
@end

@interface GLKEffectProperty ()
@property (nonatomic) bool needShaderUpdate;
@end

#pragma mark -

@interface GLKBaseEffect () {
    GLint uniforms[NUM_UNIFORMS];
    GLuint _program;
    bool _needShaderUpdate;
}
@property (nonatomic, retain) NSMutableArray *effects;
#pragma mark -
#pragma mark Internal methods

- (void)initProperties;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
@end

#pragma mark -

@implementation GLKBaseEffect
@synthesize effects = _effects;

#pragma mark -
#pragma mark Public properties

@synthesize colorMaterialEnabled = _colorMaterialEnabled;
@synthesize lightModelTwoSided = _lightModelTwoSided;
@synthesize useConstantColor = _useConstantColor;

@synthesize transform = _transform;
@synthesize light0, light1, light2;
@synthesize lightingType = _lightingType;
@synthesize lightModelAmbientColor = _lightModelAmbientColor;
@synthesize material = _material;
@synthesize texture2d0 = _texture2d0, texture2d1 = _texture2d1;
@synthesize textureOrder = _textureOrder;
@synthesize constantColor = _constantColor;
@synthesize fog = _fog;
@synthesize label = _label;

#pragma mark -
#pragma mark Getters/Setters

- (void)setUseConstantColor:(GLboolean)useConstantColor {
    if (_useConstantColor == useConstantColor) {
        return;
    }
    _useConstantColor = useConstantColor;
    _needShaderUpdate = true;
}

- (void)setColorMaterialEnabled:(GLboolean)colorMaterialEnabled {
    if (_colorMaterialEnabled == colorMaterialEnabled) {
        return;
    }
    _colorMaterialEnabled = colorMaterialEnabled;
    _needShaderUpdate = true;
}

- (GLKEffectPropertyLight *)light0 {
    if (!_light0) {
        GLKEffectPropertyLight *aLight = [[GLKEffectPropertyLight alloc] init];
        [aLight setTransform:_transform];
        _light0 = aLight;
        [_effects addObject:aLight];
        [aLight release];
        if (self.material) {}
        _needShaderUpdate = true;
    }
    return _light0;
}

- (GLKEffectPropertyLight *)light1 {
    if (!_light1) {
        GLKEffectPropertyLight *aLight = [[GLKEffectPropertyLight alloc] init];
        [aLight setTransform:_transform];
        _light1 = aLight;
        [_effects addObject:aLight];
        [aLight release];
        if (self.material) {}
        _needShaderUpdate = true;
    }
    return _light1;
}

- (GLKEffectPropertyLight *)light2 {
    if (!_light2) {
        GLKEffectPropertyLight *aLight = [[GLKEffectPropertyLight alloc] init];
        [aLight setTransform:_transform];
        _light2 = aLight;
        [_effects addObject:aLight];
        [aLight release];
        if (self.material) {}
        _needShaderUpdate = true;
    }
    return _light2;
}

- (GLKEffectPropertyMaterial *)material {
    if (!_material) {
        GLKEffectPropertyMaterial *aMaterial = [[GLKEffectPropertyMaterial alloc] init];
        _material = aMaterial;
        [_effects addObject:aMaterial];
        [aMaterial release];
        _needShaderUpdate = true;
    }
    return _material;
}

- (GLKEffectPropertyFog *)fog {
    if (!_fog) {
        GLKEffectPropertyFog *aFog = [[GLKEffectPropertyFog alloc] init];
        _fog = aFog;
        [_effects addObject:aFog];
        [aFog release];
        _needShaderUpdate = true;
    }
    return _fog;
}

#pragma mark -
#pragma mark Internal methods

- (void)initProperties {
    NSMutableArray *aMutableArray = [[NSMutableArray alloc] initWithCapacity:8];
    self.effects = aMutableArray;
    [aMutableArray release];
    _program = 0;
    _needShaderUpdate = true;
    
    _colorMaterialEnabled = GL_FALSE;
    _lightModelTwoSided = GL_FALSE;
    _useConstantColor = GL_TRUE;
    
    GLKEffectPropertyTransform *aTransform = [[GLKEffectPropertyTransform alloc] init];
    _transform = aTransform;
    [_effects addObject:aTransform];
    [aTransform release];
    
    _light0 = nil;
    _light1 = nil;
    _light2 = nil;
    _lightingType = GLKLightingTypePerVertex;
    _lightModelAmbientColor.v[0] = _lightModelAmbientColor.v[1] = _lightModelAmbientColor.v[2] = 0.2f; _lightModelAmbientColor.v[3] = 1.0f;
    _material = nil;
    _texture2d0 = nil;
    _texture2d1 = nil;
    _textureOrder = nil;
    _constantColor.v[0] = _constantColor.v[1] = _constantColor.v[2] = _constantColor.v[3] = 1.0f;
    _fog = nil;
    _fogEnabled = GL_FALSE;
    _label = nil;
}

- (BOOL)loadShaders {
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }

    GLuint vertShader, fragShader;

    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *shaderPathname = [[NSBundle mainBundle] pathForResource:@"Shaders" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:shaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:shaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_POSITION, "a_position");
    if ((_light0 && [_light0 enabled]) || (_light1 && [_light1 enabled]) || (_light2 && [_light2 enabled])) {
        glBindAttribLocation(_program, ATTRIB_NORMAL, "a_normal");
    }
    if (!_useConstantColor && (!_material || (_material && _colorMaterialEnabled))) {
        glBindAttribLocation(_program, ATTRIB_COLOR, "a_color");
    }
    if (_texture2d0 && [_texture2d0 enabled]) {
        glBindAttribLocation(_program, ATTRIB_TEXCOORD0, "a_texcoord0");
    }
    if (_texture2d1 && [_texture2d1 enabled]) {
        glBindAttribLocation(_program, ATTRIB_TEXCOORD1, "a_texcoord1");
    }
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION] = glGetUniformLocation(_program, "u_modelviewprojection");
    uniforms[UNIFORM_MODELVIEW] = glGetUniformLocation(_program, "u_modelview");
    uniforms[UNIFORM_NORMAL] = glGetUniformLocation(_program, "u_normal");
    
    uniforms[UNIFORM_CONSTANT_COLOR] = glGetUniformLocation(_program, "u_color_constant");
    uniforms[UNIFORM_COLOR_AMBIENT] = glGetUniformLocation(_program, "u_color_ambient");

    uniforms[UNIFORM_MATERIAL_AMBIENT] = glGetUniformLocation(_program, "u_material_ambient");
    uniforms[UNIFORM_MATERIAL_DIFFUSE] = glGetUniformLocation(_program, "u_material_diffuse");
    uniforms[UNIFORM_MATERIAL_SPECULAR] = glGetUniformLocation(_program, "u_material_specular");
    uniforms[UNIFORM_MATERIAL_EMISSIVE] = glGetUniformLocation(_program, "u_material_emissive");
    uniforms[UNIFORM_MATERIAL_SHININESS] = glGetUniformLocation(_program, "u_material_shininess");

    uniforms[UNIFORM_LIGHT0_POSITION] = glGetUniformLocation(_program, "u_light0_position");
    uniforms[UNIFORM_LIGHT0_AMBIENT] = glGetUniformLocation(_program, "u_light0_ambient");
    uniforms[UNIFORM_LIGHT0_DIFFUSE] = glGetUniformLocation(_program, "u_light0_diffuse");
    uniforms[UNIFORM_LIGHT0_SPECULAR] = glGetUniformLocation(_program, "u_light0_specular");
    uniforms[UNIFORM_LIGHT0_SPOTDIRECTION_EXPONENT] = glGetUniformLocation(_program, "u_light0_spotdirection_exponent");
    uniforms[UNIFORM_LIGHT0_ATTENUATION_CUTOFF] = glGetUniformLocation(_program, "u_light0_attenuation_cutoff");
    
    uniforms[UNIFORM_LIGHT1_POSITION] = glGetUniformLocation(_program, "u_light1_position");
    uniforms[UNIFORM_LIGHT1_AMBIENT] = glGetUniformLocation(_program, "u_light1_ambient");
    uniforms[UNIFORM_LIGHT1_DIFFUSE] = glGetUniformLocation(_program, "u_light1_diffuse");
    uniforms[UNIFORM_LIGHT1_SPECULAR] = glGetUniformLocation(_program, "u_light1_specular");
    uniforms[UNIFORM_LIGHT1_SPOTDIRECTION_EXPONENT] = glGetUniformLocation(_program, "u_light1_spotdirection_exponent");
    uniforms[UNIFORM_LIGHT1_ATTENUATION_CUTOFF] = glGetUniformLocation(_program, "u_light1_attenuation_cutoff");

    uniforms[UNIFORM_LIGHT2_POSITION] = glGetUniformLocation(_program, "u_light2_position");
    uniforms[UNIFORM_LIGHT2_AMBIENT] = glGetUniformLocation(_program, "u_light2_ambient");
    uniforms[UNIFORM_LIGHT2_DIFFUSE] = glGetUniformLocation(_program, "u_light2_diffuse");
    uniforms[UNIFORM_LIGHT2_SPECULAR] = glGetUniformLocation(_program, "u_light2_specular");
    uniforms[UNIFORM_LIGHT2_SPOTDIRECTION_EXPONENT] = glGetUniformLocation(_program, "u_light2_spotdirection_exponent");
    uniforms[UNIFORM_LIGHT2_ATTENUATION_CUTOFF] = glGetUniformLocation(_program, "u_light2_attenuation_cutoff");

    uniforms[UNIFORM_SAMPLER0] = glGetUniformLocation(_program, "u_sampler0");
    uniforms[UNIFORM_SAMPLER0] = glGetUniformLocation(_program, "u_sampler1");
    
    uniforms[UNIFORM_FOG_COLOR] = glGetUniformLocation(_program, "u_fog_color");
    uniforms[UNIFORM_DENSITY_START_END] = glGetUniformLocation(_program, "u_density_start_end");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSMutableString *content;
    if (type == GL_VERTEX_SHADER) {
        content = [NSMutableString stringWithString:@"#define GL_VERTEX_SHADER\n"];
    }
    else {
        content = [NSMutableString stringWithString:@"#define GL_FRAGMENT_SHADER\n"];
    }
    if (_useConstantColor) {
        [content appendString:@"#define CONSTANT_COLOR\n"];
    }
    if (_colorMaterialEnabled) {
        [content appendString:@"#define COLOR_MATERIAL\n"];
    }
    if (_material) {
        [content appendString:@"#define MATERIAL\n"];
    }
    if (_light0 && _light0.enabled) {
        [content appendString:@"#define LIGHT0\n"];
    }
    if (_light1 && _light1.enabled) {
        [content appendString:@"#define LIGHT1\n"];
    }
    if (_light2 && _light2.enabled) {
        [content appendString:@"#define LIGHT2\n"];
    }
    if (_texture2d0 && _texture2d0.enabled) {
        [content appendString:@"#define TEXCOORD0\n"];
        if (_texture2d0.target == GLKTextureTargetCubeMap) {
            [content appendString:@"#define TEXTURE0_CUBE"];
        }
    }
    if (_texture2d1 && _texture2d1.enabled) {
        [content appendString:@"#define TEXCOORD1\n"];
        if (_texture2d1.target == GLKTextureTargetCubeMap) {
            [content appendString:@"#define TEXTURE1_CUBE"];
        }
    }
    if (_textureOrder && [_textureOrder objectAtIndex:0] == _texture2d1) {
        [content appendString:@"#define TEXTURE_ORDER\n"];
        if (_texture2d0 && _texture2d0.envMode == GLKTextureEnvModeReplace) {
            [content appendString:@"#define TEXTURE_REPLACE\n"];
        }
        if (_texture2d0 && _texture2d0.envMode == GLKTextureEnvModeDecal) {
            [content appendString:@"#define TEXTURE_DECAL\n"];
        }
    }
    else {
        if (_texture2d1 && _texture2d1.envMode == GLKTextureEnvModeReplace) {
            [content appendString:@"#define TEXTURE_REPLACE\n"];
        }
        if (_texture2d1 && _texture2d1.envMode == GLKTextureEnvModeDecal) {
            [content appendString:@"#define TEXTURE_DECAL\n"];
        }
    }
    [content appendString:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
    
    const GLchar *source = (GLchar *)[content UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Superclass methods

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (void)dealloc {
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }

    [_effects release];
    [_textureOrder release];
    [_label release];
    [super dealloc];
}

#pragma mark -
#pragma mark Subclass methods

- (void) prepareToDraw {
    for (GLKEffectProperty *aProperty in _effects) {
        if ([aProperty needShaderUpdate]) {
            _needShaderUpdate = true;
            break;
        }
    }
    if (_needShaderUpdate) {
        [self loadShaders];
        _needShaderUpdate = false;
        for (GLKEffectProperty *aProperty in _effects) {
            aProperty.needShaderUpdate = false;
        }
    }
    if (_program) {
        glUseProgram(_program);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION], 1, 0, [_transform getModelviewProjectionMatrix]->m);
        if (uniforms[UNIFORM_MODELVIEW] != -1) {
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW], 1, 0, [_transform getModelviewMatrix]->m);
        }
        if (uniforms[UNIFORM_NORMAL] != -1) {
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL], 1, 0, [_transform getNormalMatrix]->m);            
        }
        if (_useConstantColor && uniforms[UNIFORM_CONSTANT_COLOR] != -1) {
            glUniform4fv(uniforms[UNIFORM_CONSTANT_COLOR], 1, _constantColor.v);
        }
        if (uniforms[UNIFORM_COLOR_AMBIENT] != -1) {
            glUniform4fv(uniforms[UNIFORM_COLOR_AMBIENT], 1, _lightModelAmbientColor.v);
        }
        if (_material) {
            glUniform4fv(uniforms[UNIFORM_MATERIAL_AMBIENT], 1, [_material getAmbientColor]->v);
            glUniform4fv(uniforms[UNIFORM_MATERIAL_DIFFUSE], 1, [_material getDiffuseColor]->v);
            glUniform4fv(uniforms[UNIFORM_MATERIAL_SPECULAR], 1, [_material getSpecularColor]->v);
            glUniform4fv(uniforms[UNIFORM_MATERIAL_EMISSIVE], 1, [_material getEmissiveColor]->v);
            glUniform1f(uniforms[UNIFORM_MATERIAL_SHININESS], [_material shininess]);
        }
        if (_light0 && _light0.enabled) {
            glUniform4fv(uniforms[UNIFORM_LIGHT0_POSITION], 1, [_light0 getEyeSpacePosition]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT0_AMBIENT], 1, [_light0 getAmbientColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT0_DIFFUSE], 1, [_light0 getDiffuseColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT0_SPECULAR], 1, [_light0 getSpecularColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT0_SPOTDIRECTION_EXPONENT], 1, [_light0 getSpotdirectionExponent].v);
            glUniform4fv(uniforms[UNIFORM_LIGHT0_ATTENUATION_CUTOFF], 1, [_light0 getAttenuationCutoff].v);
        }
        if (_light1 && _light1.enabled) {
            glUniform4fv(uniforms[UNIFORM_LIGHT1_POSITION], 1, [_light1 getEyeSpacePosition]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT1_AMBIENT], 1, [_light1 getAmbientColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT1_DIFFUSE], 1, [_light1 getDiffuseColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT1_SPECULAR], 1, [_light1 getSpecularColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT1_SPOTDIRECTION_EXPONENT], 1, [_light1 getSpotdirectionExponent].v);
            glUniform4fv(uniforms[UNIFORM_LIGHT1_ATTENUATION_CUTOFF], 1, [_light1 getAttenuationCutoff].v);
        }
        if (_light2 && _light2.enabled) {
            glUniform4fv(uniforms[UNIFORM_LIGHT2_POSITION], 1, [_light2 getEyeSpacePosition]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT2_AMBIENT], 1, [_light2 getAmbientColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT2_DIFFUSE], 1, [_light2 getDiffuseColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT2_SPECULAR], 1, [_light2 getSpecularColor]->v);
            glUniform4fv(uniforms[UNIFORM_LIGHT2_SPOTDIRECTION_EXPONENT], 1, [_light2 getSpotdirectionExponent].v);
            glUniform4fv(uniforms[UNIFORM_LIGHT2_ATTENUATION_CUTOFF], 1, [_light2 getAttenuationCutoff].v);
        }
        if (_texture2d0 && _texture2d0.enabled) {
            glActiveTexture(GL_TEXTURE0);
            if ([_texture2d0 target] == GLKTextureTarget2D) {
                glBindTexture(GL_TEXTURE_2D, [_texture2d0 name]);
            }
            else {
                glBindTexture(GL_TEXTURE_CUBE_MAP, [_texture2d0 name]);
            }
            glUniform1i(uniforms[UNIFORM_SAMPLER0], 0);
        }
        if (_texture2d1 && _texture2d1.enabled) {
            glActiveTexture(GL_TEXTURE1);
            if ([_texture2d1 target] == GLKTextureTarget2D) {
                glBindTexture(GL_TEXTURE_2D, [_texture2d1 name]);
            }
            else {
                glBindTexture(GL_TEXTURE_CUBE_MAP, [_texture2d1 name]);
            }
            glUniform1i(uniforms[UNIFORM_SAMPLER1], 0);
        }
        if (_fog && _fog.enabled) {
            glUniform4fv(uniforms[UNIFORM_FOG_COLOR], 1, [_fog getFogColor]->v);
            glUniform3fv(uniforms[UNIFORM_DENSITY_START_END], 1, [_fog getDensityStartEnd].v);
        }
    }
}
@end
