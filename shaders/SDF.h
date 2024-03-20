//
//  SDFShaders.h
//  MSLSandbox
//
//  Created by Shuichi Tsutsumi on 2024/03/08.
//  Copyright © 2024 Shuichi Tsutsumi. All rights reserved.
//

#ifndef SDFShaders_h
#define SDFShaders_h

float circleSDF(float2 p, float2 c, float r);

float sphereSDF(float3 p, float3 c, float r);
float sphereSDF(float3 p);

#endif /* SDFShaders_h */
