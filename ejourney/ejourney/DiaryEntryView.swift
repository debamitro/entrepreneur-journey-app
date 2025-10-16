//
//  DiaryEntryView.swift
//  ejourney
//
//  Created by Cascade on 7/10/25.
//

import SwiftUI

struct DiaryEntryView: View {
    @State private var content = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var saveSuccess = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Content Section
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDiaryEntry()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                             isLoading)
                }
            }
            .alert("Diary Entry", isPresented: $showAlert) {
                Button("OK") {
                    if saveSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func saveDiaryEntry() {
        isLoading = true
        
        let entry = DiaryEntry(
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
        )
        
        Task {
            do {
                let savedEntry = try await APIService.shared.saveDiaryEntry(entry)
                
                await MainActor.run {
                    isLoading = false
                    saveSuccess = true
                    alertMessage = "Your entry has been saved successfully!"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    saveSuccess = false
                    alertMessage = "Failed to save entry: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    DiaryEntryView()
}
