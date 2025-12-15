import SwiftUI

struct DaySectionHeader: View {
    let date: Date
    let records: [SleepRecord]
    @Binding var selectedRecord: SleepRecord?
    var isExpanded: Bool = true
    var onToggle: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }

    private var totalSleepTime: TimeInterval {
        records.reduce(0) { $0 + $1.duration }
    }

    private var totalSleepTimeString: String {
        let hours = Int(totalSleepTime) / 3600
        let minutes = (Int(totalSleepTime) % 3600) / 60
        return String(format: NSLocalizedString("total.sleep_time", comment: ""), hours, minutes)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Masking background for sticky header
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 16)

            VStack {
                HStack {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))

                    Text(dateFormatter.string(from: date))
                        .font(.headline)
                    Spacer()
                    Text(totalSleepTimeString)
                }
                .contentShape(Rectangle())
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .onTapGesture {
                    onToggle()
                }

                // Unified timeline
                UnifiedTimelineView(
                    records: records,
                    selectedRecordID: selectedRecord?.id,
                    onSelect: { record in
                        selectedRecord = selectedRecord?.id == record.id ? nil : record
                    },
                )
                .frame(height: 60)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
