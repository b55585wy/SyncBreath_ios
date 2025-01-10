//
//  ContentView.swift
//  SyncBreath_ios
//
//  Created by wangyi on 2025/1/9.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var showModeSelection = false
    @State private var showSoundControl = false
    
    var body: some View {
        ZStack {
            BreathingAnimationView(
                meditationType: viewModel.currentMode.type,
                phase: $viewModel.currentPhase,
                progress: $viewModel.progress
            )
            
            VStack {
                // Mode title and quote
                VStack(spacing: 8) {
                    Text(viewModel.currentMode.title)
                        .font(ThemeFonts.titleFont)
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentMode.description)
                        .font(ThemeFonts.quoteFont)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Controls
                VStack(spacing: 20) {
                    // Sound control
                    SoundControlView(viewModel: viewModel, meditationType: viewModel.currentMode.type)
                        .padding(.horizontal)
                    
                    // Start/Pause Button
                    Button(action: {
                        if viewModel.isBreathing {
                            viewModel.pauseBreathing()
                        } else {
                            viewModel.startBreathing()
                        }
                    }) {
                        Image(systemName: viewModel.isBreathing ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                    
                    // Mode Selection Button
                    Button(action: {
                        showModeSelection = true
                    }) {
                        Image(systemName: "list.bullet.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showModeSelection) {
            ModeSelectionView(viewModel: viewModel)
        }
        .onChange(of: viewModel.currentMode.type) { oldValue, newValue in
            // Fade out current sound when changing modes
            audioManager.fadeOut {}
        }
    }
}

struct ModeSelectionView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(MeditationType.allCases, id: \.self) { mode in
                Button(action: {
                    viewModel.switchMode(mode)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(mode.rawValue)
                            .font(.headline)
                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("选择模式")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
