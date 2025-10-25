//
//  BusinessIdeasView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI
import Clerk

class IdeaStore: ObservableObject {
    @Published var ideas: [BusinessIdea] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    private let key = "savedIdeas"
    
    init() {
        loadIdeas(isUserLoggedIn: false) // Don't fetch from API on init, will be called from onAppear with proper auth state
    }
    
    func loadIdeas(isUserLoggedIn: Bool = true) {
        // First load from local storage as a fallback
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([BusinessIdea].self, from: data) {
            ideas = decoded
        }
        
        // Then try to fetch from API only if user is logged in
        Task { await fetchIdeasFromAPI(isUserLoggedIn: isUserLoggedIn) }
    }
    
    @MainActor
    func fetchIdeasFromAPI(isUserLoggedIn: Bool = true) async {
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
    func addIdea(_ idea: BusinessIdea, isUserLoggedIn: Bool = true) {
        // Optimistically update the UI
        ideas.insert(idea, at: 0)
        saveIdeasLocally()
        
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
    
    @MainActor
    func updateIdea(_ updatedIdea: BusinessIdea, isUserLoggedIn: Bool = true) {
        // Find and update the idea in the local array
        if let index = ideas.firstIndex(where: { $0.id == updatedIdea.id }) {
            ideas[index] = updatedIdea
            saveIdeasLocally()
            
            Task {
                do {
                    let savedIdea = try await APIService.shared.saveIdea(updatedIdea)
                    print("Idea updated successfully on API with ID: \(savedIdea.id)")
                } catch let error as APIError {
                    errorMessage = "Failed to update idea: \(error.message)"
                    print("Error updating idea: \(error.message)")
                } catch {
                    errorMessage = "Failed to update idea: \(error.localizedDescription)"
                    print("Error updating idea: \(error.localizedDescription)")
                }
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

struct EditIdeaFormView: View {
    @Environment(\.dismiss) private var dismiss
    var idea: BusinessIdea
    var onSave: (BusinessIdea) -> Void
    
    @State private var businessDescription: String
    @State private var effort: String
    @State private var targetMarket: String
    @State private var reward: String
    
    init(idea: BusinessIdea, onSave: @escaping (BusinessIdea) -> Void) {
        self.idea = idea
        self.onSave = onSave
        _businessDescription = State(initialValue: idea.description)
        _effort = State(initialValue: idea.effort)
        _targetMarket = State(initialValue: idea.targetMarket)
        _reward = State(initialValue: idea.reward)
    }
    
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
            .navigationTitle("Edit Idea")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let updatedIdea = BusinessIdea(
                        description: businessDescription,
                        targetMarket: targetMarket,
                        effort: effort,
                        reward: reward,
                        date: idea.date
                    )
                    onSave(updatedIdea)
                    dismiss()
                }
                .disabled(businessDescription.isEmpty)
            )
        }
    }
}

struct IdeaCard: View {
    let idea: BusinessIdea
    let onTap: () -> Void
    
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
        .onTapGesture {
            onTap()
        }
    }
}

struct BusinessIdeasView: View {
    @StateObject private var ideaStore = IdeaStore()
    @State private var showingForm = false
    @State private var showingEditForm = false
    @State private var selectedIdea: BusinessIdea?
    @State private var isRefreshing = false
    @Environment(Clerk.self) private var clerk
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Ideas")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 10)
            Text("You need to keep noting down your ideas!")
                .font(.title3)
                .foregroundColor(.gray)
            if ideaStore.isLoading && ideaStore.ideas.isEmpty {
                Spacer()
                ProgressView("Loading ideas...")
                Spacer()
            } else if !ideaStore.ideas.isEmpty {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isRefreshing = true
                        Task {
                            await ideaStore.fetchIdeasFromAPI(isUserLoggedIn: clerk.user != nil)
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
                .padding(.top, 20)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(ideaStore.ideas) { idea in
                            IdeaCard(idea: idea) {
                                selectedIdea = idea
                                showingEditForm = true
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                
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
            
            HStack {
                Spacer()
                Button(action: {
                    showingForm = true
                }) {
                    Image(systemName: "plus.app.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .padding()
        .sheet(isPresented: $showingForm) {
            EntryFormView { newIdea in
                ideaStore.addIdea(newIdea, isUserLoggedIn: clerk.user != nil)
            }
        }
        .sheet(isPresented: $showingEditForm) {
            if let selectedIdea = selectedIdea {
                EditIdeaFormView(idea: selectedIdea) { updatedIdea in
                    ideaStore.updateIdea(updatedIdea, isUserLoggedIn: clerk.user != nil)
                }
            }
        }
        .onAppear {
            Task {
                await ideaStore.fetchIdeasFromAPI(isUserLoggedIn: clerk.user != nil)
            }
        }
    }
}
