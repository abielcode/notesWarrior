import Foundation

/// Concrete implementation of NoteRepositoryProtocol.
/// Owns ALL FileManager and JSON logic — nothing else does.
/// Internally uses NoteEntity for Codable serialization.
/// Maps NoteEntity ↔ NoteData at every boundary crossing.
///
/// Persistence target:
///   FileManager.default
///     .urls(for: .documentDirectory, in: .userDomainMask)
///     .first!
///     .appendingPathComponent("notes.json")
///
/// This path resolves correctly on both iOS and Android
/// via SkipFoundation's FileManager — no #if required.
final class LocalNoteRepository: NoteRepositoryProtocol {

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("notes.json")
    }()

    /// Reads [NoteEntity] from disk, maps each to NoteData,
    /// sorts by updatedAt descending (domain-level ordering).
    /// Returns [] if file does not exist.
    /// Throws on corrupt or unreadable data.
    func fetchAll() throws -> [NoteData] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        let entities = try JSONDecoder().decode([NoteEntity].self, from: data)
        return entities
            .sorted { $0.updatedAt > $1.updatedAt }
            .map { NoteData(id: $0.id,
                            content: $0.content,
                            createdAt: $0.createdAt,
                            updatedAt: $0.updatedAt) }
    }

    /// Converts incoming NoteData to NoteEntity, upserts by id
    /// (updates if id exists, appends if new), overwrites file.
    func save(_ note: NoteData) throws {
        var entities = try loadEntities()
        let incoming = NoteEntity(from: note)
        if let index = entities.firstIndex(where: { $0.id == note.id }) {
            entities[index] = incoming
        } else {
            entities.append(incoming)
        }
        try persist(entities)
    }

    /// Removes entity matching id, overwrites file.
    func delete(id: UUID) throws {
        var entities = try loadEntities()
        entities.removeAll { $0.id == id }
        try persist(entities)
    }

    // MARK: - Private helpers

    /// Raw file read → [NoteEntity]. Returns [] if file missing.
    private func loadEntities() throws -> [NoteEntity] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([NoteEntity].self, from: data)
    }

    /// Encodes [NoteEntity] and atomically writes to disk.
    private func persist(_ entities: [NoteEntity]) throws {
        let data = try JSONEncoder().encode(entities)
        try data.write(to: fileURL, options: .atomic)
    }
}
