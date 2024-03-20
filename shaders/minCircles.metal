//
//  minCircles.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/20.
//

#include <metal_stdlib>
using namespace metal;



#include "CommonFunctions.h"
#include "SDF.h"

[[ stitchable ]] half4 minCircles(float2 position,
                                  half4 color,
                                  float4 boundingRect)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    float d1 = circleSDF(p, float2(0,  0.5), 0.9);
    float d2 = circleSDF(p, float2(0, -0.5), 0.5);
    float u = min(d1, d2);
    half3 rgb = contour(u);
    return half4(rgb, 1);
}
