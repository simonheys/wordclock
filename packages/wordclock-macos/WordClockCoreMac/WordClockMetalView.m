//
//  WordClockMetalView.m
//  WordClock macOS
//
//  MTKView wrapper that owns the Metal renderer.
//

#import "WordClockMetalView.h"

#import "WordClockMetalRenderer.h"

@interface WordClockMetalView () {
    WordClockMetalRenderer *_renderer;
}
@end

@implementation WordClockMetalView

- (instancetype)initWithFrame:(NSRect)frameRect {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    self = [super initWithFrame:frameRect device:device];
    [device release];
    if (self) {
        if (!self.device) {
            [self release];
            return nil;
        }
        self.paused = NO;
        self.enableSetNeedsDisplay = NO;
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        self.framebufferOnly = NO;
        self.tracksMouseEvents = NO;
        _renderer = [[WordClockMetalRenderer alloc] initWithView:self];
        if (!_renderer) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [_renderer release];
    [super dealloc];
}

- (void)updateWordVertices:(const float *)positions colors:(const float *)colors texCoords:(const short *)texCoords wordCount:(NSUInteger)wordCount scale:(float)scale {
    [_renderer updateWordVertices:positions colors:colors texCoords:texCoords wordCount:wordCount scale:scale];
}

- (void)updateWordTextures:(NSArray<id<MTLTexture>> *)textures {
    [_renderer updateWordTextures:textures];
}

- (NSView *)hitTest:(NSPoint)point {
    (void)point;
    return nil;
}

- (void)updateGuideVertices:(const float *)positions colors:(const float *)colors count:(NSUInteger)count {
    [_renderer updateGuideVertices:positions colors:colors count:count];
}

@end
