//
//  WordClockMetalRenderer.m
//  WordClock macOS
//
//  Metal renderer for Word Clock.
//

#import "WordClockMetalRenderer.h"

#import <simd/simd.h>
#include <stddef.h>

typedef struct {
    vector_float2 position;
    vector_float2 uv;
    vector_float4 color;
} WordVertex;

typedef struct {
    matrix_float4x4 projection;
} VSUniforms;

static matrix_float4x4 WordClockOrtho(CGFloat left, CGFloat right, CGFloat bottom, CGFloat top, CGFloat nearZ, CGFloat farZ) {
    const float r_l = (float)(right - left);
    const float t_b = (float)(top - bottom);
    const float f_n = (float)(farZ - nearZ);

    matrix_float4x4 m = matrix_identity_float4x4;
    m.columns[0].x = 2.0f / r_l;
    m.columns[1].y = 2.0f / t_b;
    m.columns[2].z = 1.0f / f_n;
    m.columns[3].x = -((float)(right + left) / r_l);
    m.columns[3].y = -((float)(top + bottom) / t_b);
    m.columns[3].z = -((float)nearZ / f_n);
    return m;
}

@interface WordClockMetalRenderer () {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _library;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLBuffer> _quadVertexBuffer;
    id<MTLBuffer> _wordVertexBuffer;
    NSUInteger _wordVertexCount;
    NSUInteger _wordCount;
    id<MTLBuffer> _guideVertexBuffer;
    NSUInteger _guideVertexCount;
    id<MTLBuffer> _uniformBuffer;
    id<MTLSamplerState> _samplerState;
    id<MTLTexture> _opaqueTexture;
    id<MTLTexture> _transparentTexture;
    NSMutableArray<id<MTLTexture>> *_wordTextures;
    MTKView *_view;
}
@end

@implementation WordClockMetalRenderer

- (id<MTLTexture>)buildSolidTextureWithAlpha:(uint8_t)alpha {
    uint8_t pixel[4] = {255, 255, 255, alpha};
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:1 height:1 mipmapped:NO];
    descriptor.usage = MTLTextureUsageShaderRead;
    id<MTLTexture> texture = [_device newTextureWithDescriptor:descriptor];
    if (!texture) {
        return nil;
    }
    MTLRegion region = MTLRegionMake2D(0, 0, 1, 1);
    [texture replaceRegion:region mipmapLevel:0 withBytes:pixel bytesPerRow:4];
    return texture;
}

- (void)updateQuadForSize:(CGSize)size {
    if (!_quadVertexBuffer) {
        return;
    }
    const float halfWidth = (float)size.width * 0.5f;
    const float halfHeight = (float)size.height * 0.5f;
    WordVertex quad[6] = {
        {.position = {-halfWidth, halfHeight}, .uv = {0.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {halfWidth, halfHeight}, .uv = {1.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {-halfWidth, -halfHeight}, .uv = {0.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {-halfWidth, -halfHeight}, .uv = {0.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {halfWidth, halfHeight}, .uv = {1.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {halfWidth, -halfHeight}, .uv = {1.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}},
    };
    memcpy([_quadVertexBuffer contents], quad, sizeof(quad));
}

- (MTLVertexDescriptor *)buildVertexDescriptor {
    MTLVertexDescriptor *descriptor = [[[MTLVertexDescriptor alloc] init] autorelease];
    descriptor.attributes[0].format = MTLVertexFormatFloat2;
    descriptor.attributes[0].offset = offsetof(WordVertex, position);
    descriptor.attributes[0].bufferIndex = 0;

    descriptor.attributes[1].format = MTLVertexFormatFloat2;
    descriptor.attributes[1].offset = offsetof(WordVertex, uv);
    descriptor.attributes[1].bufferIndex = 0;

    descriptor.attributes[2].format = MTLVertexFormatFloat4;
    descriptor.attributes[2].offset = offsetof(WordVertex, color);
    descriptor.attributes[2].bufferIndex = 0;

    descriptor.layouts[0].stride = sizeof(WordVertex);
    descriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    descriptor.layouts[0].stepRate = 1;
    return descriptor;
}

- (instancetype)initWithView:(MTKView *)view {
    self = [super init];
    if (self) {
        id<MTLDevice> device = view.device ?: MTLCreateSystemDefaultDevice();
        if (!device) {
            [self release];
            return nil;
        }
        _device = [device retain];
        _commandQueue = [_device newCommandQueue];
        NSError *libraryError = nil;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _library = [_device newDefaultLibraryWithBundle:bundle error:&libraryError];
        if (!_library) {
            _library = [_device newDefaultLibrary];
        }
        if (!_library && libraryError) {
            NSLog(@"Failed to load metal library: %@", libraryError);
        }
        _pipelineState = [self buildPipeline];
        _quadVertexBuffer = [self buildQuad];
        _uniformBuffer = [_device newBufferWithLength:sizeof(VSUniforms) options:MTLResourceStorageModeShared];
        _wordTextures = [[NSMutableArray alloc] init];
        MTLSamplerDescriptor *samplerDesc = [[[MTLSamplerDescriptor alloc] init] autorelease];
        samplerDesc.minFilter = MTLSamplerMinMagFilterLinear;
        samplerDesc.magFilter = MTLSamplerMinMagFilterLinear;
        samplerDesc.sAddressMode = MTLSamplerAddressModeClampToEdge;
        samplerDesc.tAddressMode = MTLSamplerAddressModeClampToEdge;
        _samplerState = [_device newSamplerStateWithDescriptor:samplerDesc];

        _opaqueTexture = [[self buildSolidTextureWithAlpha:255] retain];
        _transparentTexture = [[self buildSolidTextureWithAlpha:0] retain];
        _view = view;
        _view.device = _device;
        _view.delegate = self;
        _view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        _view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        _view.framebufferOnly = NO;
        [self updateUniformsForSize:_view.bounds.size];
        [self updateQuadForSize:_view.bounds.size];
    }
    return self;
}

- (void)dealloc {
    _view.delegate = nil;
    [_uniformBuffer release];
    [_wordVertexBuffer release];
    [_guideVertexBuffer release];
    [_wordTextures release];
    [_samplerState release];
    [_opaqueTexture release];
    [_transparentTexture release];
    [_quadVertexBuffer release];
    [_pipelineState release];
    [_library release];
    [_commandQueue release];
    [_device release];
    [super dealloc];
}

- (id<MTLRenderPipelineState>)buildPipeline {
    if (!_library) {
        return nil;
    }
    id<MTLFunction> vertex = [_library newFunctionWithName:@"wordclock_vertex"];
    id<MTLFunction> fragment = [_library newFunctionWithName:@"wordclock_fragment"];
    if (!vertex || !fragment) {
        [vertex release];
        [fragment release];
        return nil;
    }
    MTLRenderPipelineDescriptor *desc = [[[MTLRenderPipelineDescriptor alloc] init] autorelease];
    desc.label = @"WordClock Pipeline";
    desc.vertexFunction = vertex;
    desc.fragmentFunction = fragment;
    desc.vertexDescriptor = [self buildVertexDescriptor];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    desc.colorAttachments[0].blendingEnabled = YES;
    desc.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    desc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    desc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
    desc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
    desc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    desc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;

    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:desc error:&error];
    [vertex release];
    [fragment release];
    if (!pipeline) {
        NSLog(@"Failed to build pipeline: %@", error);
    }
    return pipeline;
}

- (id<MTLBuffer>)buildQuad {
    static const WordVertex quad[6] = {
        {.position = {-1.0f, -1.0f}, .uv = {0.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {1.0f, -1.0f}, .uv = {1.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {-1.0f, 1.0f}, .uv = {0.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {-1.0f, 1.0f}, .uv = {0.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {1.0f, -1.0f}, .uv = {1.0f, 1.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}}, {.position = {1.0f, 1.0f}, .uv = {1.0f, 0.0f}, .color = {0.1f, 0.1f, 0.1f, 1.0f}},
    };
    return [_device newBufferWithBytes:quad length:sizeof(quad) options:MTLResourceStorageModeShared];
}

- (void)updateUniformsForSize:(CGSize)size {
    if (!_uniformBuffer) {
        return;
    }
    VSUniforms *uniforms = (VSUniforms *)[_uniformBuffer contents];
    const float halfWidth = (float)size.width * 0.5f;
    const float halfHeight = (float)size.height * 0.5f;
    uniforms->projection = WordClockOrtho(-halfWidth, halfWidth, halfHeight, -halfHeight, 0.0f, 1.0f);
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    (void)view;
    (void)size;
    [self updateUniformsForSize:view.bounds.size];
    [self updateQuadForSize:view.bounds.size];
}

- (void)drawInMTKView:(MTKView *)view {
    id<CAMetalDrawable> drawable = [view currentDrawable];
    if (!drawable) {
        return;
    }
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *pass = view.currentRenderPassDescriptor;
    if (!pass) {
        [commandBuffer commit];
        return;
    }
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:pass];
    if (_pipelineState) {
        [encoder setRenderPipelineState:_pipelineState];
        if (_wordVertexBuffer && _wordVertexCount > 0) {
            [encoder setVertexBuffer:_wordVertexBuffer offset:0 atIndex:0];
        } else {
            [encoder setVertexBuffer:_quadVertexBuffer offset:0 atIndex:0];
        }
        [encoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        if (_samplerState) {
            [encoder setFragmentSamplerState:_samplerState atIndex:0];
        }
        if (_wordVertexBuffer && _wordVertexCount > 0) {
            for (NSUInteger i = 0; i < _wordCount; i++) {
                id<MTLTexture> texture = nil;
                if (i < [_wordTextures count]) {
                    id candidate = [_wordTextures objectAtIndex:i];
                    if (candidate != [NSNull null]) {
                        texture = candidate;
                    }
                }
                if (!texture) {
                    texture = _transparentTexture;
                }
                [encoder setFragmentTexture:texture atIndex:0];
                [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:(NSUInteger)(i * 6) vertexCount:6];
            }
        } else {
            [encoder setFragmentTexture:_opaqueTexture atIndex:0];
            [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        }
        if (_guideVertexBuffer && _guideVertexCount > 0) {
            [encoder setVertexBuffer:_guideVertexBuffer offset:0 atIndex:0];
            [encoder setFragmentTexture:_opaqueTexture atIndex:0];
            [encoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:0 vertexCount:_guideVertexCount];
        }
    }
    [encoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)updateWordVertices:(const float *)positions colors:(const float *)colors texCoords:(const short *)texCoords wordCount:(NSUInteger)wordCount scale:(float)scale {
    if (!positions || !colors || wordCount == 0) {
        _wordVertexCount = 0;
        _wordCount = 0;
        return;
    }
    const NSUInteger vertexCount = wordCount * 6;
    const NSUInteger bufferLength = vertexCount * sizeof(WordVertex);

    if (!_wordVertexBuffer || [_wordVertexBuffer length] < bufferLength) {
        [_wordVertexBuffer release];
        _wordVertexBuffer = [_device newBufferWithLength:bufferLength options:MTLResourceStorageModeShared];
    }
    _wordVertexCount = vertexCount;
    _wordCount = wordCount;

    WordVertex *outVertices = (WordVertex *)[_wordVertexBuffer contents];
    for (NSUInteger i = 0; i < wordCount; i++) {
        const float *pos = positions + (i * 8);
        const float *col = colors + (i * 16);
        const short *uv = texCoords ? (texCoords + (i * 8)) : NULL;

        const float x0 = pos[0] * scale;
        const float y0 = pos[1] * scale;
        const float x1 = pos[2] * scale;
        const float y1 = pos[3] * scale;
        const float x2 = pos[4] * scale;
        const float y2 = pos[5] * scale;
        const float x3 = pos[6] * scale;
        const float y3 = pos[7] * scale;

        const float u0 = uv ? (float)uv[0] : 0.0f;
        const float v0 = uv ? (float)uv[1] : 0.0f;
        const float u1 = uv ? (float)uv[2] : 1.0f;
        const float v1 = uv ? (float)uv[3] : 1.0f;
        const float u2 = uv ? (float)uv[4] : 0.0f;
        const float v2 = uv ? (float)uv[5] : 0.0f;
        const float u3 = uv ? (float)uv[6] : 1.0f;
        const float v3 = uv ? (float)uv[7] : 0.0f;

        const vector_float4 c0 = {col[0], col[1], col[2], col[3]};
        const vector_float4 c1 = {col[4], col[5], col[6], col[7]};
        const vector_float4 c2 = {col[8], col[9], col[10], col[11]};
        const vector_float4 c3 = {col[12], col[13], col[14], col[15]};

        const NSUInteger base = i * 6;
        outVertices[base + 0] = (WordVertex){.position = {x0, y0}, .uv = {u0, v0}, .color = c0};
        outVertices[base + 1] = (WordVertex){.position = {x1, y1}, .uv = {u1, v1}, .color = c1};
        outVertices[base + 2] = (WordVertex){.position = {x2, y2}, .uv = {u2, v2}, .color = c2};
        outVertices[base + 3] = (WordVertex){.position = {x2, y2}, .uv = {u2, v2}, .color = c2};
        outVertices[base + 4] = (WordVertex){.position = {x1, y1}, .uv = {u1, v1}, .color = c1};
        outVertices[base + 5] = (WordVertex){.position = {x3, y3}, .uv = {u3, v3}, .color = c3};
    }
}

- (void)updateWordTextures:(NSArray<id<MTLTexture>> *)textures {
    [_wordTextures release];
    _wordTextures = [textures mutableCopy];
}

- (void)updateGuideVertices:(const float *)positions colors:(const float *)colors count:(NSUInteger)count {
    if (!positions || !colors || count == 0) {
        _guideVertexCount = 0;
        return;
    }
    const NSUInteger bufferLength = count * sizeof(WordVertex);
    if (!_guideVertexBuffer || [_guideVertexBuffer length] < bufferLength) {
        [_guideVertexBuffer release];
        _guideVertexBuffer = [_device newBufferWithLength:bufferLength options:MTLResourceStorageModeShared];
    }
    WordVertex *outVertices = (WordVertex *)[_guideVertexBuffer contents];
    for (NSUInteger i = 0; i < count; i++) {
        const float x = positions[i * 2 + 0];
        const float y = positions[i * 2 + 1];
        const float r = colors[i * 4 + 0];
        const float g = colors[i * 4 + 1];
        const float b = colors[i * 4 + 2];
        const float a = colors[i * 4 + 3];
        outVertices[i] = (WordVertex){
            .position = {x, y},
            .uv = {0.5f, 0.5f},
            .color = {r, g, b, a},
        };
    }
    _guideVertexCount = count;
}

@end
