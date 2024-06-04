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

float length9_9(float3 p, float time){
    float t = time * 0.2;
    // 3つの距離関数の混合
    float v[3] = {euc(p), shogi(p), kyoto(p)};

    // 時間に応じて距離を遷移させる
    float x = fract(t);
    return mix(v[int(t) % 3], v[(int(t) + 1) % 3], smoothstep(0.25, 0.75, x));
}

float sphereSDF9_9(float3 p, float r, float time){
    return length9_9(p, time) - r;
}

// 正八面体の大きさを変えながら立方体との共通部分を取ると、
// 立方体の頂点を削った切頂多面体が得られる
float sceneSDF_9_9(float3 p, float time){
    return sphereSDF9_9(p, 0.5, time);
}

[[ stitchable ]] half4 mathGraphicsShader_9_9(float2 position,
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
    float3 cUp = euler(float3(0.0, -1.0, 0.0), t);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = euler(float3(0.0, 0.0, 1.0), t);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    // レイの正規化をnormalizeではなくlengthで行う
//    ray = normalize(ray);
    ray = ray / length9_9(ray, time);

    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);
    
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_9_9(rPos, time) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_9_9(rPos, time) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), gradSDF(rPos, time, sceneSDF_9_9)), 0.0);

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
