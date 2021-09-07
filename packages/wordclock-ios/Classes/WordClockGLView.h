//
//  WordClockGLView.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DLog.h"
#import "DisplayLinkManagerTarget.h"
#import "TouchableView.h"
#import "TweenManager.h"
#import "WordClockWordLayout.h"
#import "culling.h"

// allow 14Mb for texture storage (24mb max inclusing framebuffers)
// /2 = 16 bit textures
#define kWordClockWordTextureMaximumPixelsCombined 14 * 1024 * 1024 / 2

@interface WordClockGLView : GLKView {
   @private
    WordClockWordLayout *_layout;
    uint _numberOfWords;

    BOOL _initialised;

    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;

    GLfloat _translateX;
    GLfloat _translateY;
    GLfloat _scale;

    EAGLContext *context;

    int _textureRenderRotaIndex;
    BOOL _textureScalingEnabled;
    BOOL _updateFromPreferences;

    // The OpenGL names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;

    /* OpenGL name for the sprite texture */
    GLuint *_spriteTexture;
    GLshort *_coordinates;
    GLfloat *_vertices;
    WordClockRectsForCulling *_rectsForCulling;
    int *_visibleWordIndices;
    GLfloat *_colours;
    BOOL *_highlighted;
}

- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray;
- (void)deleteTextures;
- (void)renderTextures;
- (void)updateFromPreferences;
- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)drawView;

@property GLfloat scale;
@property GLfloat translateX;
@property GLfloat translateY;
@property(readonly) WordClockWordLayout *layout;
@property BOOL textureScalingEnabled;

@end
