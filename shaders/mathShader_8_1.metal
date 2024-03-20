//
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//
//  The original GLSL code: https://github.com/yutannihilation/math_of_realtime_graphics_wgsl_version

#include <metal_stdlib>
using namespace metal;

#include "RotateFunctions.h"
#include "Textures.h"


[[ stitchable ]] half4 mathGraphicsShader_8_1(float2 position,
                                              half4 color,
                                              float4 boundingRect)
{
    float2 p = (2.0 * position.xy - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    float3 cPos = float3(0.0, 0.0, 0.0);
    // カメラの回転角
    // 書籍サンプルでは、マウスポインタのy座標に応じて変化させていた
    //    float t = -0.5 * PI * (u_mouse.y / u_resolution.y);
    float t = 0;

    // カメラの向き
    float3 cDir = rotX(float3(0.0, 0.0, -1.0), t);
    // カメラの上方向
    float3 cUp = rotX(float3(0.0, -1.0, 0.0), t);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;
    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth - cPos;
    ray = normalize(ray);
    // 地面の法線ベクトル
    float3 groundNormal = float3(0.0, 1.0, 0.0);
    // 地面の高さ
    // 書籍ではマウスポインタの位置（x座標）で変えていた
    //    float groundHeight = 1.0 + (u_mouse.x / u_resolution.x);
    float groundHeight = 2;

    half3 rgb;
    // 交差判定： 地面の法線ベクトルとレイのなす角が90度以上か？
    if (dot(ray, groundNormal) < 0.0){
        // 交差する座標の計算
        float3 hit = cPos - ray * groundHeight / dot(ray, groundNormal);
        // 交差する座標におけるテクスチャを取得
        rgb = half3(text(hit.zx));
    } else {
        rgb = half3(0.0);
    }

    return half4(rgb, 1);
}
