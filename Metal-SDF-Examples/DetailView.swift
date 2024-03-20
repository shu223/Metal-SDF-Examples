//
//  DetailView.swift
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

import SwiftUI

struct DetailView: View {
    var shaderInfo: ShaderDescribing

    var body: some View {
        let start = Date()
        TimelineView(.animation) { context in
            let seconds = context.date.timeIntervalSince(start)

            Rectangle()
                .colorEffect(shaderInfo.createShader(seconds: seconds))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    DetailView(shaderInfo: AnimatedShaderInfo(title: "9_3_smoothMin", functionName: "mathGraphicsShader_9_3"))
}
