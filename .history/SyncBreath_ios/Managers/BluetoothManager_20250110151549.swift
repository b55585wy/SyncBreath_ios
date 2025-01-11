import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    // MARK: - Published properties
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var showError = false
    @Published var errorMessage: String?
    
    // MARK: - Private properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    // Service and characteristic UUIDs
    private let serviceUUID = CBUUID(string: "FFE0")
    private let characteristicUUID = CBUUID(string: "FFE1")
    private var writeCharacteristic: CBCharacteristic?
    
    // Motor commands
    enum MotorCommand: UInt8 {
        case start = 0x01
        case stop = 0x00
        case speedUp = 0x02
        case speedDown = 0x03
    }
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public methods
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            showError(message: "请打开蓝牙")
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to device: CBPeripheral) {
        peripheral = device
        centralManager.connect(device, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // MARK: - Private methods
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func sendCommand(_ command: MotorCommand) {
        guard let characteristic = writeCharacteristic else {
            showError(message: "设备未准备好")
            return
        }
        
        let data = Data([command.rawValue])
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("蓝牙已开启")
        case .poweredOff:
            showError(message: "请打开蓝牙")
            isConnected = false
        case .unauthorized:
            showError(message: "请授权蓝牙权限")
        case .unsupported:
            showError(message: "设备不支持蓝牙")
        default:
            showError(message: "蓝牙不可用")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectedDevice = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        showError(message: "连接失败: \(error?.localizedDescription ?? "未知错误")")
        isConnected = false
        connectedDevice = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectedDevice = nil
        writeCharacteristic = nil
        if let error = error {
            showError(message: "断开连接: \(error.localizedDescription)")
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            showError(message: "服务发现失败: \(error.localizedDescription)")
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            showError(message: "未找到所需服务")
            return
        }
        
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            showError(message: "特征发现失败: \(error.localizedDescription)")
            return
        }
        
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            showError(message: "未找到所需特征")
            return
        }
        
        writeCharacteristic = characteristic
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            showError(message: "写入失败: \(error.localizedDescription)")
        }
    }
} 