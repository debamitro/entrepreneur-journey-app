//
//  ContentView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text("Have you already started your entrepreneural journey?")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                NavigationLink(destination: WannapreneurView()) {
                    Text("Not yet")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.brown)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: EntrepreneurView()) {
                    Text("Yes I have")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
