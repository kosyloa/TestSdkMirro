//
//  EventMapper.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 05.06.23.
//

import Foundation
@_implementationOnly import graal_api

/// A collection of classes for mapping unmanaged native events dxfg_event_type_t
class EventMapper: Mapper {
    var count: Int = 0
    typealias TypeAlias = dxfg_event_type_t
    var type: dxfg_event_type_t.Type

    init() {
        self.type = dxfg_event_type_t.self
    }

    private let mappers: [EventCode: any Mapper] = [.quote: QuoteMapper(),
                                                    .timeAndSale: TimeAndSaleMapper(),
                                                    .profile: ProfileMapper(),
                                                    .trade: TradeMapper(),
                                                    .tradeETH: TradeETHMapper(),
                                                    .candle: CandleMapper(),
                                                    .summary: SummaryMapper(),
                                                    .greeks: GreeksMapper(),
                                                    .underlying: UnderlyingMapper(),
                                                    .theoPrice: TheoPriceMapper(),
                                                    .order: OrderMapper(),
                                                    .analyticOrder: AnalyticOrderMapper(),
                                                    .spreadOrder: SpreadOrderMapper(),
                                                    .series: SeriesMapper(),
                                                    .optionSale: OptionSaleMapper()]

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent? {
        let code = try EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz))
        if let mapper = mappers[code] {
            return try mapper.fromNative(native: native)
        } else {
            count += 1
            print("Not found mapper \(native.pointee.clazz) \(count)")
        }
        return nil
    }

    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let code = event.type
        if let mapper = mappers[code] {
            let native = try mapper.toNative(event: event)
            return native
        }
        return nil
    }

    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>) {
        if let code = try? EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz)) {
            if let mapper = mappers[code] {
                mapper.releaseNative(native: native)
            }
        }
    }
}
