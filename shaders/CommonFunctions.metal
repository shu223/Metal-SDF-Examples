//
//  CommonFunctions.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

float contour(float v) {
    return step(abs(v), 0.008);
}

// 滑らかなmin関数（書籍 p131 コード 9.3）
// aとbは和を取る対象のSDFの値
// kは補間を行うしきい値
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}
