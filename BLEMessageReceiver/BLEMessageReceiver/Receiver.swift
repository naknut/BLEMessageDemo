//
//  ContentView.swift
//  BLEMessageReciver
//
//  Created by Marcus Isaksson on 11/2/20.
//

import SwiftUI

struct Receiver: View {
    @ObservedObject var messageReceiver = MessageReceiver()
    
    var body: some View {
        VStack {
            Text(messageReceiver.status?.rawValue ?? "")
            Text(messageReceiver.message ?? "")
        }.onAppear { try! messageReceiver.start() }
    }
}

struct Receiver_Previews: PreviewProvider {
    static var previews: some View {
        Receiver()
    }
}
