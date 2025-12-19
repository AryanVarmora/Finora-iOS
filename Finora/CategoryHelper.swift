//
//  CategoryHelper.swift
//  Finora
//
//  Created by Aryan Varmora on 12/19/25.
//


//
//  CategoryHelper.swift
//  Finora - Category display utilities
//

import SwiftUI

struct CategoryHelper {
    
    // MARK: - Category List
    static let allCategories = [
        "Food",
        "Transportation", 
        "Shopping",
        "Bills",
        "Entertainment",
        "Health",
        "Other"
    ]
    
    // MARK: - Get Emoji Only
    static func emoji(for category: String) -> String {
        switch category {
        case "Food": return "🍴"
        case "Transportation": return "🚗"
        case "Shopping": return "🛍️"
        case "Bills": return "💡"
        case "Entertainment": return "🎬"
        case "Health": return "🏥"
        case "Other": return "📌"
        default: return "📌"
        }
    }
    
    // MARK: - Get SF Symbol Icon
    static func icon(for category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Shopping": return "bag"
        case "Bills": return "doc.text"
        case "Entertainment": return "tv"
        case "Health": return "cross.case"
        case "Other": return "folder"
        default: return "folder"
        }
    }
    
    // MARK: - Get Color
    static func color(for category: String) -> Color {
        switch category {
        case "Food": return Color(hex: "EF4444")
        case "Transportation": return Color(hex: "F59E0B")
        case "Shopping": return Color(hex: "3B82F6")
        case "Bills": return Color(hex: "10B981")
        case "Entertainment": return Color(hex: "8B5CF6")
        case "Health": return Color(hex: "EC4899")
        case "Other": return Color(hex: "6B7280")
        default: return Color(hex: "6B7280")
        }
    }
    
    // MARK: - Get Display Name with Emoji
    static func displayName(for category: String) -> String {
        return "\(emoji(for: category)) \(category)"
    }
    
    // MARK: - Category Row View (Reusable Component)
    struct CategoryRow: View {
        let category: String
        let showText: Bool
        
        init(category: String, showText: Bool = true) {
            self.category = category
            self.showText = showText
        }
        
        var body: some View {
            HStack(spacing: 8) {
                Text(CategoryHelper.emoji(for: category))
                    .font(.title3)
                
                if showText {
                    Text(category)
                        .font(.body)
                }
            }
        }
    }
    
    // MARK: - Category Icon View (with background)
    struct CategoryIcon: View {
        let category: String
        let size: CGFloat
        
        init(category: String, size: CGFloat = 44) {
            self.category = category
            self.size = size
        }
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(CategoryHelper.color(for: category).opacity(0.1))
                    .frame(width: size, height: size)
                
                Text(CategoryHelper.emoji(for: category))
                    .font(.system(size: size * 0.45))
            }
        }
    }
    
    // MARK: - Category Badge View (with color background)
    struct CategoryBadge: View {
        let category: String
        
        var body: some View {
            HStack(spacing: 6) {
                Text(CategoryHelper.emoji(for: category))
                    .font(.caption)
                
                Text(category)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(CategoryHelper.color(for: category).opacity(0.1))
            .foregroundColor(CategoryHelper.color(for: category))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Row format
        ForEach(CategoryHelper.allCategories, id: \.self) { category in
            CategoryHelper.CategoryRow(category: category)
        }
        
        Divider()
        
        // Icon format
        HStack(spacing: 15) {
            ForEach(CategoryHelper.allCategories.prefix(4), id: \.self) { category in
                CategoryHelper.CategoryIcon(category: category)
            }
        }
        
        Divider()
        
        // Badge format
        VStack(spacing: 10) {
            ForEach(CategoryHelper.allCategories.prefix(3), id: \.self) { category in
                CategoryHelper.CategoryBadge(category: category)
            }
        }
    }
    .padding()
}
