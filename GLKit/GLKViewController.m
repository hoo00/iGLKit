//
//  GLKViewController.m
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKViewController.h>

@interface GLKViewController ()
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) NSDate *firstResume;
@property (nonatomic, retain) NSDate *lastResume;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSDate *lastDraw;
@property (nonatomic, retain) NSDate *lastPause;

#pragma mark -
#pragma mark Internal methods

- (void)initProperties;
- (void)startAnimation;
- (void)stopAnimation;
- (void)executeRunLoop;
@end

#pragma mark -

@implementation GLKViewController
@synthesize displayLink = _displayLink;
@synthesize animationFrameInterval = _animationFrameInterval;
@synthesize firstResume = _firstResume;
@synthesize lastResume = _lastResume;
@synthesize lastUpdate = _lastUpdate;
@synthesize lastDraw = _lastDraw;
@synthesize lastPause = _lastPause;

#pragma mark -
#pragma mark Public properties

@synthesize delegate = _delegate;
@synthesize preferredFramesPerSecond = _preferredFramesPerSecond;
@synthesize framesPerSecond;
@synthesize paused = _paused;
@synthesize framesDisplayed = _framesDisplayed;
@synthesize timeSinceFirstResume;
@synthesize timeSinceLastResume;
@synthesize timeSinceLastUpdate;
@synthesize timeSinceLastDraw;
@synthesize pauseOnWillResignActive = _pauseOnWillResignActive;
@synthesize resumeOnDidBecomeActive = _resumeOnDidBecomeActive;

#pragma mark -
#pragma mark Getters/Setters

- (void)setAnimationFrameInterval:(NSInteger)animationFrameInterval {
    if (animationFrameInterval == _animationFrameInterval) {
        return;
    }
    _animationFrameInterval = animationFrameInterval;
    [self.displayLink invalidate];
    CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(executeRunLoop)];
    [aDisplayLink setFrameInterval:_animationFrameInterval];
    [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = aDisplayLink;    
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;
    if (_preferredFramesPerSecond < 2) {
        self.animationFrameInterval = 60;
        return;
    }
    if (_preferredFramesPerSecond > 30) {
        self.animationFrameInterval = 1;
        return;
    }
    self.animationFrameInterval = 60 / _preferredFramesPerSecond;
}

- (NSInteger)framesPerSecond {
    if (!_lastResume) {
        return 0;
    }
    return (NSInteger)((double)_framesDisplayed / -[_lastResume timeIntervalSinceNow]);
}

- (void)setPaused:(BOOL)paused {
    if (paused) {
        if (!_paused) {
            [self.displayLink invalidate];
            self.displayLink = nil;
            
            NSDate *now = [[NSDate alloc] init];
            self.lastPause = now;
            [now release];
            
            _paused = YES;
        }
        return;
    }
    if (_paused) {
        CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(executeRunLoop)];
        [aDisplayLink setFrameInterval:_animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
            
        NSDate *now = [[NSDate alloc] init];
        if (!_firstResume) self.firstResume = now;
        self.lastResume = now;
        [now release];
        
        self.lastUpdate = [_lastUpdate dateByAddingTimeInterval:-[_lastPause timeIntervalSinceNow]];
        self.lastDraw = [_lastDraw dateByAddingTimeInterval:-[_lastPause timeIntervalSinceNow]];
        
        _paused = NO;
    }
}

- (NSTimeInterval)timeSinceFirstResume {
    return -[_firstResume timeIntervalSinceNow];
}

- (NSTimeInterval)timeSinceLastResume {
    return -[_lastResume timeIntervalSinceNow];
}

- (NSTimeInterval)timeSinceLastUpdate {
    return -[_lastUpdate timeIntervalSinceNow];
}

- (NSTimeInterval)tiemSinceLastDraw {
    return -[_lastDraw timeIntervalSinceNow];
}

- (void)setPauseOnWillResignActive:(BOOL)pauseOnWillResignActive {
    if (pauseOnWillResignActive == _pauseOnWillResignActive) {
        return;
    }
    _pauseOnWillResignActive = pauseOnWillResignActive;
    if (pauseOnWillResignActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation) name:UIApplicationWillResignActiveNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    }
}

- (void)setResumeOnDidBecomeActive:(BOOL)resumeOnDidBecomeActive {
    if (resumeOnDidBecomeActive == _resumeOnDidBecomeActive) {
        return;
    }
    _resumeOnDidBecomeActive = resumeOnDidBecomeActive;
    if (resumeOnDidBecomeActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

#pragma mark -
#pragma mark Internal methods

- (void)initProperties {
    _displayLink = nil;
    _animationFrameInterval = 2;
    _firstResume = nil;
    _lastResume = nil;
    _lastUpdate = nil;
    _lastDraw = nil;
    _lastPause = nil;
    
    _delegate = nil;
    _preferredFramesPerSecond = 30;
    _paused = YES;
    _framesDisplayed = 0;
    _pauseOnWillResignActive = NO;
    self.pauseOnWillResignActive = YES;
    _resumeOnDidBecomeActive = NO;
    self.resumeOnDidBecomeActive = YES;
}

- (void)startAnimation {
    [self setPaused:NO];
}

- (void)stopAnimation {
    [self setPaused:YES];
}

- (void)executeRunLoop {
    [(GLKView *)(self.view) bindDrawable];
    if (_delegate) {
        [_delegate glkViewControllerUpdate:self];
    }
    else {
        if ([self respondsToSelector:@selector(update)]) {
            [self performSelector:@selector(update)];
        }
    }
    NSDate *now = [[NSDate alloc] init];
    self.lastUpdate = now;
    [now release];
    [(GLKView *)(self.view) display];
    now = [[NSDate alloc] init];
    self.lastDraw = now;
    [now release];
    
    ++_framesDisplayed;
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (void)dealloc {
    [self setPaused:YES];
    
    [_firstResume release];
    [_lastResume release];
    [_lastUpdate release];
    [_lastDraw release];
    [_lastPause release];
    
    self.pauseOnWillResignActive = NO;
    self.resumeOnDidBecomeActive = NO;
    [super dealloc];
}

- (void)loadView {
    GLKView *glkView = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds] context:nil];
    [glkView setDelegate:self];
    [glkView setBackgroundColor:[UIColor blackColor]];
    [self setView:glkView];
    [glkView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setPaused:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self setPaused:YES];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
}

@end
