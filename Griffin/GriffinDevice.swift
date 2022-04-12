//
//  GriffinDevice.swift
//  Griffin
//
//  Created by Jules Amalie on 2022/04/12.
//

import Cocoa
import USBDeviceSwift

public class GriffinDevice {
  /// The device's delegate class
  weak public var delegate: GriffinDeviceDelegate?
  
  private var device: USBDevice?
  private var requestPtr: [Int8] = [Int8](repeating: 0, count: 6)
  private let griffinMonitor = USBDeviceMonitor([
    USBMonitorData(vendorId: 0x077d, productId: 0x0410)
  ])
  
  public init(delegate: GriffinDeviceDelegate?) {
    self.delegate = delegate
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  public func run() {
    let griffinDeviceDaemon = Thread(target: griffinMonitor, selector: #selector(griffinMonitor.start), object: nil)
    griffinDeviceDaemon.start()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected(_:)), name: .USBDeviceConnected, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected(_:)), name: .USBDeviceDisconnected, object: nil)
    
    self.monitor()
  }
  
  private func monitor() {
    while true {
      guard let device = device else {
        continue
      }
      guard let deviceInterface = device.deviceInterfacePtrPtr?.pointee?.pointee else {
        self.delegate?.griffinErrorOccurred(.deviceInterfaceNotFound)
        continue
      }
      
      var kr: Int32 = 0
      requestPtr = [Int8](repeating: 0, count: 6)
      requestPtr[3] = 0
      requestPtr[4] = 0x7f & ~(0 << 8)
      requestPtr[5] = 0
      var request = IOUSBDevRequest(bmRequestType: 161,
                                    bRequest: 0x01,
                                    wValue: 0,
                                    wIndex: 0,
                                    wLength: UInt16(6),
                                    pData: &requestPtr,
                                    wLenDone: 255)
      kr = deviceInterface.DeviceRequest(device.deviceInterfacePtrPtr, &request)
      
      if kr != kIOReturnSuccess {
        self.delegate?.griffinErrorOccurred(.IOKitError(kr))
        continue
      }
      
      self.delegate?.griffinButtonStateChanged(requestPtr[0] == 1)
      self.delegate?.griffinKnobTurn(requestPtr[1])
    }
  }
  
  @objc private func usbConnected(_ notification: NSNotification) {
    guard let obj = notification.object as? NSDictionary else {
      return
    }
    
    guard let newDevice: USBDevice = obj["device"] as? USBDevice else {
      return
    }
    
    let newGriffinDevice = GriffinUSBDevice(id: newDevice.id,
                                            vendorId: newDevice.vendorId,
                                            productId: newDevice.productId,
                                            name: newDevice.name,
                                            deviceInterface: newDevice.deviceInterfacePtrPtr)
    if (self.delegate?.griffinConnected(newGriffinDevice) ?? false) || device == nil {
      device = newDevice
    }
  }
  
  @objc private func usbDisconnected(_ notification: NSNotification) {
    guard let obj = notification.object as? NSDictionary else {
      return
    }
    
    guard let deviceId: UInt64 = obj["id"] as? UInt64 else {
      return
    }
    
    self.delegate?.griffinDisconnected(deviceId, device == nil ? false : device!.id == deviceId)
    device = nil
  }
}
