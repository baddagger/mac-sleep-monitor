import SwiftUI

// MARK: - DaySectionView

/// Displays all sleep records for a single day with unified timeline
struct DaySectionRecordsView: View {
    let date: Date
    let records: [SleepRecord]
    let selectedRecordID: UUID?
    let onSelect: (SleepRecord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Record list
            VStack(spacing: 8) {
                ForEach(records) { record in
                    SleepRecordRow(
                        record: record,
                        isSelected: selectedRecordID == record.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onSelect(record)
                            }
                        },
                    )
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}
