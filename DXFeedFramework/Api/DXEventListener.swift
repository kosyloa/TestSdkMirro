//
//  DXEventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 31.05.23.
//

import Foundation

public protocol DXEventListener: AnyObject {
    func receiveEvents(_ events: [MarketEvent])
}
