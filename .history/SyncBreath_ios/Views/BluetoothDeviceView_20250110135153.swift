import SwiftUI

struct BluetoothDeviceView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // 状态信息
                if let error = bluetoothManager.connectionError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 设备列表
                List {
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothManager.connect(to: device)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.name ?? "未知设备")
                                        .font(.headline)
                                    Text(device.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if bluetoothManager.isConnected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .disabled(bluetoothManager.isConnected)
                    }
                }
                
                // 扫描按钮
                Button(action: {
                    if bluetoothManager.isScanning {
                        bluetoothManager.stopScanning()
                    } else {
                        bluetoothManager.startScanning()
                    }
                }) {
                    HStack {
                        Image(systemName: bluetoothManager.isScanning ? "stop.circle.fill" : "arrow.clockwise.circle.fill")
                        Text(bluetoothManager.isScanning ? "停止扫描" : "开始扫描")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(bluetoothManager.isScanning ? Color.red : Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                
                if bluetoothManager.isConnected {
                    Button(action: {
                        bluetoothManager.disconnect()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("断开连接")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("设备连接")
            .navigationBarItems(trailing: Button("完成") {
                dismiss()
            })
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
    BluetoothDeviceView()
} 