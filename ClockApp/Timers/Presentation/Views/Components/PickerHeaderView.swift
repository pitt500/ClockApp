//
//  PickerHeaderView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct PickerHeaderView: View {
    @Binding var draft: TimersStore.Draft
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                timePicker("hours", range: 0...23, selection: $draft.hours)
                timePicker("min", range: 0...59, selection: $draft.minutes)
                timePicker("sec", range: 0...59, selection: $draft.seconds)
            }
            .frame(height: 180)

            HStack {
                Button("Cancel") {
                    draft = .init()
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Spacer()

                Button("Start") {
                    onStart()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!draft.isValid)
            }
        }
        .padding(.horizontal, 16)
    }

    private func timePicker(
        _ title: String,
        range: ClosedRange<Int>,
        selection: Binding<Int>
    ) -> some View {
        VStack(spacing: 4) {
            Picker(title, selection: selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
