//
//  ConnectCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 27.09.23.
//

import Foundation
import DXFeedFramework

class ConnectCommand: ToolsCommand {
    var cmd = "Connect"
    var shortDescription = "Connects to specified address(es)."

    var fullDescription  =
"""
Connect
=======

  "address" argument parsing error. Insufficient parameters.

Usage:
  Connect <address> <types> <symbols> [<time>]

Where:
    address - The address to connect to retrieve data (remote host or local tape file).
              To pass an authorization token, add to the address: ""[login=entitle:<token>]"",
              e.g.: demo.dxfeed.com:7300[login=entitle:<token>]
    types   - Is comma-separated list of dxfeed event types ({eventTypeNames}).
    symbol  - Is comma-separated list of symbol names to get events for (e.g. ""IBM,AAPL,MSFT"").
              for Candle event specify symbol with aggregation like in ""AAPL{{=d}}""
    time    - Is from-time for history subscription in standard formats.
              Same examples of valid from-time:
                  20070101-123456
                  20070101-123456.123
                  2005-12-31 21:00:00
                  2005-12-31 21:00:00.123+03:00
                  2005-12-31 21:00:00.123+0400
                  2007-11-02Z
                  123456789 - value-in-milliseconds

"""

    var subscription = Subscription()

    func execute() {
        var arguments: [String]!
        do {
            arguments = try ArgumentParser().parse(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 4)
        } catch {
            print(fullDescription)
        }
        let address = arguments[1]
        let types = arguments[2]
        let symbols = arguments[3].components(separatedBy: ",")

        var time: String?
        if arguments.count > 4 {
            time = arguments[4]
        }

        let listener = ConnectEventListener()
        subscription.createSubscription(address: address,
                                        symbols: symbols,
                                        types: types,
                                        listener: listener,
                                        time: time)

        // Print till input new line
        _ = readLine()

    }
}
