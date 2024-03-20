//
//  RotateFunctions.h
//
//  Created by Shuichi Tsutsumi on 2024/03/08.
//  Copyright © 2024 Shuichi Tsutsumi. All rights reserved.
//

#ifndef RotateShaders_h
#define RotateShaders_h

float2 rot2(float2 p, float t);
float3 rotX(float3 p, float t);
float3 rotY(float3 p, float t);
float3 rotZ(float3 p, float t);
float3 euler(float3 p, float3 t);

#endif /* RotateShaders_h */
