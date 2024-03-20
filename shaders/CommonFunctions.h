//
//  CommonFunctions.h
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#ifndef CommonFunctions_h
#define CommonFunctions_h

template<typename Tx, typename Ty>
inline Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}

template<typename Txy, typename Ta>
inline Txy mix(Txy x, Txy y, Ta a)
{
    return x + (y - x) * a;
}

float contour(float v);

float smin(float a, float b, float k);

#endif /* CommonFunctions_h */
