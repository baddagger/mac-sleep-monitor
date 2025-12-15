import SwiftUI

// MARK: - SleepRecordRow

/// Single sleep record row with details
struct SleepRecordRow: View {
    let record: SleepRecord
    let isSelected: Bool
    let onTap: () -> Void

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "moon.fill" : "moon")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("label.sleep_time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(timeFormatter.string(from: record.startTime))
                            .font(.subheadline)
                            .fontWeight(isSelected ? .semibold : .medium)

                        Text("→")
                            .foregroundColor(.secondary)

                        Text(timeFormatter.string(from: record.endTime))
                            .font(.subheadline)
                            .fontWeight(isSelected ? .semibold : .medium)
                    }

                    HStack {
                        Text("label.duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(record.durationString)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .blue : .primary)
                    }
                }

                Spacer()

                Text(record.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.05) : Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5),
            )
        }
        .buttonStyle(.plain)
    }
}
