//
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//
//  The original GLSL code: https://github.com/yutannihilation/math_of_realtime_graphics_wgsl_version

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"
#include "RotateFunctions.h"
#include "SDF.h"
#include "GradSDF.h"


float sceneSDF_9_3(float3 p, float time) {
    // 3つずつの小さい球と大きい球のSDFを生成
    float smallS[3], bigS[3];
    for(int i = 0; i < 3; i ++ ){
        // iによってx座標を変えている
        // またsmallの方は時間によってy座標が変わる
        smallS[i] = sphereSDF(p, float3(float(i - 1), sin(time), 0.0), 0.3);
        bigS[i] = sphereSDF(p, float3(float(i - 1), 0.0, 0.0), 0.4);
    }
    // 3パターン表示。それぞれkが違う。kが1に近いほど、くっつきが大きくなる
    float cap = smin(smallS[0], bigS[0], 0.1);
    float cup = smin(smallS[1], bigS[1], 0.3);
    float minus = smin(smallS[2], bigS[2], 0.5);
    return min(min(cap, cup), minus);
}

[[ stitchable ]] half4 mathGraphicsShader_9_3(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    // カメラの位置
    float3 cPos = float3(0.0, 0.0, 2.0);

    // カメラの向き
    float3 cDir = float3(0.0, 0.0, -1.0);

    // カメラの上方向
    float3 cUp = float3(0.0, -1.0, 0.0);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = float3(0.0, 0.0, 1.0);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_9_3(rPos, time) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_9_3(rPos, time) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), gradSDF(rPos, time, sceneSDF_9_3)), 0.0);
            // 光の色
            half3 col = half3(1.0);
            // 拡散光と環境光の和によって光の強さが決まる。これに光の色をかけて色が決まる。
            col *= diff + amb;
            rgb = col;

            break;
        }
    }

    return half4(rgb, 1);
}
