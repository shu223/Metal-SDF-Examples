//
//  GradSDF.h
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/05/10.
//

#ifndef GradSDF_h
#define GradSDF_h

#include "CommonScene.h"

float3 gradSDF(float3 p, SceneSDF sceneSDF);
float3 gradSDF(float3 p, float time, SceneSDFWithTime sceneSDF);

#endif /* GradSDF_h */
