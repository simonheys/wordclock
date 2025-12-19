//
//  WordClockMetalRenderer.h
//  WordClock macOS
//
//  Metal renderer for Word Clock.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface WordClockMetalRenderer : NSObject <MTKViewDelegate>

- (instancetype)initWithView:(MTKView *)view;
- (void)updateWordVertices:(const float *)positions colors:(const float *)colors texCoords:(const short *)texCoords wordCount:(NSUInteger)wordCount scale:(float)scale;
- (void)updateWordTextures:(NSArray<id<MTLTexture>> *)textures;
- (void)updateGuideVertices:(const float *)positions colors:(const float *)colors count:(NSUInteger)count;

@end
