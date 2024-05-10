//
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//
//  The original GLSL code: https://github.com/yutannihilation/math_of_realtime_graphics_wgsl_version

#include <metal_stdlib>
using namespace metal;

#include "RotateFunctions.h"
#include "SDF.h"
#include "GradSDF.h"

float sceneSDF_8_7(float3 p, float time) {
    // y軸を中心に球の中心を回転
    float3 cent = rotY(float3(0.0, 0.0, -0.9), time);
    // 球の半径
    float scale = 0.3;
    return sphereSDF(p, cent, scale);
}

[[ stitchable ]] half4 mathGraphicsShader_8_7(float2 position,
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

    // 平行光を球に合わせて回転
    float3 lDir = rotY(float3(0.0, 0.0, 1.0), time);

    // カメラからスクリーンのマス目へ向かうベクトル
    // これまでは-cPosしていたがここではそれがない
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_8_7(rPos, time) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_8_7(rPos, time) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            // ここが8_6と変わっている（コメントアウトしているのが8_6のコード）
            //            float diff = 0.9 * max(dot(normalize(lPos - rPos), gradSDF(rPos)), 0.0);
            float diff = 0.9 * max(dot(lDir, gradSDF(rPos, time, sceneSDF_8_7)), 0.0);
            // 光の色
            half3 col = half3(0.0, 1.0, 1.0);
            // 拡散光と環境光の和によって光の強さが決まる。これに光の色をかけて色が決まる。
            col *= diff + amb;
            rgb = col;
            break;
        }
    }

    return half4(rgb, 1);
}
