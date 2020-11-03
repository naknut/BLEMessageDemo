//
//  ContentView.swift
//  BLEMessageTest2
//
//  Created by Marcus Isaksson on 11/2/20.
//

import SwiftUI

struct Send: View {
    @State private var message = ""
    private let messageSender = MessageSender()
    
    private func send() {
        try! messageSender.send(message: message)
    }
    
    var body: some View {
        VStack {
            TextField("Message", text: $message, onCommit: send)
            Button("Send", action: send)
        }.onAppear { try! messageSender.start() }
    }
}

struct Send_Previews: PreviewProvider {
    static var previews: some View {
        Send()
    }
}
