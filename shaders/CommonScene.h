//
//  CommonScene.h
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/04/09.
//

#ifndef CommonScene_h
#define CommonScene_h

typedef float (*SceneSDF)(float3);
typedef float (*SceneSDFWithTime)(float3, float);

float sphereSceneSDF(float3 p);
float3 sphereSceneGradSDF(float3 p);

#endif /* CommonScene_h */
