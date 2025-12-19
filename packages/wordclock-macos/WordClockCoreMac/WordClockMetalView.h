//
//  WordClockMetalView.h
//  WordClock macOS
//
//  MTKView wrapper that owns the Metal renderer.
//

#import <MetalKit/MetalKit.h>
@class WordClockMetalRenderer;

@interface WordClockMetalView : MTKView

@property(nonatomic, assign) BOOL tracksMouseEvents;

- (instancetype)initWithFrame:(NSRect)frameRect;
- (void)updateWordVertices:(const float *)positions colors:(const float *)colors texCoords:(const short *)texCoords wordCount:(NSUInteger)wordCount scale:(float)scale;
- (void)updateWordTextures:(NSArray<id<MTLTexture>> *)textures;
- (void)updateGuideVertices:(const float *)positions colors:(const float *)colors count:(NSUInteger)count;

@end
