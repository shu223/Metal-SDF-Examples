//
//  morphingCircles.metal
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"
#include "RotateFunctions.h"
#include "SDF.h"

float sceneSDF_9_3_2D(float2 p, float time) {
    // 3つずつの小さい球と大きい球のSDFを生成
    float smallS[3], bigS[3];

    // サイズ調整係数。これが1.0だと画面幅いっぱいに広がるのではみ出る
    float rad = 0.6;

    for(int i = 0; i < 3; i ++ ){
        // iによってx座標を変えている
        // またsmallの方は時間によってy座標が変わる
        smallS[i] = circleSDF(p, float2(float(i - 1) * rad, sin(time)), 0.15);
        bigS[i] = circleSDF(p, float2(float(i - 1) * rad, 0.0), 0.2);
    }
    // 3パターン表示。それぞれkが違う。kが1に近いほど、くっつきが大きくなる
    float cap = smin(smallS[0], bigS[0], 0.1);
    float cup = smin(smallS[1], bigS[1], 0.3);
    float minus = smin(smallS[2], bigS[2], 0.5);
    return min(min(cap, cup), minus);
}

[[ stitchable ]] half4 smoothMin2DShader(float2 position,
                                         half4 color,
                                         float4 boundingRect,
                                         float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    half3 rgb = contour(sceneSDF_9_3_2D(p, time)) * half3(1);
    return half4(rgb, 1);
}
