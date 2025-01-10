import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    // MARK: - Properties
    static let shared = BluetoothManager()
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    // 服务和特征UUID
    private let serviceUUID = CBUUID(string: "000000FF-0000-1000-8000-00805F9B34FB")
    private let writeCharacteristicUUID = CBUUID(string: "0000FF03-0000-1000-8000-00805F9B34FB")
    private let readAngleCharacteristicUUID = CBUUID(string: "0000FF04-0000-1000-8000-00805F9B34FB")
    
    // 发布状态变化
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectionError: String?
    
    // MARK: - Motor Commands
    enum MotorCommand {
        case forward
        case reverse
        case stop
        case startBreathing
        case stopBreathing
        
        var data: [UInt8] {
            switch self {
            case .forward: return [0x01, 0x03]
            case .reverse: return [0x01, 0x01]
            case .stop: return [0x01, 0x00]
            case .startBreathing: return [0x01, 0x01, 0x01]
            case .stopBreathing: return [0x01, 0x00, 0x01]
            }
        }
    }
    
    // MARK: - Initialization
    override private init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        // 5秒后自动停止扫描
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to peripheral: CBPeripheral) {
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // MARK: - Command Methods
    func sendCommand(_ command: MotorCommand) {
        guard let peripheral = peripheral,
              let characteristic = peripheral.services?
                .first(where: { $0.uuid == serviceUUID })?
                .characteristics?
                .first(where: { $0.uuid == writeCharacteristicUUID })
        else {
            print("未找到特征或设备未连接")
            return
        }
        
        let data = Data(command.data)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // MARK: - Helper Methods
    private func convertToByteArray(_ value: Int) -> [UInt8] {
        let highByte = UInt8((value >> 4) & 0xFF)
        let lowByte = UInt8(value & 0x0F)
        return [highByte, lowByte]
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("蓝牙已开启")
        case .poweredOff:
            print("蓝牙已关闭")
            isConnected = false
            connectionError = "请打开蓝牙"
        case .unauthorized:
            print("蓝牙未授权")
            connectionError = "请授权蓝牙使用权限"
        case .unsupported:
            print("设备不支持蓝牙")
            connectionError = "设备不支持蓝牙"
        default:
            print("其他蓝牙状态")
            connectionError = "蓝牙状态异常"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已连接到设备: \(peripheral.name ?? "未知设备")")
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        isConnected = true
        connectionError = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败: \(error?.localizedDescription ?? "未知错误")")
        connectionError = "连接失败: \(error?.localizedDescription ?? "未知错误")"
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("设备已断开连接")
        isConnected = false
        if let error = error {
            connectionError = "断开连接: \(error.localizedDescription)"
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("发现服务错误: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([writeCharacteristicUUID, readAngleCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("发现特征错误: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == readAngleCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("读取数据错误: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else { return }
        if characteristic.uuid == readAngleCharacteristicUUID {
            // 解析角度数据
            if data.count >= 4 {
                let waistValue = Float((Int(data[0]) << 8) + Int(data[1])) / 100.0
                let ribCageValue = Float((Int(data[2]) << 8) + Int(data[3])) / 100.0
                print("腰围: \(waistValue)cm, 胸围: \(ribCageValue)cm")
                // TODO: 发布数据更新通知
            }
        }
    }
} 