import Foundation

/// Domain type. What the ViewModel and Views work with exclusively.
/// Conforms to NoteRepresentable as a shared identity contract.
/// NOT Codable — domain types have no knowledge of serialization.
struct NoteData: NoteRepresentable, Identifiable, Equatable {
    let id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date

    /// First line of content, trimmed.
    /// Returns "Untitled" if the first line is empty.
    var title: String {
        let first = content
            .components(separatedBy: "\n")
            .first ?? ""
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }

    /// Everything after the first newline, trimmed.
    /// Returns empty string if there is no second line.
    var body: String {
        let lines = content.components(separatedBy: "\n")
        guard lines.count > 1 else { return "" }
        return lines.dropFirst()
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// First 80 characters of body, with "…" appended if truncated.
    var previewBody: String {
        guard !body.isEmpty else { return "" }
        if body.count <= 80 { return body }
        return String(body.prefix(80)) + "…"
    }
}
