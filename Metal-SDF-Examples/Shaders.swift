//
//  Shaders.swift
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

import SwiftUI

let bookShaders: [ShaderDescribing] = [
    ShaderInfo(title: "8_1_texMapping", functionName: "mathGraphicsShader_8_1"),
    ShaderInfo(title: "8_2_lighting", functionName: "mathGraphicsShader_8_2"),
    AnimatedShaderInfo(title: "8_6_sphere", functionName: "mathGraphicsShader_8_6"),
    AnimatedShaderInfo(title: "8_7_rotSphere", functionName: "mathGraphicsShader_8_7"),
    AnimatedShaderInfo(title: "9_2_morphing", functionName: "mathGraphicsShader_9_2"),
    AnimatedShaderInfo(title: "9_3_smoothMin", functionName: "mathGraphicsShader_9_3"),
]

let customShaders: [ShaderDescribing] = [
    ShaderInfo(title: "Circle SDF", functionName: "circleShader"),
    ShaderInfo(title: "Union of SDFs", functionName: "minCircles"),
    AnimatedShaderInfo(title: "2D Morphing", functionName: "morphing2DShader"),
    AnimatedShaderInfo(title: "2D Smooth Min", functionName: "smoothMin2DShader"),
]
