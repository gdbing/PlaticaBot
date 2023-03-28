//
//  StatusBarView.swift
//  PlaticaBot
//
//  Created by graham.bing on 2023-03-27.
//

import SwiftUI
import PythonKit

struct StatusBarView: View {
    @Binding var temperature: Float
    @Binding var newModel: Bool
    @Binding var interactions: [Interaction]
    @Binding var prompt: String
    
    func tokensIn(interactions: Binding<[Interaction]>, prompt: Binding<String>) -> Int {
        let python = EmbeddedPython.shared
        var count: Int = 0
        for item in interactions.wrappedValue {
            count += python.tokenCountFor(input: item.plain)
            count += python.tokenCountFor(input: item.query)
        }
        count += python.tokenCountFor(input: prompt.wrappedValue)
        return count
    }

    var body: some View {
        HStack {
            Spacer()
            Text("\(newModel ? "GPT4" : "GPT3.5-turbo")")
            Text("|")
            Text("\(String(format:"%.1f", temperature))°")
            Text("|")
            Text("\(tokensIn(interactions:$interactions, prompt: $prompt)) tokens")
        }
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView(temperature: .constant(1.2), newModel: .constant(false), interactions: .constant([]), prompt: .constant("yolo"))
    }
}
