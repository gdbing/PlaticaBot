//
//  EmbeddedPython.swift
//  PlaticaBot
//
//  Created by graham.bing on 2023-03-27.
//

import SwiftUI
import Python
import PythonKit

struct EmbeddedPython {
    static let shared = EmbeddedPython()
    private var tokenEncoder: PythonObject?
    
    init() {
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }
        guard let thirdPartyPath = Bundle.main.path(forResource: "python-third-party", ofType: nil) else { return }

        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath):\(thirdPartyPath)", 1)
        Py_Initialize()
        
        let tiktoken = Python.import("tiktoken")
        self.tokenEncoder = tiktoken.get_encoding("cl100k_base")
    }
    
    func tokenCountFor(input: String) -> Int {
        guard let tokenEncoder = self.tokenEncoder else { return 0 }
        
        let tokens = tokenEncoder.encode(input)
        return tokens.count
    }
}
