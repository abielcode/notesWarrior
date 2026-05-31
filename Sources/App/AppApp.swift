import Foundation
import SkipFuse
import SwiftUI

let logger: Logger = Logger(subsystem: "com.abielcode.skipnotes", category: "App")

/* SKIP @bridge */public struct AppRootView: View {
    /* SKIP @bridge */public init() {}

    public var body: some View {
        NoteListView()
    }
}

/* SKIP @bridge */public final class AppAppDelegate: Sendable {
    /* SKIP @bridge */public static let shared = AppAppDelegate()

    private init() {}

    /* SKIP @bridge */public func onInit() { logger.debug("onInit") }
    /* SKIP @bridge */public func onLaunch() { logger.debug("onLaunch") }
    /* SKIP @bridge */public func onResume() { logger.debug("onResume") }
    /* SKIP @bridge */public func onPause() { logger.debug("onPause") }
    /* SKIP @bridge */public func onStop() { logger.debug("onStop") }
    /* SKIP @bridge */public func onDestroy() { logger.debug("onDestroy") }
    /* SKIP @bridge */public func onLowMemory() { logger.debug("onLowMemory") }
}
