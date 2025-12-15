import Foundation

// MARK: - SleepLogParser
/// Parses macOS power management logs to extract sleep records
class SleepLogParser {
    static func parseLogs(days: Int = 7) async -> [SleepRecord] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "log"]
        
        // Set environment variables to use shell environment
        process.environment = ProcessInfo.processInfo.environment
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            // Read data asynchronously in background thread to avoid deadlock
            let outputData = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    continuation.resume(returning: data)
                }
            }
            
            let errorData = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    continuation.resume(returning: data)
                }
            }
            
            process.waitUntilExit()
            
            // Check error output
            if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
                print("Error output: \(errorOutput)")
            }
            
            // Check return code
            if process.terminationStatus != 0 {
                print("Command failed with code: \(process.terminationStatus)")
                return []
            }
            
            guard let output = String(data: outputData, encoding: .utf8), !output.isEmpty else {
                print("Empty output")
                return []
            }
            
            print("Successfully read \(output.count) characters of log data")
            return parseOutput(output, days: days)
            
        } catch {
            print("Failed to execute command: \(error)")
            return []
        }
    }
    
    private static func parseOutput(_ output: String, days: Int) -> [SleepRecord] {
        let lines = output.components(separatedBy: .newlines)
        var records: [SleepRecord] = []
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        print("Starting parse, total lines: \(lines.count)")
        var foundCount = 0
        
        for line in lines {
            if line.contains("Entering Sleep state") {
                foundCount += 1
                if let record = parseSleepLine(line) {
                    if record.startTime >= cutoffDate {
                        records.append(record)
                    }
                } else {
                    print("Failed to parse line: \(line)")
                }
            }
        }
        
        print("Found \(foundCount) sleep records, valid records: \(records.count)")
        return records.sorted { $0.startTime > $1.startTime }
    }
    
    private static func parseSleepLine(_ line: String) -> SleepRecord? {
        // Format: 2025-10-29 12:20:56 +0800 Sleep  Entering Sleep state due to 'Software Sleep pid=157':TCPKeepAlive=active Using AC (Charge:0%) 19 secs
        
        let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard components.count >= 3 else { return nil }
        
        // Parse date and time
        let dateString = components[0] + " " + components[1] + " " + components[2]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            print("Failed to parse date: \(dateString)")
            return nil
        }
        
        // Find duration (last number + "secs")
        var duration: TimeInterval = 0
        if let secsIndex = components.lastIndex(of: "secs"),
           secsIndex > 0 {
            let durationString = components[secsIndex - 1]
            if let durationValue = Double(durationString) {
                duration = durationValue
            }
        }
        
        // Extract reason
        var reason = NSLocalizedString("reason.unknown", comment: "")
        if let dueToRange = line.range(of: "due to '") {
            let startIndex = dueToRange.upperBound
            if let endQuoteRange = line[startIndex...].range(of: "'") {
                reason = String(line[startIndex..<endQuoteRange.lowerBound])
            }
        }
        
        return SleepRecord(startTime: date, duration: duration, reason: reason)
    }
}
