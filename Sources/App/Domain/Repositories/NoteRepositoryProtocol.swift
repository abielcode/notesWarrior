import Foundation

/// Domain persistence contract.
/// Speaks exclusively in NoteData — the domain type.
/// The ViewModel depends ONLY on this protocol, never on any
/// Data layer type.
protocol NoteRepositoryProtocol {
    func fetchAll() throws -> [NoteData]
    func save(_ note: NoteData) throws
    func delete(id: UUID) throws
}
