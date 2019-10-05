//
//  MyShader.metal
//  MetalPractice
//

#include <metal_stdlib>
using namespace metal;

struct Vertex_In {
    float3 position;
    float4 color;
};

struct RasterizeData {
    float4 position [[position]];
    float4 color;
};


vertex RasterizeData basicVertexShader(device Vertex_In *vertices [[ buffer(0) ]],
                                uint vertexID [[ vertex_id ]]){
    RasterizeData rasterizeData;
    
    rasterizeData.position = float4(vertices[vertexID].position,1.0);
    rasterizeData.color = vertices[vertexID].color;
    
    return rasterizeData;
}

fragment half4 basicFragmentShader(RasterizeData rasterizeData [[stage_in]]){
    
    float4 color = rasterizeData.color;
    
    return half4(color.r, color.g, color.b, color.a);
}
