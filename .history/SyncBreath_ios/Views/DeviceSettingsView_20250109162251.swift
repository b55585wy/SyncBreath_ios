import SwiftUI

struct DeviceSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var showWifiSetup = false
    @State private var showDeviceList = false
    @State private var motorVoltage: Double = 0.8
    @State private var pumpVoltage: Double = 0.8
    @State private var wifiSSID = ""
    @State private var wifiPassword = ""
    
    var body: some View {
        NavigationView {
            Form {
                // 设备连接状态
                Section("设备状态") {
                    HStack {
                        Image(systemName: bluetoothManager.isConnected ? "bluetooth.connected" : "bluetooth")
                            .foregroundColor(bluetoothManager.isConnected ? .blue : .gray)
                        Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                        Spacer()
                        if bluetoothManager.isConnected {
                            Button("断开连接") {
                                bluetoothManager.disconnect()
                            }
                            .foregroundColor(.red)
                        } else {
                            Button("连接设备") {
                                showDeviceList = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if bluetoothManager.isConnected {
                        HStack {
                            Image(systemName: "battery.100")
                            Text("电池电量")
                            Spacer()
                            Text("\(bluetoothManager.batteryLevel)%")
                        }
                    }
                }
                
                if bluetoothManager.isConnected {
                    // 电机设置
                    Section("电机设置") {
                        VStack {
                            HStack {
                                Text("电机电压")
                                Spacer()
                                Text("\(Int(motorVoltage * 100))%")
                            }
                            Slider(value: $motorVoltage, in: 0...1) { changed in
                                if !changed {
                                    bluetoothManager.setMotorVoltage(motorVoltage)
                                }
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text("气泵电压")
                                Spacer()
                                Text("\(Int(pumpVoltage * 100))%")
                            }
                            Slider(value: $pumpVoltage, in: 0...1) { changed in
                                if !changed {
                                    bluetoothManager.setPumpVoltage(pumpVoltage)
                                }
                            }
                        }
                    }
                    
                    // WiFi设置
                    Section("网络设置") {
                        TextField("WiFi名称", text: $wifiSSID)
                        SecureField("WiFi密码", text: $wifiPassword)
                        Button("配置WiFi") {
                            bluetoothManager.configureWiFi(ssid: wifiSSID, password: wifiPassword)
                        }
                        .disabled(wifiSSID.isEmpty || wifiPassword.isEmpty)
                    }
                    
                    // 系统设置
                    Section("系统设置") {
                        Button("重启设备") {
                            bluetoothManager.sendCommand([0x03, 0x01, 0x05])
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("设备设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDeviceList) {
                DeviceListView()
            }
        }
    }
}

struct DeviceListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        NavigationView {
            List {
                if bluetoothManager.isScanning {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 8)
                        Text("正在扫描...")
                    }
                }
                
                ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                    Button(action: {
                        bluetoothManager.connect(to: device)
                        dismiss()
                    }) {
                        HStack {
                            Text(device.name ?? "未知设备")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("选择设备")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Text(bluetoothManager.isScanning ? "停止" : "扫描")
                    }
                }
            }
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
    }
}

#Preview {
    DeviceSettingsView()
}
