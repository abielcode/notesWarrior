import Foundation
import SkipFuseUI

/// Observable domain orchestrator.
/// Has ZERO knowledge of NoteEntity, LocalNoteRepository,
/// FileManager, or JSON. Depends only on NoteRepositoryProtocol.
@Observable
final class NotesViewModel {
    var notes: [NoteData] = []
    var errorMessage: String? = nil

    private let repository: NoteRepositoryProtocol

    /// Default initializer wires the real stack:
    ///   LocalNoteRepository → NoteEntity → FileManager JSON
    /// Tests inject a mock NoteRepositoryProtocol directly.
    init(repository: NoteRepositoryProtocol = LocalNoteRepository()) {
        self.repository = repository
    }

    /// Loads all notes from repository, sorted by updatedAt descending.
    func loadNotes() {
        do {
            notes = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Saves a note (insert or update) then reloads.
    func saveNote(_ note: NoteData) {
        do {
            try repository.save(note)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes a note by id then reloads.
    func deleteNote(id: UUID) {
        do {
            try repository.delete(id: id)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Returns a fresh blank NoteData ready for editing.
    func newNote() -> NoteData {
        NoteData(
            id: UUID(),
            content: "",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
