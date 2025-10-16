//
//  EntreprenuerView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct EntrepreneurView: View {
    @State private var showingDiaryEntry = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Entrepreneur")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 10)
            Text("Diary")
                .font(.title3)
                .foregroundColor(.gray)
            
            Button(action: {
                showingDiaryEntry = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Entry")
                }
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingDiaryEntry) {
            DiaryEntryView()
        }
    }
}
