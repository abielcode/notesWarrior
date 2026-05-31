import SwiftUI

/// Stateless list row. Receives NoteData as a value — no bindings.
/// Title uses .headline (bold, primary color).
/// previewBody uses .subheadline (normal weight, secondary color).
/// If previewBody is empty, only the title line is shown.
struct NoteRowView: View {
    let note: NoteData

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)

            if !note.previewBody.isEmpty {
                Text(note.previewBody)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
