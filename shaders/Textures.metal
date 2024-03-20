//
//  Textures.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"

float text(float2 st) {
    return mod(floor(st.x) + floor(st.y), 2.0);
}

