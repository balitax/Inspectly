//
//  HTTPMethodBadge.swift
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

// MARK: - HTTP Method Badge

@available(iOS 16.0, *)
struct HTTPMethodBadge: View {
    let method: HTTPMethodType

    var body: some View {
        Text(method.rawValue)
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.forMethod(method).opacity(0.15))
            .foregroundColor(Color.forMethod(method))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct HTTPMethodBadge_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 8) {
            HTTPMethodBadge(method: .get)
            HTTPMethodBadge(method: .post)
            HTTPMethodBadge(method: .put)
            HTTPMethodBadge(method: .patch)
            HTTPMethodBadge(method: .delete)
        }
        .padding()
    }
}
