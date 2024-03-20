//
//  circleShader.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"
#include "SDF.h"

[[ stitchable ]] half4 circleShader(float2 position,
                                    half4 color,
                                    float4 boundingRect)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    half3 rgb = contour(circleSDF(p, float2(0.0), 0.9));
    return half4(rgb, 1);
}
