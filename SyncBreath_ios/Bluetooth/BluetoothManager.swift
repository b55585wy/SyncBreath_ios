import Foundation
import CoreBluetooth

public class BluetoothManager: NSObject, ObservableObject {
    public static let shared = BluetoothManager()
    
    @Published public var deviceStatus = DeviceStatus()
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func sendCommand(_ command: BluetoothCommand) {
        guard let peripheral = peripheral,
              let characteristic = characteristic,
              deviceStatus.isConnected else {
            print("Cannot send command: device not connected")
            return
        }
        
        peripheral.writeValue(command.data, for: characteristic, type: .withResponse)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            deviceStatus.isAvailable = true
            startScanning()
        default:
            deviceStatus.isAvailable = false
            deviceStatus.isConnected = false
        }
    }
    
    private func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                self.characteristic = characteristic
                deviceStatus.isConnected = true
                break
            }
        }
    }
}

public struct DeviceStatus {
    public var isAvailable: Bool = false
    public var isConnected: Bool = false
}
