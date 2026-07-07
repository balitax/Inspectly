//
//  RequestListToolbarItems.swift
//  Inspectly
//
//  Created by Agus Cahyono on 18/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//
//  Inspectly is a premium, developer-first HTTP interception and mocking
//  library for iOS. It captures, inspects, and mocks network requests with
//  zero configuration and zero dependencies.
//
//  Compatible with URLSession, Alamofire, AFNetworking, and any networking
//  library built on top of Foundation networking.
//
//  Repository:
//  https://github.com/balitax/Inspectly
//

import SwiftUI

// MARK: - Sort Menu

@available(iOS 16.0, *)
struct RequestSortMenu: View {
    @ObservedObject var viewModel: RequestListViewModel

    var body: some View {
        Menu {
            ForEach(RequestSortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                    viewModel.applyFiltersAndSort()
                } label: {
                    Label {
                        Text(option.rawValue)
                    } icon: {
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 14))
        }
    }
}

// MARK: - Clear Requests Button

@available(iOS 16.0, *)
struct ClearRequestsButton: View {
    @ObservedObject var viewModel: RequestListViewModel

    var body: some View {
        Button(role: .destructive) {
            viewModel.showClearConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14))
        }
    }
}

// MARK: - Filter Button

@available(iOS 16.0, *)
struct RequestFilterButton: View {
    @ObservedObject var viewModel: RequestListViewModel

    var body: some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 14))

                if viewModel.filter.isActive {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}
