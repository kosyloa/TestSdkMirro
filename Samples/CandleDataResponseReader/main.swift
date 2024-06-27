//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework
import SwiftCSV


let login = "demo"
let password = "demo"

let config = URLSessionConfiguration.default
let userPasswordString = "\(login):\(password)"
let userPasswordData = userPasswordString.data(using: .utf8)
let base64EncodedCredential = userPasswordData!.base64EncodedString()

config.httpAdditionalHeaders = ["Authorization": "Basic \(base64EncodedCredential)"]
let delegate = AuthDel()
let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

//let candlesUrl = "https://tools.dxfeed.com/candledata?records=Candle&symbols=AIV{=d}&start=20201201-000000&stop=20210101-000000"
let tnsUrl = URL(string: "https://tools-demo.dxfeed.com/candledata-preview?records=TimeAndSale&symbols=IBM&start=20240624-093000&stop=20240624-093500&format=csv&compression=gzip")!


let task = session.downloadTask(with: tnsUrl, completionHandler: { localURL, urlResponse, error in
    if let localURL = localURL {
        Data()
        if let string = try? String(contentsOf: localURL) {
            if let tnsList = try? parseTimeAndSale(string) {
                tnsList.forEach { element in
                    print(element.toString())
                }
            } else {
                print("Something happened with parsing: \(string)")
            }
        }
    }
})

task.resume()

_ = readLine()


class AuthDel: NSObject {

}
extension AuthDel: URLSessionDelegate {
    dow
}

fileprivate func parseCandles(_ string: String) throws -> [Candle] {
    var candles = [Candle]()
    let tsv: CSV = try CSV<Enumerated>(string: string)
    let header = tsv.header
    try tsv.rows.forEach { values in
        var event: Candle?

        for index in 0..<values.count {
            let value = values[index]

            if index == header.count {
                event?.eventFlags = parseEventflags(value)
            } else {
                let headerKey = header[index]
                switch headerKey {
                case "#=Candle": break
                case "EventSymbol":
                    event = Candle(try CandleSymbol.valueOf(value))
                case "EventTime":
                    let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                    event?.eventTime = time ?? 0
                case "Time":
                    let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                    event?.time = time ?? 0
                case "Sequence":
                    let millisAndSequence = value.split(separator: ":")
                    if millisAndSequence.count == 2 {
                        let sequence = millisAndSequence[1]
                        try? event?.setSequence(Int(sequence) ?? 0)
                    }
                    event?.time = (event?.time ?? 0) + (Int64(String(millisAndSequence.first!)) ?? 0)
                case "Count":
                    event?.count = Long(value) ?? 0
                case "Open":
                    event?.open = Double(value) ?? .nan
                case "High":
                    event?.high = Double(value) ?? .nan
                case "Low":
                    event?.low = Double(value) ?? .nan
                case "Close":
                    event?.close = Double(value) ?? .nan
                case "Volume":
                    event?.volume = Double(value) ?? .nan
                case "VWAP":
                    event?.vwap = Double(value) ?? .nan
                case "BidVolume":
                    event?.bidVolume = Double(value) ?? .nan
                case "AskVolume":
                    event?.askVolume = Double(value) ?? .nan
                case "ImpVolatility":
                    event?.impVolatility = Double(value) ?? .nan
                case "OpenInterest":
                    event?.openInterest = Double(value) ?? .nan
                default:
                    print("Undefined key \(headerKey)")
                }
            }
        }
        if let candle = event {
            candles.append(candle)
        }
    }
    return candles
}

fileprivate func parseTimeAndSale(_ string: String) throws -> [TimeAndSale] {
    var candles = [TimeAndSale]()
    let tsv: CSV = try CSV<Enumerated>(string: string)
    let header = tsv.header
    try tsv.rows.forEach { values in
        var event: TimeAndSale?

        for index in 0..<values.count {
            let value = values[index]

            if index == header.count {
                event?.eventFlags = parseEventflags(value)
            } else {
                let headerKey = header[index]
                switch headerKey {
                case "#=TimeAndSale": break
                case "EventSymbol":
                    event = TimeAndSale(value)
                case "EventTime":
                    let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                    event?.eventTime = time ?? 0
                case "Time":
                    let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                    event?.time = time ?? 0
                case "Sequence":
                    let millisAndSequence = value.split(separator: ":")
                    if millisAndSequence.count == 2 {
                        let sequence = millisAndSequence[1]
                        try? event?.setSequence(Int(sequence) ?? 0)
                    }
                    event?.time = (event?.time ?? 0) + (Int64(String(millisAndSequence.first!)) ?? 0)
                case "ExchangeCode":
                    event?.exchangeCode = StringUtil.decodeString(value)
                case "Price":
                    event?.price = Double(value) ?? 0
                case "Size":
                    event?.size = Double(value) ?? 0
                case "BidPrice":
                    event?.bidPrice = Double(value) ?? 0
                case "AskPrice":
                    event?.askPrice = Double(value) ?? 0
                case "SaleConditions":
                    event?.exchangeSaleConditions = value
                case "Flags":
                    event?.flags = Int32(value) ?? 0
                case "Buyer":
                    event?.buyer = value
                case "Seller":
                    event?.seller = value
                default:
                    print("Undefined key \(headerKey)")
                }
            }
        }
        if let candle = event {
            candles.append(candle)
        }
    }
    return candles
}

fileprivate func parseFlags(_ string: String) -> Int32 {
    var result: Int32 = 0
    string.split(separator: ",").forEach { value in
        switch String(value) {
        case "TX_PENDING":
            result = result | Candle.txPending
        case "REMOVE_EVENT":
            result = result | Candle.removeEvent
        case "SNAPSHOT_BEGIN":
            result = result | Candle.snapshotBegin
        case "SNAPSHOT_END":
            result = result | Candle.snapshotEnd
        case "SNAPSHOT_SINP":
            result = result | Candle.snapshotSnip
        default:
            print("Undefined event flag \(value)")
        }
    }
    return result
}

fileprivate func parseEventflags(_ value: String) -> Int32 {
    // it is events flags
    if !value.isEmpty {
        let prefix = "EventFlags="
        if value.hasPrefix(prefix) {
            return parseFlags(String(value.dropFirst(prefix.count)))
        }
    }
    return 0
}
