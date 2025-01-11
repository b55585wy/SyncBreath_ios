import SwiftUI

struct HardwareConnectionView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设备状态")) {
                    HStack {
                        Image(systemName: bluetoothManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                            .frame(width: 44, height: 44) // 符合Apple触控区域建议
                        
                        VStack(alignment: .leading) {
                            Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                                .font(.headline)
                            if let deviceName = bluetoothManager.connectedDevice?.name {
                                Text(deviceName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if bluetoothManager.isConnected {
                            Button(action: {
                                bluetoothManager.disconnect()
                            }) {
                                Image(systemName: "disconnect.circle.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                }
                
                Section(header: Text("可用设备")) {
                    if bluetoothManager.isScanning {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("正在搜索...")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothManager.connect(to: device)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.name ?? "未知设备")
                                        .font(.body)
                                    Text(device.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .frame(minHeight: 44) // 确保可点击区域足够大
                        }
                    }
                }
            }
            .navigationTitle("设备连接")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Image(systemName: bluetoothManager.isScanning ? "stop.circle.fill" : "arrow.clockwise.circle.fill")
                            .frame(width: 44, height: 44)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("连接错误", isPresented: $bluetoothManager.showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(bluetoothManager.errorMessage ?? "未知错误")
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

#Preview {
    HardwareConnectionView()
} 