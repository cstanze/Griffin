//
//  GriffinDeviceDelegate.swift
//  Griffin
//
//  Created by Jules Amalie on 2022/04/12.
//

import Cocoa
import IOKit
import USBDeviceSwift

public struct GriffinUSBDevice {
  /// The IOKit id of the usb device
  public let id: UInt64
  
  /// The vendor id of the usb device
  public let vendorId: UInt16
  
  /// The product id of the usb device
  public let productId: UInt16
  
  /// The name of the usb device
  public let name: String
  
  /// A double pointer to the IOKit device interface
  public let deviceInterface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
  
  public init(id: UInt64,
              vendorId: UInt16,
              productId: UInt16,
              name: String,
              deviceInterface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?) {
    self.id = id
    self.vendorId = vendorId
    self.productId = productId
    self.name = name
    self.deviceInterface = deviceInterface
  }
}

public protocol GriffinDeviceDelegate: AnyObject {
  /// Run when a new griffin device is connected.
  ///
  /// If this method returns `true`, force the replacement of the currently tracked connected device.
  /// Otherwise, don't overwrite an already connected and tracked device. If a device is not being tracked,
  /// this boolean value is ignored and the new device is automatically tracked.
  ///
  /// - Parameter griffin: The new device that was connected
  ///
  /// - Returns: A boolean indicating the replacement of the tracked and connected device. See the discussion for more
  func griffinConnected(_ griffin: GriffinUSBDevice) -> Bool
  
  /// Run when a griffin device is disconnected
  /// - Parameter deviceId: The device id of the disconnected
  /// - Parameter isCurrentDevice: This is `true` when the device that was disconnect is the currently connected device
  func griffinDisconnected(_ deviceId: UInt64, _ isCurrentDevice: Bool)
  
  /// Called when the griffin knob is turned
  /// - Parameter offset: The offset of the knob turn. Griffin doesn't use absolute positioning, instead offsets
  func griffinKnobTurn(_ offset: Int8)
  
  /// Called when the griffin button state has changed
  /// - Parameter buttonState: The new state of the button
  func griffinButtonStateChanged(_ buttonState: Bool)
  
  /// Called when an error occurred in the main monitor loop
  /// - Parameter error: The error that occurred
  func griffinErrorOccurred(_ error: GriffinDeviceError)
}
