//
//  PeripheralManager.swift
//  BLEMessageDemo2Reciver
//
//  Created by Marcus Isaksson on 11/2/20.
//

import SwiftUI
import CoreBluetooth

class MessageSender: NSObject, CBPeripheralManagerDelegate {
    enum Error: Swift.Error {
        case allreadyStarted, notStarted
    }
    
    private var peripheralManager: CBPeripheralManager?
    private static let serviceUUID = CBUUID(string: "A48FE431-05B7-4368-A3A9-B607007474B0")
    private var service = CBMutableService(type: MessageSender.serviceUUID, primary: true)
    private var characteristic = CBMutableCharacteristic(type: CBUUID(string: "4988510C-858E-4617-854F-A3E72BFF6F0D"),
                                                         properties: [.notify],
                                                         value: nil,
                                                         permissions: .readable)
    
    func start() throws {
        guard peripheralManager == nil else { throw Error.allreadyStarted }
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            service.characteristics = [characteristic]
            peripheral.add(service)
            peripheral.startAdvertising([CBAdvertisementDataLocalNameKey: UIDevice.current.name, CBAdvertisementDataServiceUUIDsKey: [MessageSender.serviceUUID]])
        } else {
            peripheral.remove(service)
            peripheral.stopAdvertising()
        }
    }
    
    func send(message: String) throws {
        guard let peripheralManager = peripheralManager else { throw Error.notStarted }
        guard let data = message.data(using: .utf8) else { return }
        peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
    }
}
