import SwiftUI

/// Full-screen editor. Receives a Binding<NoteData> so edits flow
/// back to the list without a separate save-to-state step.
/// The FIRST LINE of the TextEditor content is the title —
/// no separate title field exists. This is intentional.
struct NoteEditorView: View {
    @Binding var note: NoteData
    let vm: NotesViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 4)

            if note.content.isEmpty {
                Text("First line becomes the title.\nStart writing…")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle(note.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .trailingBar) {
                Button("Save") {
                    note.updatedAt = Date()
                    vm.saveNote(note)
                    dismiss()
                }
                .fontWeight(.semibold)
                .disabled(note.content.trimmingCharacters(
                    in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
