//
//  AboutView.swift
//  ejourney
//
//  Created by Claude on 10/25/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .padding(.top, 40)
                    
                    VStack(spacing: 10) {
                        Text("EJourney")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your Entrepreneurial Journey Companion")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 20) {
                        Text("About EJourney")
                            .font(.headline)
                            .padding(.top, 20)
                        
                        Text("EJourney is designed to help aspiring entrepreneurs and established business owners track their ideas, document their journey, and grow their ventures. Whether you're a wannapreneur with big dreams or an entrepreneur making things happen, this app is your digital companion.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Made with ❤️ for entrepreneurs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link("Copyright 2025 East Coast Software LLC", destination: URL(string: "https://www.eastcoastsoft.com")!)
                            .font(.caption)
                            .padding(.top, 10)
                    }
                    .padding(.top, 30)
                }
                .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
