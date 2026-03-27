//
//  TimerAlertSoundPickerView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 27/03/26.
//

import SwiftUI

enum TimerAlertSound: String, CaseIterable, Identifiable {
    case `default`
    case alarmPitt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default:
            return "Default"
        case .alarmPitt:
            return "Alarm Pitt"
        }
    }

    var fileName: String? {
        switch self {
        case .default:
            return nil
        case .alarmPitt:
            return "alarm_pitt.caf"
        }
    }
}

struct TimerAlertSoundPickerView: View {
    @Binding var selectedSound: TimerAlertSound
    @Environment(\.dismiss) private var dismiss

    private let sounds = TimerAlertSound.allCases

    var body: some View {
        NavigationStack {
            List {
                ForEach(sounds) { sound in
                    Button {
                        selectedSound = sound
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(isSelected(sound) ? .orange : .clear)

                            Text(sound.title)
                                .foregroundStyle(.primary)
                            
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("When Timer Ends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func isSelected(_ sound: TimerAlertSound) -> Bool {
        selectedSound == sound
    }
}
