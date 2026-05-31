import Foundation

/// Lightweight identity contract shared across layers.
/// Defines what a note IS — not how it is stored or displayed.
/// Intentionally has NO Codable, no persistence, no UI concerns.
protocol NoteRepresentable {
    var id: UUID { get }
    var content: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
}
