//
//  ContentView.swift
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/18.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack {
            List {
                Section("Book examples") {
                    ForEach(bookShaders, id: \.functionName) { shaderInfo in
                        NavigationLink {
                            DetailView(shaderInfo: shaderInfo)
                        } label: {
                            ShaderRow(shaderInfo: shaderInfo)
                        }
                    }
                }
                Section("Custom examples") {
                    ForEach(customShaders, id: \.functionName) { shaderInfo in
                        NavigationLink {
                            DetailView(shaderInfo: shaderInfo)
                        } label: {
                            ShaderRow(shaderInfo: shaderInfo)
                        }
                    }
                }
            }
            .navigationTitle("SDF with MSL")
        }
    }
}

#Preview {
    ContentView()
}
