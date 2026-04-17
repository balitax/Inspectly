//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Stub Manager View

struct StubManagerView: View {
    @StateObject var viewModel: StubManagerViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.stubs.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isEmpty {
                    EmptyStateView(
                        icon: "hammer.circle",
                        title: "No Stubs Created",
                        subtitle: "Create API stubs to mock responses and simulate errors during development.",
                        actionTitle: "Create Stub"
                    ) {
                        viewModel.showingNewStub = true
                    }
                } else {
                    stubList
                }
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Stubs")
            .searchable(text: $viewModel.searchText, prompt: "Search stubs...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingNewStub = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    filterMenu
                }
            }
            .sheet(isPresented: $viewModel.showingNewStub) {
                NavigationStack {
                    StubDetailView(
                        viewModel: StubDetailViewModel(
                            stub: viewModel.createNewStub(),
                            isEditing: true,
                            stubRepository: MockStubRepository()
                        ),
                        onSave: { stub in
                            Task {
                                await viewModel.saveStub(stub)
                            }
                        }
                    )
                }
            }
            .task {
                await viewModel.loadStubs()
            }
        }
    }

    // MARK: - Stub List

    private var stubList: some View {
        List {
            ForEach(viewModel.groupedStubs, id: \.group) { group in
                Section {
                    ForEach(group.stubs) { stub in
                        NavigationLink(value: stub.id) {
                            StubRowView(stub: stub)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteStub(stub) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                Task { await viewModel.duplicateStub(stub) }
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(.indigo)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task { await viewModel.toggleStub(stub) }
                            } label: {
                                Label(
                                    stub.isEnabled ? "Disable" : "Enable",
                                    systemImage: stub.isEnabled ? "pause.circle" : "play.circle"
                                )
                            }
                            .tint(stub.isEnabled ? .orange : .green)
                        }
                    }
                } header: {
                    Text(group.group)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: UUID.self) { stubId in
            if let stub = viewModel.stubs.first(where: { $0.id == stubId }) {
                StubDetailView(
                    viewModel: StubDetailViewModel(
                        stub: stub,
                        isEditing: false,
                        stubRepository: MockStubRepository()
                    ),
                    onSave: { updatedStub in
                        Task {
                            await viewModel.saveStub(updatedStub)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Filter Menu

    private var filterMenu: some View {
        Menu {
            Section("Status") {
                ForEach(StubFilterOption.allCases) { option in
                    Button {
                        viewModel.filterOption = option
                    } label: {
                        Label {
                            Text(option.rawValue)
                        } icon: {
                            if viewModel.filterOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section("Method") {
                Button {
                    viewModel.methodFilter = nil
                } label: {
                    Label {
                        Text("All Methods")
                    } icon: {
                        if viewModel.methodFilter == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach([HTTPMethodType.get, .post, .put, .patch, .delete]) { method in
                    Button {
                        viewModel.methodFilter = method
                    } label: {
                        Label {
                            Text(method.rawValue)
                        } icon: {
                            if viewModel.methodFilter == method {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 14))
        }
    }
}

// MARK: - Preview

#Preview {
    StubManagerView(viewModel: .mock())
}
