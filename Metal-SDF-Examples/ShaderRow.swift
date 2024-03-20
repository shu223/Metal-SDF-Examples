//
//  ShaderRow.swift
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

import SwiftUI

struct ShaderRow: View {
    var shaderInfo: ShaderDescribing

    var body: some View {
        HStack {
            Text(shaderInfo.title)
            Spacer()
        }
    }
}

#Preview {
    ShaderRow(shaderInfo: bookShaders.first!)
}
