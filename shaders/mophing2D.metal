//
//  morphing2D.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"
#include "RotateFunctions.h"
#include "SDF.h"

constant float PI = 3.14159265359;

float sceneSDF_9_2_2D(float2 p, float time) {
    float t = 0.5 * time;
    float d1 = 1.0;

    // 6個全体での半径。これが1.0だと画面幅いっぱいに広がるのではみ出る
    float rad = 0.8;

    // 6個の円の和集合のSDF
    for (float i = 0.0; i < 6.0; i++) {

        // 円周上に円を配置（円の中心を決めている）
        float2 cent = float2(cos(PI * i / 3.0) * rad, sin(PI * i / 3.0) * rad);
        // 和集合を取っていく
        d1 = min(d1, circleSDF(p, cent, 0.2));
    }

    // 原点を中心とした円のSDF
    float d2 = circleSDF(p, float2(0.0), 0.9);

    // ブレンド係数の計算
    // mod(t, 2.0) によりtは0〜2.0を周期的に繰り返す
    // abs(... - 1.0) により0から1の範囲に押し込まれる
    float a = abs(mod(t, 2.0) - 1.0);

    // 2つのSDFの補間
    // aに応じてd1とd2がブレンドされる
    return mix(d1, d2, a);
}

[[ stitchable ]] half4 morphing2DShader(float2 position,
                                        half4 color,
                                        float4 boundingRect,
                                        float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    half3 rgb = contour(sceneSDF_9_2_2D(p, time)) * half3(1);
    return half4(rgb, 1);
}
