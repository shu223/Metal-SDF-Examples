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

float kyoto(float3 p){
    float scale = 1.0;
    return scale * (abs(p.x) + abs(p.y) + abs(p.z));
}

float shogi(float3 p){
    float scale =1.;
    return scale * max(max(abs(p.x), abs(p.y)), abs(p.z));
}

float euc(float3 p){
    float scale = 1.0;
    return scale * length(p);
}

float length_(float3 p, float t){
    float time = t * 0.2;
    float v0, v1;
    if (int(time) % 3 == 0){
        v0 = euc(p);
        v1 = shogi(p);
    } else if (int(time) % 3 == 1){
        v0 = shogi(p);
        v1 = kyoto(p);
    } else {
        v0 = kyoto(p);
        v1 = euc(p);
    }
    return mix(v0, v1, smoothstep(0.25, 0.75, fract(time)));
}

float length2(float3 p, float time){
    p = abs(p);
    float d = 4.0 * sin(0.5 * time) + 5.0;
    return pow(pow(p.x, d) + pow(p.y, d) + pow(p.z, d), 1.0 / d);
}

float sphereSDF2(float3 p, float r, float time){
    return length_(p, time) - r;
}

float sceneSDF_9_10(float3 p, float time) {
    return sphereSDF2(p, 0.5, time);
}

float3 gradSDF_9_10(float3 p, float time) {
    float eps = 0.001;
    return normalize(float3(
                            sceneSDF_9_10(p + float3(eps, 0.0, 0.0), time) - sceneSDF_9_10(p - float3(eps, 0.0, 0.0), time),
                            sceneSDF_9_10(p + float3(0.0, eps, 0.0), time) - sceneSDF_9_10(p - float3(0.0, eps, 0.0), time),
                            sceneSDF_9_10(p + float3(0.0, 0.0, eps), time) - sceneSDF_9_10(p - float3(0.0, 0.0, eps), time)
                            ));
}

[[ stitchable ]] half4 mathGraphicsShader_9_10(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    float3 t = float3(time * 0.3);

    // カメラの位置
    float3 cPos = euler(float3(0.0, 0.0, 2.0), t);

    // カメラの向き
    float3 cDir = euler(float3(0.0, 0.0, - 1.0), t);

    // カメラの上方向
    float3 cUp = euler(float3(0.0, 1.0, 0.0), t);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = euler(float3(0.0, 0.0, 1.0), t);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;

    float3 rPos = ray + cPos;

    ray = ray / length2(ray, time);

    half3 rgb = half3(0.0);
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_9_10(rPos, time) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_9_10(rPos, time) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), gradSDF_9_10(rPos, time)), 0.0);
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
