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

    private enum Layout {
        static let pickerHeight: CGFloat = 180
        static let selectionBarHeight: CGFloat = 34
        static let selectionBarWidth: CGFloat = 310
        static let selectionBarCornerRadius: CGFloat = 14
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                PickerSelectionBar()
                    .frame(width: Layout.selectionBarWidth)
                
                HStack(spacing: 12) {
                    UnitWheelPicker(unit: "hours", range: 0...23, selection: $draft.hours)
                    UnitWheelPicker(unit: "min", range: 0...59, selection: $draft.minutes)
                    UnitWheelPicker(unit: "sec", range: 0...59, selection: $draft.seconds)
                }
                .frame(height: Layout.pickerHeight)
            }

            HStack {
                Button("Cancel") { draft = .init() }
                    .buttonStyle(.bordered)
                    .tint(.gray)

                Spacer()

                Button("Start") { onStart() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!draft.isValid)
            }
        }
        .padding(.horizontal, 16)
    }

    private struct UnitWheelPicker: View {
        let unit: String
        let range: ClosedRange<Int>
        @Binding var selection: Int

        var body: some View {
            HStack(spacing: 0) {
                Picker(unit, selection: $selection) {
                    ForEach(range, id: \.self) { value in
                        Text("\(value)").tag(value)
                            
                    }
                    
                }
                .pickerStyle(.wheel)
                
                Text(unit)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                    .frame(width: 50, alignment: .leading)
            }
            .frame(width: 100, height: 100)
        }
    }

    private struct PickerSelectionBar: View {
        var body: some View {
            RoundedRectangle(cornerRadius: Layout.selectionBarCornerRadius, style: .continuous)
                .fill(.gray.opacity(0.3))
                .frame(height: Layout.selectionBarHeight)
                .allowsHitTesting(false)
        }
    }
}

#Preview("Clock-style Picker Header") {
    @Previewable @State var draft = TimersStore.Draft(hours: 0, minutes: 1, seconds: 20)

    return NavigationStack {
        List {
            Section {
                PickerHeaderView(draft: $draft) {}
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
            }

            Section("Recents") {
                Text("1:15")
                Text("1:20")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Timers")
    }
}
