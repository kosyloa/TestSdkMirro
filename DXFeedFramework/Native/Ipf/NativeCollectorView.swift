//
//  NativeCollectorView.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.08.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeCollectorView {
    private let view: UnsafeMutablePointer<dxfg_iterable_ip_t>
    let mapper = InstrumentProfileMapper()

    deinit {
        let thread = currentThread()
        _ = try? ErrorCheck.nativeCall(thread,
                                       dxfg_JavaObjectHandler_release(thread,
                                                                      &(view.pointee.handler)))
    }

    init(view: UnsafeMutablePointer<dxfg_iterable_ip_t>) {
        self.view = view
    }

    func hasNext() throws -> Bool {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread, dxfg_Iterable_InstrumentProfile_hasNext(thread, view))
        return result != 0
    }

    func next() throws -> InstrumentProfile {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread, dxfg_Iterable_InstrumentProfile_next(thread, view))

        let profile = mapper.fromNative(native: result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfile_release(thread, result))
        return profile
    }
}
