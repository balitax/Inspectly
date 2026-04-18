//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Inspectly Swizzler
///
/// A utility class that uses method swizzling to automatically inject
/// InspectlyURLProtocol into all URLSessionConfiguration instances.
/// This enables "seamless" integration for Alamofire, AFNetworking,
/// and native URLSession without manual configuration.

final class InspectlySwizzler {
    
    static let shared = InspectlySwizzler()
    private var isSwizzled = false
    
    private init() {}
    
    /// Activate swizzling for URLSessionConfiguration.
    func activate() {
        guard !isSwizzled else { return }
        
        swizzleDefaultConfiguration()
        swizzleEphemeralConfiguration()
        
        isSwizzled = true
    }
    
    // MARK: - Private Methods
    
    private func swizzleDefaultConfiguration() {
        let originalSelector = #selector(getter: URLSessionConfiguration.default)
        let swizzledSelector = #selector(getter: URLSessionConfiguration.inspectly_default)
        
        swizzle(URLSessionConfiguration.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector, isClassMethod: true)
    }
    
    private func swizzleEphemeralConfiguration() {
        let originalSelector = #selector(getter: URLSessionConfiguration.ephemeral)
        let swizzledSelector = #selector(getter: URLSessionConfiguration.inspectly_ephemeral)
        
        swizzle(URLSessionConfiguration.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector, isClassMethod: true)
    }
    
    private func swizzle(_ cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector, isClassMethod: Bool) {
        let originalMethod: Method?
        let swizzledMethod: Method?
        
        if isClassMethod {
            originalMethod = class_getClassMethod(cls, originalSelector)
            swizzledMethod = class_getClassMethod(cls, swizzledSelector)
        } else {
            originalMethod = class_getInstanceMethod(cls, originalSelector)
            swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        }
        
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

// MARK: - URLSessionConfiguration Extension

extension URLSessionConfiguration {
    
    @objc class var inspectly_default: URLSessionConfiguration {
        let config = self.inspectly_default // Call original implementation (swizzled)
        config.injectInspectly()
        return config
    }
    
    @objc class var inspectly_ephemeral: URLSessionConfiguration {
        let config = self.inspectly_ephemeral // Call original implementation (swizzled)
        config.injectInspectly()
        return config
    }
    
    fileprivate func injectInspectly() {
        guard Inspectly.isEnabled else { return }
        
        var protocols = protocolClasses ?? []
        if !protocols.contains(where: { $0 == InspectlyURLProtocol.self }) {
            protocols.insert(InspectlyURLProtocol.self, at: 0)
            protocolClasses = protocols
        }
    }
}
