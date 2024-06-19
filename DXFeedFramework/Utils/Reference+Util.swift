//
//  Reference+Util.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 24.08.23.
//

import Foundation

func stringReference(_ obj: AnyObject) -> String {
    return "\(Unmanaged.passUnretained(obj).toOpaque())"
}
