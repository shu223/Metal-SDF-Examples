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
#include "CommonScene.h"
#include "Textures.h"


[[ stitchable ]] half4 mathGraphicsShader_9_4(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    float t = time * 0.3;

    // カメラの位置
    float3 cPos = rotY(float3(0.0, 0.0, 2.0), t);

    // カメラの向き
    float3 cDir = rotY(float3(0.0, 0.0, - 1.0), t);

    // カメラの上方向
    float3 cUp = rotY(float3(0.0, -1.0, 0.0), t);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = rotY(float3(1.0), t);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);


    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sphereSceneSDF(rPos) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sphereSceneSDF(rPos) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), sphereSceneGradSDF(rPos)), 0.0);

            // 光の色
            // 3次元パーリンノイズをソリッドテクスチャリング
            // c.f. これまでは単一色
            float text = pnoise31(10.0 * rPos);
            half3 col = half3(text);

            // 拡散光と環境光の和によって光の強さが決まる。これに光の色をかけて色が決まる。
            col *= diff + amb;
            rgb = col;

            break;
        }
    }
    return half4(rgb, 1);
}
