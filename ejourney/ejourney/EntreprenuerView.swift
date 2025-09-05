//
//  EntreprenuerView.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 6/11/25.
//

import SwiftUI

struct EntrepreneurView: View {
    var body: some View {
        VStack {
            Text("Entrepreneur")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 10)
            Text("Here's your diary")
                .font(.title3)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}
