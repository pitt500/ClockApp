//
//  TimersScreenUIKit.swift
//  ClockApp
//
//  Created by Pedro Rojas on 17/02/26.
//

import SwiftUI
import UIKit

struct TimersScreenUIKit: View {
    @State private var store = TimersStore()
    @Environment(\.editMode) private var editMode
    @State private var route: Route?

    var body: some View {
        NavigationStack {
            TimersTableView(model: makeModel())
                .navigationTitle("Timers")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                }
                .navigationDestination(item: $route) { route in
                    detailDestination(for: route)
                }
        }
    }

    // MARK: - Model

    private func makeModel() -> TimersTableModel {
        TimersTableModel(
            showDraftHeader: store.activeTimers.isEmpty,
            active: store.activeTimers,
            recents: store.recentTimers,
            isEditing: editMode?.wrappedValue.isEditing == true,
            header: {
                AnyView(
                    DraftHeaderView(draft: $store.draft) {
                        store.startFromDraft()
                    }
                )
            },
            onToggle: { store.toggle($0) },
            onDeleteActive: { store.deleteActiveTimers(at: $0) },
            onDeleteRecents: { store.deleteRecentTimers(at: $0) },
            onSelectActive: { route = .detail(source: .active, id: $0) },
            onSelectRecent: { route = .detail(source: .recent, id: $0) }
        )
    }

    // MARK: - Destination

    @ViewBuilder
    private func detailDestination(for route: Route) -> some View {
        switch route {
        case .detail(let source, let id):
            if let item = resolveItem(source: source, id: id) {
                TimerDetailView(
                    provider: TimerDetailProviderFromManager(
                        item: item,
                        onStartRequested: { preset in
                            store.activate(preset)
                        }
                    ),
                    onCancel: { store.cancel(item) }
                )
            } else {
                Text("Timer not found")
            }
        }
    }

    private func resolveItem(source: Route.Source, id: UUID) -> TimerItem? {
        switch source {
        case .active:
            return store.activeTimers.first(where: { $0.id == id })
        case .recent:
            return store.recentTimers.first(where: { $0.id == id })
        }
    }
}

// MARK: - Route

private enum Route: Identifiable, Hashable {
    enum Source: Hashable {
        case active
        case recent
    }

    case detail(source: Source, id: UUID)

    var id: String {
        switch self {
        case .detail(let source, let id):
            return "\(source)-\(id.uuidString)"
        }
    }
}

// MARK: - Draft Header (SwiftUI)

private struct DraftHeaderView: View {
    @Binding var draft: TimersStore.Draft
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            PickerHeaderView(draft: $draft, onStart: onStart)

            VStack(spacing: 0) {
                labelRow
                Divider().padding([.leading, .trailing], 16)
                whenTimerEndsRow
            }
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
    }

    private var labelRow: some View {
        HStack(spacing: 12) {
            Text("Label")
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            TextField("Timer", text: $draft.label)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var whenTimerEndsRow: some View {
        Button { } label: {
            HStack(spacing: 12) {
                Text("When Timer Ends")
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text("Radar")
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Table Model

private struct TimersTableModel {
    var showDraftHeader: Bool
    var active: [TimerItem]
    var recents: [TimerItem]
    var isEditing: Bool

    var header: () -> AnyView

    var onToggle: (TimerItem) -> Void
    var onDeleteActive: (IndexSet) -> Void
    var onDeleteRecents: (IndexSet) -> Void

    var onSelectActive: (UUID) -> Void
    var onSelectRecent: (UUID) -> Void
}

// MARK: - UITableView wrapper

private struct TimersTableView: UIViewRepresentable {
    let model: TimersTableModel

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: Coordinator.cellID)

        table.dataSource = context.coordinator
        table.delegate = context.coordinator

        table.backgroundColor = .systemBackground
        table.insetsContentViewsToSafeArea = false
        table.cellLayoutMarginsFollowReadableWidth = false
        table.sectionHeaderTopPadding = 0
        table.separatorColor = UIColor.separator.withAlphaComponent(0.35)
        table.layoutMargins = .zero
        table.separatorInset = .zero

        context.coordinator.attach(tableView: table)
        return table
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.update(model: model, in: uiView)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static let cellID = "Cell"
        
        private let horizontalInset: CGFloat = 20
        private let headerBottomPadding: CGFloat = 6
        private let trashIcon = UIImage(systemName: "trash.fill")

        private weak var tableView: UITableView?
        private var model: TimersTableModel?

        private var hostingHeaderController: UIHostingController<AnyView>?

        enum Section: Int, CaseIterable {
            case active
            case recents
        }

        func attach(tableView: UITableView) {
            self.tableView = tableView
        }

        func update(model: TimersTableModel, in tableView: UITableView) {
            self.model = model

            tableView.setEditing(model.isEditing, animated: true)
            tableView.reloadData()
            updateDraftHeader(in: tableView)
        }

        // MARK: Data Source

        func numberOfSections(in tableView: UITableView) -> Int {
            Section.allCases.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let model, let s = Section(rawValue: section) else { return 0 }
            return items(for: s, model: model).count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath)
            configure(cell: cell, at: indexPath)
            return cell
        }

        private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = .zero
            cell.separatorInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)

            guard
                let model,
                let section = Section(rawValue: indexPath.section),
                let item = item(at: indexPath, section: section, model: model)
            else {
                cell.contentConfiguration = nil
                return
            }

            cell.contentConfiguration = UIHostingConfiguration {
                TimerRowView(
                    item: item,
                    onPrimaryAction: { [weak self] in
                        guard let self else { return }
                        self.model?.onToggle(item)
                    }
                )
                .padding(.horizontal, self.horizontalInset)
            }
            .margins(.all, 0)
        }

        // MARK: Delegate

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            guard
                let model,
                let section = Section(rawValue: indexPath.section),
                let item = item(at: indexPath, section: section, model: model)
            else { return }

            switch section {
            case .active:
                model.onSelectActive(item.id)
            case .recents:
                model.onSelectRecent(item.id)
            }
        }

        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            guard let model, let section = Section(rawValue: indexPath.section) else { return false }
            return item(at: indexPath, section: section, model: model) != nil
        }

        // MARK: Swipe-to-delete (Trash icon)

        func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

            guard
                let model,
                let section = Section(rawValue: indexPath.section),
                item(at: indexPath, section: section, model: model) != nil
            else { return nil }

            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
                guard let self, let model = self.model else {
                    completion(false)
                    return
                }

                switch section {
                case .active:
                    model.onDeleteActive(IndexSet(integer: indexPath.row))
                case .recents:
                    model.onDeleteRecents(IndexSet(integer: indexPath.row))
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self, let tableView = self.tableView else { return }
                    tableView.reloadData()
                    self.updateDraftHeader(in: tableView)
                }

                completion(true)
            }

            deleteAction.image = trashIcon
            deleteAction.backgroundColor = .systemRed

            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = true
            return config
        }

        // MARK: - Custom Section Header ("Recents")

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let model, let s = Section(rawValue: section) else { return nil }
            guard s == .recents, !model.recents.isEmpty else { return nil }

            let label = UILabel()
            label.text = "Recents"
            label.textColor = .secondaryLabel
            label.font = UIFont.preferredFont(forTextStyle: .headline)

            let container = UIView()
            container.backgroundColor = .clear
            container.addSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalInset),
                label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -horizontalInset),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -headerBottomPadding)
            ])

            return container
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            guard let model, let s = Section(rawValue: section) else { return .leastNonzeroMagnitude }
            guard s == .recents, !model.recents.isEmpty else { return .leastNonzeroMagnitude }
            return 44
        }

        // MARK: Draft Header (tableHeaderView)

        private func updateDraftHeader(in tableView: UITableView) {
            guard let model else { return }

            guard model.showDraftHeader else {
                tableView.tableHeaderView = nil
                return
            }

            let root = model.header()

            if let hostingHeaderController {
                hostingHeaderController.rootView = root
            } else {
                let hc = UIHostingController(rootView: root)
                hc.view.backgroundColor = .clear
                hostingHeaderController = hc
            }

            guard let hostedView = hostingHeaderController?.view else { return }

            let container = UIView()
            container.backgroundColor = .clear
            container.addSubview(hostedView)

            hostedView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostedView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                hostedView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                hostedView.topAnchor.constraint(equalTo: container.topAnchor),
                hostedView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                container.widthAnchor.constraint(equalToConstant: tableView.bounds.width)
            ])

            container.setNeedsLayout()
            container.layoutIfNeeded()

            let target = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
            let size = container.systemLayoutSizeFitting(
                target,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

            container.frame = CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: size.height))
            tableView.tableHeaderView = container
        }

        // MARK: Items

        private func items(for section: Section, model: TimersTableModel) -> [TimerItem] {
            switch section {
            case .active: return model.active
            case .recents: return model.recents
            }
        }

        private func item(at indexPath: IndexPath, section: Section, model: TimersTableModel) -> TimerItem? {
            let list = items(for: section, model: model)
            guard list.indices.contains(indexPath.row) else { return nil }
            return list[indexPath.row]
        }
    }
}

#Preview {
    TimersScreenUIKit()
        .preferredColorScheme(.dark)
}

