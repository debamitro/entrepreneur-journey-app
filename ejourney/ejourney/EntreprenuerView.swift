//
//  EntreprenuerView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct EntrepreneurView: View {
    @State private var showingDiaryEntry = false
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Text("Entrepreneur")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 10)
                    Text("Diary")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading entries...")
                        .padding()
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else if diaryEntries.isEmpty {
                    Spacer()
                    Text("No diary entries yet. Create your first entry!")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(diaryEntries) { entry in
                                DiaryEntryCard(entry: entry)
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    showingDiaryEntry = true
                }) {
                    Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .onAppear {
                fetchDiaryEntries()
            }
            .sheet(isPresented: $showingDiaryEntry) {
                DiaryEntryView()
            }
            .onChange(of: showingDiaryEntry) { _, newValue in
                if !newValue {
                    fetchDiaryEntries()
                }
            }
        }
    }
    
    private func fetchDiaryEntries() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let entries = try await APIService.shared.fetchDiaryEntries()
                await MainActor.run {
                    self.diaryEntries = entries.sorted { $0.createdAt > $1.createdAt }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct DiaryEntryCard: View {
    let entry: DiaryEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: entry.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
