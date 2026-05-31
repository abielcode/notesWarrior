import SwiftUI

extension ToolbarItemPlacement {
    /// Trailing toolbar placement that works on iOS, Android, and macOS.
    static var trailingBar: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .topBarTrailing
        #endif
    }
}
