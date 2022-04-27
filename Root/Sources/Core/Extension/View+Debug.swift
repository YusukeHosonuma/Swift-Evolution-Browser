//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/04/27.
//

import SwiftUI
import SwiftUISimulator

public extension View {
    func debugFilename(_ file: StaticString = #file) -> some View {
        #if DEBUG
        simulatorDebugFilename(file)
        #else
        self
        #endif
    }
}

// import SwiftUI
//
// public extension String {
//    init(_ staticString: StaticString) {
//        self = staticString.withUTF8Buffer {
//            String(decoding: $0, as: UTF8.self)
//        }
//    }
// }
//
//
// public extension View {
//    func debugFilename(_ filename: StaticString = #file) -> some View {
//        modifier(DebugFilenameModifier(filename: String(String(filename).split(separator: "/").last ?? "")))
//    }
// }
//
// struct DebugViewEnvironmentKey: EnvironmentKey {
//    static var defaultValue: Bool = false
// }
//
// public extension EnvironmentValues {
//    var debugView: Bool {
//        get {
//            self[DebugViewEnvironmentKey.self]
//        }
//        set {
//            self[DebugViewEnvironmentKey.self] = newValue
//        }
//    }
// }
//
// struct DebugFilenameModifier: ViewModifier {
//    let filename: String
//
//    @Environment(\.debugView) var debugView
//    @State var highlight = false
//
//    func body(content: Content) -> some View {
//        #if DEBUG
//        if debugView {
//            if highlight {
//                content
//                    .border(.red, width: 1)
//                    .onTapGesture {
//                        highlight.toggle()
//                    }
//            } else {
//                ZStack(alignment: .topLeading) {
//                    content
//                    Text("\(filename)")
//                        .font(.caption2)
//                        .background(.white.opacity(0.9))
//                        .padding(2)
//                        .border(.blue)
//                        .offset(x: 8, y: 16)
//                        .onTapGesture {
//                            highlight.toggle()
//                        }
//                }
//            }
//        } else {
//            content
//        }
//        #else
//        content
//        #endif
//    }
// }
