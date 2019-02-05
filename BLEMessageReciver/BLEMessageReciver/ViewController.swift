//
//  ViewController.swift
//  BLEMessageReciver
//
//  Created by Marcus Isaksson on 2017-12-27.
//  Copyright © 2017 Naknut Industries. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    let serviceUUID = CBUUID(string: "A48FE431-05B7-4368-A3A9-B607007474B0")
    let characteristicUUID = CBUUID(string: "4988510C-858E-4617-854F-A3E72BFF6F0D")
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    //MARK: - Central manager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            statusLabel.text = "Status: Scanning"
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        statusLabel.text = "Status: Discovered"
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        statusLabel.text = "Status: Connected"
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    //MARK: - Peripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        statusLabel.text = "Status: Discovered Service"
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        statusLabel.text = "Status: Discovered Characteristics"
        if let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID}) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            messageLabel.text = String(data: data, encoding: .utf8)
        }
    }
}

