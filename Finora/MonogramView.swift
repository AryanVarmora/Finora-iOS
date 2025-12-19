//
//  MonogramView.swift
//  Finora - User initials monogram
//

import SwiftUI

struct MonogramView: View {
    let initials: String
    let size: CGFloat
    
    init(fullName: String, size: CGFloat = 40) {
        let parts = fullName.split(separator: " ")
        if parts.count >= 2 {
            self.initials = "\(parts[0].first ?? " ")\(parts[1].first ?? " ")".uppercased()
        } else if let first = parts.first {
            self.initials = String(first.prefix(2)).uppercased()
        } else {
            self.initials = "??"
        }
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "3B82F6"),
                        Color(hex: "2563EB")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        MonogramView(fullName: "John Doe", size: 40)
        MonogramView(fullName: "Jane Smith", size: 60)
        MonogramView(fullName: "Bob", size: 80)
    }
}
