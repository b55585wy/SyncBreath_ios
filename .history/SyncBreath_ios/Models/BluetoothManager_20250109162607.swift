import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    // MARK: - Published Properties
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var batteryLevel: Int = 0
    @Published var rotationAngle: Float = 0
    @Published var motorCurrent: Float = 0
    
    // MARK: - Service and Characteristic UUIDs
    private let serviceUUID = CBUUID(string: "FF00")
    private let batteryCharUUID = CBUUID(string: "FF02")
    private let commandCharUUID = CBUUID(string: "FF03")
    private let rotationCharUUID = CBUUID(string: "FF04")
    private let currentCharUUID = CBUUID(string: "FF05")
    private let wifiSSIDCharUUID = CBUUID(string: "FF06")
    private let wifiPasswordCharUUID = CBUUID(string: "FF07")
    
    // MARK: - Private Properties
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - Command Methods
    func sendCommand(_ bytes: [UInt8]) {
        guard let peripheral = connectedPeripheral,
              let characteristic = commandCharacteristic else {
            return
        }
        
        let data = Data(bytes)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func startBreathing(inhaleTime: Double, exhaleTime: Double) {
        // Set inhale time
        let inhaleValue = UInt8(inhaleTime * 10)
        sendCommand([0x01, 0x01, inhaleValue])
        
        // Set exhale time
        let exhaleValue = UInt8(exhaleTime * 10)
        sendCommand([0x01, 0x02, exhaleValue])
        
        // Start breathing
        sendCommand([0x01, 0x01, 0x01])
    }
    
    func stopBreathing() {
        sendCommand([0x01, 0x00, 0x01])
    }
    
    func setMotorVoltage(_ ratio: Double) {
        let value = UInt8(ratio * 255)
        sendCommand([0x01, 0x03, value])
    }
    
    func setPumpVoltage(_ ratio: Double) {
        let value = UInt8(ratio * 255)
        sendCommand([0x01, 0x04, value])
    }
    
    func configureWiFi(ssid: String, password: String) {
        guard let peripheral = connectedPeripheral,
              let wifiSSIDChar = peripheral.services?.first(where: { $0.uuid == serviceUUID })?
                .characteristics?.first(where: { $0.uuid == wifiSSIDCharUUID }),
              let wifiPasswordChar = peripheral.services?.first(where: { $0.uuid == serviceUUID })?
                .characteristics?.first(where: { $0.uuid == wifiPasswordCharUUID }) else {
            return
        }
        
        // Write SSID
        if let ssidData = ssid.data(using: .utf8) {
            peripheral.writeValue(ssidData, for: wifiSSIDChar, type: .withResponse)
        }
        
        // Write Password
        if let passwordData = password.data(using: .utf8) {
            peripheral.writeValue(passwordData, for: wifiPasswordChar, type: .withResponse)
        }
        
        // Initialize WiFi
        sendCommand([0x02, 0x01, 0x02])
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available: \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) && peripheral.name?.hasPrefix("SYNC") == true {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        isConnected = true
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        commandCharacteristic = nil
        isConnected = false
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            case batteryCharUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            case commandCharUUID:
                commandCharacteristic = characteristic
            case rotationCharUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            case currentCharUUID:
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        switch characteristic.uuid {
        case batteryCharUUID:
            if data.count >= 1 {
                batteryLevel = Int(data[0])
            }
        case rotationCharUUID:
            if data.count >= 4 {
                rotationAngle = data.withUnsafeBytes { $0.load(as: Float.self) }
            }
        case currentCharUUID:
            if data.count >= 4 {
                motorCurrent = data.withUnsafeBytes { $0.load(as: Float.self) }
            }
        default:
            break
        }
    }
}
