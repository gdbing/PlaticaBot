//
//  PersonaSettings.swift
//  PlaticaBot
//
//  Created by graham.bing on 2023-03-31.
//

import SwiftUI

// MARK: Persona Model

struct Persona: Hashable, Codable, Identifiable {
    var id: UUID
    var name: String
    var direction: String
    
    init(id: UUID = UUID(), name: String, direction: String) {
        self.id = id
        self.name = name
        self.direction = direction
    }
    
    struct Data {
        var name = ""
        var direction = ""
    }
    
    var data: Data {
        Data(name: name, direction: direction)
    }
    
    mutating func update(from data: Data) {
        name = data.name
        direction = data.direction
    }
    
    init(data: Data) {
        self.id = UUID()
        self.name = data.name
        self.direction = data.direction
    }
}

// MARK: -
// MARK: Personae storage

private let personaeKey = "Personae"
private let defaultPersona = Persona(name: "Default", direction: "You are a helpful assistant")
private func getPersonae () -> [Persona] {
    let personae = NSUbiquitousKeyValueStore.default.array(forKey: personaeKey) ?? [defaultPersona]
    return personae.compactMap { $0 as? Persona }
}

private func setPersonae (_ value: [Persona]) {
    NSUbiquitousKeyValueStore.default.set(value, forKey: personaeKey)
    NSUbiquitousKeyValueStore.default.synchronize()
}


// MARK: -
// MARK: Personae iOS View

struct PersonaSettings: View {
    @State var personae : [Persona] = getPersonae()
    @State var isPresentingNewPersonaView: Bool = false
    @State private var personaData = Persona.Data()

    var body: some View {
        List {
            ForEach($personae) { $persona in
                NavigationLink(destination: PersonaEditView(personaData: $personaData)
                    .onAppear() {
                        personaData = persona.data
                    }
                    .onDisappear() {
                    persona.update(from: personaData)
                    setPersonae(personae)
                    personaData = Persona.Data()
                }) {
                    PersonaListItem(persona: persona)
                }
            }
            .onDelete { indices in
                personae.remove(atOffsets: indices)
            }
        }
        .navigationTitle("Personae")
        .toolbar {
            Button(action: {
                isPresentingNewPersonaView = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isPresentingNewPersonaView) {
            NavigationView {
                PersonaEditView(personaData: $personaData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewPersonaView = false
                                personaData = Persona.Data()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let newPersona = Persona.init(data: personaData)
                                personae.append(newPersona)
                                setPersonae(personae)
                                isPresentingNewPersonaView = false
                                personaData = Persona.Data()
                            }
                            .disabled(personaData.name == "")
                        }
                    }
            }
        }
    }
}

struct PersonaListItem: View {
    let persona: Persona
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
            VStack(alignment: .leading) {
                Text(persona.name)
                    .font(.headline)
                Text(persona.direction)
                    .font(.caption)
                    .lineLimit(1)
            }
            
        }
    }
}

struct PersonaEditView: View {
    @Binding var personaData: Persona.Data
            
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $personaData.name)
                TextField("Direction", text: $personaData.direction, axis: .vertical)
            }
        }
    }
}

// MARK: -
// MARK: Personae MacOS View

struct PersonaListToolbar: View {
    @Binding var personae: [Persona]
    
    var body: some View {
        HStack(spacing: 0) {
            PersonaListToolbarButton(image: Image(systemName: "plus"))
            Divider()
            PersonaListToolbarButton(image: Image(systemName: "minus"))
            Divider()
            Spacer()
        }
        .frame(height:20)
    }
    
    struct PersonaListToolbarButton: View {
        var image: Image
        
        var body: some View {
            Button(action: {}) {
                image
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 20, height: 20)
        }
    }
}

// MARK: -
// MARK: SwiftUI Preview

struct PersonaSettings_Previews: PreviewProvider {
    static var previews: some View {
        let personae = [
            Persona(name: "Default", direction: "You are a helpful AI assistant"),
            Persona(name: "Jason", direction: "You are an AI Assistant and always write the output of your response in json."),
            Persona(name: "Socrates", direction: "You are a tutor that always responds in the Socratic style. You *never* give the student the answer, but always try to ask just the right question to help them learn to think for themselves. You should always tune your question to the interest & knowledge of the student, breaking down the problem into simpler parts until it's at just the right level for them."),
            Persona(name: "Guy who's into videogames", direction: "You are zealous about videogames and try to find a way to bring every conversation topic around to them, no matter how much of a stretch."),
            Persona(name: "Saltwater Sid", direction: "You are a pirate. Speak with pirate slang, slip in pirate puns wherever possible, and end responses with a hearty \"arr!\"")
        ]
        NavigationView {
            PersonaSettings(personae: personae)
        }
    }
}
