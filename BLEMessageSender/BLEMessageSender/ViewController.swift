//
//  ViewController.swift
//  BLEMessageSender
//
//  Created by Marcus Isaksson on 2019-02-05.
//  Copyright © 2019 Naknut Industries. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet weak var messageTextField: UITextField!
    
    private var peripheralManager: CBPeripheralManager!
    private static let serviceUUID = CBUUID(string: "A48FE431-05B7-4368-A3A9-B607007474B0")
    private var service = CBMutableService(type: ViewController.serviceUUID, primary: true)
    private var characteristic = CBMutableCharacteristic(type: CBUUID(string: "4988510C-858E-4617-854F-A3E72BFF6F0D"), properties: [.notify], value: nil, permissions: .readable)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: UIDevice.current.name, CBAdvertisementDataServiceUUIDsKey: [ViewController.serviceUUID]])
        } else {
            peripheralManager.remove(service)
            peripheralManager.stopAdvertising()
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        if let message = messageTextField.text?.data(using: .utf8) {
            peripheralManager.updateValue(message, for: characteristic, onSubscribedCentrals: nil)
        }
    }
}

