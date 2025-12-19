//
//  KeyboardToolbar.swift
//  Finora
//
//  Created by Aryan Varmora on 12/8/25.
//


//
//  KeyboardHelper.swift
//  Finora
//
//  Keyboard management utilities
//

import SwiftUI

// MARK: - Keyboard Dismissal Extension

extension View {
    /// Hides the keyboard when tapping outside text fields
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    /// Hides the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Keyboard Toolbar Modifier

struct KeyboardToolbar: ViewModifier {
    var doneAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        doneAction?()
                    }
                    .fontWeight(.semibold)
                }
            }
    }
}

extension View {
    /// Adds a "Done" button above the keyboard
    func keyboardToolbar(doneAction: (() -> Void)? = nil) -> some View {
        self.modifier(KeyboardToolbar(doneAction: doneAction))
    }
}

// MARK: - Keyboard Dismissal on Scroll

struct ScrollViewWithKeyboardDismissal<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            content
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
