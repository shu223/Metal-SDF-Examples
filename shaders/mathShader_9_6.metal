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
#include "Textures.h"

float sceneSDF_9_6(float3 p){
    float3 center = float3(0.0);
    float scale = 0.1;
    // 空間を [-0.5, 0.5) 区間に束ね、原点を中心とした半径 0.1 の球を配置
    // fract(p)だと [0, 1) 区間に束ねるが、その範囲を変えるために 0.5 を足し引きしている
    return sphereSDF(fract(p+0.5)-0.5, center, scale);
    // また fract(p) ではなく単に p とすると球が1つだけ描画される
    //return sphereSDF(p, center, scale);
}

float3 gradSDF_9_6(float3 p) {
    float eps = 0.001;
    return normalize(float3(
                            sceneSDF_9_6(p + float3(eps, 0.0, 0.0)) - sceneSDF_9_6(p - float3(eps, 0.0, 0.0)),
                            sceneSDF_9_6(p + float3(0.0, eps, 0.0)) - sceneSDF_9_6(p - float3(0.0, eps, 0.0)),
                            sceneSDF_9_6(p + float3(0.0, 0.0, eps)) - sceneSDF_9_6(p - float3(0.0, 0.0, eps))
                            ));
}

[[ stitchable ]] half4 mathGraphicsShader_9_6(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    float3 t = float3(time * 0.1);

    // カメラの位置
    float3 cPos = euler(float3(0.0, 0.0, 0.5), t);

    // カメラの向き
    float3 cDir = euler(float3(0.0, 0.0, - 1.0), t);

    // カメラの上方向
    float3 cUp = euler(float3(0.0, -1.0, 0.0), t);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = float3(1.0);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 rPos = cPos;

    half3 rgb = half3(0.0);

    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_9_6(rPos) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_9_6(rPos) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), gradSDF_9_6(rPos)), 0.0);

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
