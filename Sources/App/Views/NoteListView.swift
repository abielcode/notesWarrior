import SwiftUI

/// Root view. Owns the ViewModel as @State so it lives for the
/// lifetime of this view tree.
struct NoteListView: View {
    @State var vm = NotesViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.notes) { note in
                    NavigationLink {
                        NoteEditorView(
                            note: bindingFor(note),
                            vm: vm
                        )
                    } label: {
                        NoteRowView(note: note)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.deleteNote(id: note.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .trailingBar) {
                    NavigationLink {
                        NoteEditorView(
                            note: .constant(vm.newNote()),
                            vm: vm
                        )
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear { vm.loadNotes() }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    /// Returns a Binding<NoteData> into vm.notes for a given note.
    /// Safe: if note disappears (e.g. deleted), binding falls back
    /// to a blank note rather than crashing.
    private func bindingFor(_ note: NoteData) -> Binding<NoteData> {
        Binding(
            get: {
                vm.notes.first { $0.id == note.id } ?? note
            },
            set: { updated in
                if let index = vm.notes.firstIndex(where: {
                    $0.id == updated.id
                }) {
                    vm.notes[index] = updated
                }
            }
        )
    }
}
