//
//  StartView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct StartView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    StartView()
}
