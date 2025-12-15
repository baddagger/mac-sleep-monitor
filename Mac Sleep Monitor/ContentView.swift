import SwiftUI

// MARK: - ContentView

/// Main view displaying sleep records with filtering options
struct ContentView: View {
    @State private var records: [SleepRecord] = []
    @State private var isLoading = false
    @State private var selectedDays = 7
    @State var selectedRecord: SleepRecord?
    @State private var expandedSections: Set<Date> = []

    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            HStack {
                Picker("filter.days", selection: $selectedDays) {
                    Text("filter.1day").tag(1)
                    Text("filter.3days").tag(3)
                    Text("filter.7days").tag(7)
                    Text("filter.30days").tag(30)
                }
                .pickerStyle(.segmented)
                .frame(width: 270)

                Spacer()

                Button(action: loadLogs) {
                    Label("button.refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("status.loading")
                    Spacer()
                }
            } else if records.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("status.no_records")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(recordsByDay.keys.sorted(by: >), id: \.self) { day in
                            let records = recordsByDay[day] ?? []
                            let isExpanded = expandedSections.contains(day)
                            Section {
                                if isExpanded {
                                    DaySectionRecordsView(
                                        date: day,
                                        records: records,
                                        selectedRecordID: selectedRecord?.id,
                                        onSelect: { record in
                                            selectedRecord = selectedRecord?.id == record
                                                .id ? nil : record
                                        },
                                    )
                                    .padding(.top, 8)
                                }
                            } header: {
                                DaySectionHeader(
                                    date: day,
                                    records: records,
                                    selectedRecord: $selectedRecord,
                                    isExpanded: isExpanded,
                                    onToggle: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if expandedSections.contains(day) {
                                                expandedSections.remove(day)
                                            } else {
                                                expandedSections.insert(day)
                                            }
                                        }
                                    },
                                )
                                .id(day) // anchor for scrolling
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear(perform: loadLogs)
        .onChange(of: selectedDays) {
            loadLogs()
        }
    }

    private var recordsByDay: [Date: [SleepRecord]] {
        let calendar = Calendar.current
        return Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.startTime)
        }
    }

    private func loadLogs() {
        isLoading = true
        Task {
            let newRecords = await SleepLogParser.parseLogs(days: selectedDays)
            await MainActor.run {
                records = newRecords
                isLoading = false
            }
        }
    }
}
