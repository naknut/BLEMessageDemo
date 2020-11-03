//
//  MessageReceiver.swift
//  BLEMessageReceiver
//
//  Created by Marcus Isaksson on 11/2/20.
//

import SwiftUI
import CoreBluetooth

class MessageReceiver: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    enum Error: Swift.Error {
        case allreadyStarted, notStarted
    }
    
    enum Status: String {
        case started, scanning, discovered, connected, discoveredServices, discoveredCharacteristics
    }
    
    @Published var message: String?
    @Published var status: Status?
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    let serviceUUID = CBUUID(string: "A48FE431-05B7-4368-A3A9-B607007474B0")
    let characteristicUUID = CBUUID(string: "4988510C-858E-4617-854F-A3E72BFF6F0D")
    
    override init() {
        super.init()
        print("Init")
    }
    
    func start() throws {
        guard centralManager == nil else { throw Error.allreadyStarted }
        status = .started
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    //MARK: - Central manager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            status = .scanning
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        status = .discovered
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        status = .connected
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    //MARK: - Peripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Swift.Error?) {
        status = .discoveredServices
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Swift.Error?) {
        status = .discoveredCharacteristics
        if let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID}) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Swift.Error?) {
        if let data = characteristic.value {
            message = String(data: data, encoding: .utf8)
        }
    }
}
