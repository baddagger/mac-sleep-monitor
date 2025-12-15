import SwiftUI

// MARK: - UnifiedTimelineView
/// 24-hour timeline showing all sleep periods for a day
struct UnifiedTimelineView: View {
    let records: [SleepRecord]
    let selectedRecordID: UUID?
    let onSelect: (SleepRecord) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background - 24 hours
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // Time scale marks
                HStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        HStack(spacing: 0) {
                            Text("\(hour)")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            if hour < 23 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 1, height: 8)
                            }
                        }
                        .frame(width: geometry.size.width / 24)
                    }
                }
                
                // Sleep periods
                ForEach(records) { record in
                    let isSelected = selectedRecordID == record.id
                    Rectangle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: barWidth(for: record, in: geometry.size.width),
                            height: isSelected ? 50 : 40
                        )
                        .cornerRadius(6)
                        .offset(x: barOffset(for: record, in: geometry.size.width))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onSelect(record)
                            }
                        }
                }
            }
        }
    }
    
    private func barOffset(for record: SleepRecord, in width: CGFloat) -> CGFloat {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: record.startTime)
        let secondsFromStart = record.startTime.timeIntervalSince(startOfDay)
        return CGFloat(secondsFromStart / 86400) * width
    }
    
    private func barWidth(for record: SleepRecord, in width: CGFloat) -> CGFloat {
        let widthRatio = record.duration / 86400
        return max(CGFloat(widthRatio) * width, 2) // minimum width 2px
    }
}
