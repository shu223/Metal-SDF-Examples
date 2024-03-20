//
//  ShaderInfo.swift
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

import SwiftUI

protocol ShaderDescribing {
    var title: String { get }
    var functionName: String { get }
    func createShader(seconds: TimeInterval) -> Shader
}

extension ShaderDescribing {
    var function: ShaderFunction {
        ShaderFunction(library: .default,name: functionName)
    }
}

struct ShaderInfo: ShaderDescribing {
    let title: String
    let functionName: String

    func createShader(seconds: TimeInterval) -> Shader {
        return Shader(function: function, arguments: [.boundingRect])
    }
}

struct AnimatedShaderInfo: ShaderDescribing {
    let title: String
    let functionName: String

    func createShader(seconds: TimeInterval) -> Shader {
        return Shader(function: function,
                      arguments: [.boundingRect, .float(seconds)])
    }
}
