//
//  GLKView.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKView.h>

@interface GLKView () {
    GLuint _defaultFramebuffer;
    GLuint _colorRenderbuffer;
    GLuint _depthRenderbuffer;
}

- (void)initProperties;
- (void)createDrawable;
@end

#pragma mark -

@implementation GLKView
@synthesize delegate = _delegate;
@synthesize context = _context;
@synthesize drawableWidth = _drawableWidth;
@synthesize drawableHeight = _drawableHeight;
@synthesize drawableColorFormat = _drawableColorFormat;
@synthesize drawableDepthFormat = _drawableDepthFormat;
@synthesize drawableStencilFormat = _drawableStencilFormat;
@synthesize drawableMultisample = _drawableMultisample;

@synthesize enableSetNeedsDisplay = _enableSetNeedsDisplay;

#pragma mark -
#pragma mark Getters/Setters

- (void)setContext:(EAGLContext *)context {
    if (_context == context) {
        return;
    }
    [self deleteDrawable];
    [_context release];
    _context = [context retain];
    
    [EAGLContext setCurrentContext:nil];
}

#pragma mark -
#pragma mark Internal methods

- (void)initProperties {
    _defaultFramebuffer = _colorRenderbuffer = _depthRenderbuffer = 0;
    
    _delegate = nil;
    _context = nil;
    
    _drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    _drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    _drawableStencilFormat = GLKViewDrawableStencilFormatNone;
    _drawableMultisample = GLKViewDrawableMultisampleNone;
    
    _enableSetNeedsDisplay = TRUE;
    
    // Retina
    if ([self respondsToSelector:@selector(contentScaleFactor)]) {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)createDrawable {
    if (_context && !_defaultFramebuffer) {
        [EAGLContext setCurrentContext:_context];
        // frame
        glGenFramebuffers(1, &_defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        // color
        glGenRenderbuffers(1, &_colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_drawableWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_drawableHeight);
        // depth, optional
        if (_drawableDepthFormat != GLKViewDrawableDepthFormatNone) {
            glGenRenderbuffers(1, &_depthRenderbuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
            if (_drawableDepthFormat == GLKViewDrawableDepthFormat16) {
                glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _drawableWidth, _drawableHeight);
            }
            else {
                glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, _drawableWidth, _drawableHeight);
            }
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
        }
        // checking
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
    }
}

#pragma mark -
#pragma mark Superclass methods

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
        [self setContext:context];
    }
    return self;
}

- (void)dealloc {
    [self deleteDrawable];
    [_context release];
    
    [super dealloc];
}

- (void)layoutSubviews {
    [self deleteDrawable];
}

#pragma mark -
#pragma mark Subclass methods

- (void)bindDrawable {
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        if (!_defaultFramebuffer) {
            [self createDrawable];
        }
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        glViewport(0, 0, _drawableWidth, _drawableHeight);
    }
}

- (void)deleteDrawable {
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        if (_defaultFramebuffer) {
            glDeleteFramebuffers(1, &_defaultFramebuffer);
            _defaultFramebuffer = 0;
        }
        if (_colorRenderbuffer) {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
        if (_depthRenderbuffer) {
            glDeleteRenderbuffers(1, &_depthRenderbuffer);
            _depthRenderbuffer = 0;
        }
    }
}

- (UIImage *)snapshot {
    // Apple's Technical Q&A QA1704: OpenGL ES View Snapshot
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    NSInteger x = 0, y = 0, width = _drawableWidth, height = _drawableHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast, ref, NULL, true, kCGRenderingIntentDefault);
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        CGFloat scale = self.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    return image;
}

- (void)display {
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        if (_delegate) {
            [_delegate glkView:self drawInRect:[self bounds]];
        }
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

@end