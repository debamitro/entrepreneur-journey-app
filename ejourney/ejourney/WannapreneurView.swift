//
//  WannapreneurView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct BusinessIdea: Identifiable, Codable {
    let id = UUID()
    var description: String
    var targetMarket: String
    var effort: String
    var reward: String
    var date = Date()
}

class IdeaStore: ObservableObject {
    @Published var ideas: [BusinessIdea] = []
    private let key = "savedIdeas"
    
    init() {
        loadIdeas()
    }
    
    func loadIdeas() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([BusinessIdea].self, from: data) {
            ideas = decoded
        }
    }
    
    func saveIdeas() {
        if let encoded = try? JSONEncoder().encode(ideas) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func addIdea(_ idea: BusinessIdea) {
        ideas.insert(idea, at: 0)
        saveIdeas()
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (BusinessIdea) -> Void
    
    @State private var businessDescription = ""
    @State private var effort = ""
    @State private var targetMarket = ""
    @State private var reward = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Business Idea")) {
                    TextField("Description", text: $businessDescription)
                    TextField("Who is it for", text: $targetMarket)
                    TextField("Effort", text: $effort)
                    TextField("Reward ($)", text: $reward)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Idea")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let newIdea = BusinessIdea(
                        description: businessDescription,
                        targetMarket: targetMarket,
                        effort: effort,
                        reward: reward
                    )
                    onSave(newIdea)
                    dismiss()
                }
                .disabled(businessDescription.isEmpty)
            )
        }
    }
}

struct IdeaCard: View {
    let idea: BusinessIdea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(idea.description)
                .font(.headline)
            
            Group {
                Text("Target Market: \(idea.targetMarket)")
                Text("Effort: \(idea.effort)")
                Text("Potential Reward: $\(idea.reward)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text(idea.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct WannapreneurView: View {
    @StateObject private var ideaStore = IdeaStore()
    @State private var showingForm = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Wannapreneur")
                .font(.largeTitle)
                .padding(.bottom, 10)
            
            Button(action: {
                showingForm = true
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Jot down an idea")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            if !ideaStore.ideas.isEmpty {
                Text("Your Ideas")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(ideaStore.ideas) { idea in
                            IdeaCard(idea: idea)
                        }
                    }
                }
            } else {
                Spacer()
                Text("No ideas yet. Tap the button to add one!")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showingForm) {
            EntryFormView { newIdea in
                ideaStore.addIdea(newIdea)
            }
        }
    }
}
