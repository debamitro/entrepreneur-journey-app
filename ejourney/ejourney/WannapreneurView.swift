//
//  WannapreneurView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct BusinessIdea: Identifiable, Codable {
    var id: UUID
    var description: String
    var targetMarket: String
    var effort: String
    var reward: String
    var date: Date
    
    init(id: UUID = UUID(), description: String, targetMarket: String, effort: String, reward: String, date: Date = Date()) {
        self.id = id
        self.description = description
        self.targetMarket = targetMarket
        self.effort = effort
        self.reward = reward
        self.date = date
    }
    
    enum CodingKeys: String, CodingKey {
        case id, description, targetMarket, effort, reward, date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode the id as a UUID string
        if let idString = try? container.decode(String.self, forKey: .id) {
            if let uuid = UUID(uuidString: idString) {
                self.id = uuid
            } else {
                self.id = UUID() // Fallback if the string isn't a valid UUID
            }
        } else {
            // If id is not present or not a string, generate a new UUID
            self.id = UUID()
        }
        
        self.description = try container.decode(String.self, forKey: .description)
        self.targetMarket = try container.decode(String.self, forKey: .targetMarket)
        self.effort = try container.decode(String.self, forKey: .effort)
        self.reward = try container.decode(String.self, forKey: .reward)
        
        // Try to decode date as ISO8601 string, or use current date as fallback
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            self.date = formatter.date(from: dateString) ?? Date()
        } else if let timestamp = try? container.decode(Date.self, forKey: .date) {
            self.date = timestamp
        } else {
            self.date = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(targetMarket, forKey: .targetMarket)
        try container.encode(effort, forKey: .effort)
        try container.encode(reward, forKey: .reward)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: date), forKey: .date)
    }
}

class IdeaStore: ObservableObject {
    @Published var ideas: [BusinessIdea] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    private let key = "savedIdeas"
    
    init() {
        loadIdeas()
    }
    
    func loadIdeas() {
        // First load from local storage as a fallback
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([BusinessIdea].self, from: data) {
            ideas = decoded
        }
        
        // Then try to fetch from API
        Task { await fetchIdeasFromAPI() }
    }
    
    @MainActor
    func fetchIdeasFromAPI() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedIdeas = try await APIService.shared.fetchIdeas()
            ideas = fetchedIdeas
            saveIdeasLocally() // Cache the fetched ideas locally
            isLoading = false
        } catch let error as APIError {
            errorMessage = error.message
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch ideas: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func saveIdeasLocally() {
        if let encoded = try? JSONEncoder().encode(ideas) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    @MainActor
    func addIdea(_ idea: BusinessIdea) {
        // Optimistically update the UI
        ideas.insert(idea, at: 0)
        saveIdeasLocally()
        
        // Save to API
        Task {
            do {
                let savedIdea = try await APIService.shared.saveIdea(idea)
                print("Idea saved successfully to API with ID: \(savedIdea.id)")
            } catch let error as APIError {
                errorMessage = "Failed to save idea: \(error.message)"
                print("Error saving idea: \(error.message)")
            } catch {
                errorMessage = "Failed to save idea: \(error.localizedDescription)"
                print("Error saving idea: \(error.localizedDescription)")
            }
        }
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
    @State private var isRefreshing = false
    
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
            
            if ideaStore.isLoading && ideaStore.ideas.isEmpty {
                Spacer()
                ProgressView("Loading ideas...")
                Spacer()
            } else if !ideaStore.ideas.isEmpty {
                HStack {
                    Text("Your Ideas")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        isRefreshing = true
                        Task {
                            await ideaStore.fetchIdeasFromAPI()
                            isRefreshing = false
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                    .disabled(ideaStore.isLoading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(ideaStore.ideas) { idea in
                            IdeaCard(idea: idea)
                        }
                    }
                }
                
                if ideaStore.isLoading {
                    ProgressView()
                        .padding()
                }
            } else {
                Spacer()
                Text("No ideas yet. Tap the button to add one!")
                    .foregroundColor(.gray)
                Spacer()
            }
            
            if let errorMessage = ideaStore.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding()
        .sheet(isPresented: $showingForm) {
            EntryFormView { newIdea in
                ideaStore.addIdea(newIdea)
            }
        }
        .onAppear {
            Task {
                await ideaStore.fetchIdeasFromAPI()
            }
        }
    }
}
