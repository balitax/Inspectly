//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - HTTP Method Badge

struct HTTPMethodBadge: View {
    let method: HTTPMethodType

    var body: some View {
        Text(method.rawValue)
            .font(.system(size: 10, weight: .heavy, design: .monospaced))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.forMethod(method).opacity(0.15))
            .foregroundStyle(Color.forMethod(method))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        HTTPMethodBadge(method: .get)
        HTTPMethodBadge(method: .post)
        HTTPMethodBadge(method: .put)
        HTTPMethodBadge(method: .patch)
        HTTPMethodBadge(method: .delete)
    }
    .padding()
}
