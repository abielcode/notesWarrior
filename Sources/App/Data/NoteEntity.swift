import Foundation

/// Internal data layer type. NEVER referenced outside Data/.
/// Conforms to NoteRepresentable (shared contract) and Codable
/// (data layer concern — JSON serialization).
/// Has no computed UI helpers — that is NoteData's responsibility.
final class NoteEntity: NoteRepresentable, Codable {
    var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, content: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Maps FROM any NoteRepresentable (e.g. NoteData from ViewModel).
    /// This is the only mapping constructor — keeps it in one place.
    convenience init(from representable: some NoteRepresentable) {
        self.init(
            id: representable.id,
            content: representable.content,
            createdAt: representable.createdAt,
            updatedAt: representable.updatedAt
        )
    }
}
