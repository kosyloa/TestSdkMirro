//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

class HelpTool: ToolsCommand {
    var isTools: Bool = true
    var cmd = "Help"

    var shortDescription = "Help tool."

    var fullDescription: String = ""

    func execute() {
    }
}
