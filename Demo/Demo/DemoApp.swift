//
//  DemoApp.swift
//  Demo
//
//  Created by kintan on 11/27/23.
//

import Libmpv
import SwiftUI
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class Player {
    let mpv: OpaquePointer
    init() {
        mpv = mpv_create()
        mpv_initialize(mpv)
        mpv_set_property_string(mpv, "vo", "avfoundation")
        mpv_set_property_string(mpv, "keepaspect", "yes")
        mpv_request_log_messages(mpv, "debug")
    }
}
