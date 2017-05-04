//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import BluetoothKit
import CryptoSwift

internal protocol RemotePeripheralViewControllerDelegate: class {
    func remotePeripheralViewControllerWillDismiss(_ remotePeripheralViewController: RemotePeripheralViewController)
}

internal class RemotePeripheralViewController: UIViewController, BKRemotePeripheralDelegate, BKRemotePeerDelegate, LoggerDelegate {

    // MARK: Properties

    internal weak var delegate: RemotePeripheralViewControllerDelegate?
    internal let central: BKCentral
    internal let remotePeripheral: BKRemotePeripheral

    fileprivate let logTextView = UITextView()
    fileprivate lazy var sendDataBarButtonItem: UIBarButtonItem! = { UIBarButtonItem(title: "Send Data", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RemotePeripheralViewController.sendData)) }()

    // MARK: Initialization

    internal init(central: BKCentral, remotePeripheral: BKRemotePeripheral) {
        self.central = central
        self.remotePeripheral = remotePeripheral
        super.init(nibName: nil, bundle: nil)
        remotePeripheral.delegate = self
        remotePeripheral.peripheralDelegate = self
    }

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    // MARK: UIViewController Life Cycle

    internal override func viewDidLoad() {
        navigationItem.title = remotePeripheral.name
        navigationItem.rightBarButtonItem = sendDataBarButtonItem
        Logger.delegate = self
        view.addSubview(logTextView)
        view.backgroundColor = UIColor.white
        #if os(iOS)
            logTextView.isEditable = false
        #endif
        logTextView.alwaysBounceVertical = true
        applyConstraints()
        print("Awaiting data from peripheral")
    }

    internal override func viewWillDisappear(_ animated: Bool) {
        delegate?.remotePeripheralViewControllerWillDismiss(self)
        
        let num = 3
        print("numは\(num)です") // numは3です
    }

    // MARK: Functions

    internal func applyConstraints() {
        logTextView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view)
        }
    }

    // MARK: BKRemotePeripheralDelegate

    internal func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        navigationItem.title = name
        print("Name change: \(name)")
    }

    internal func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        let str: String! = String(data: data, encoding: .utf8)
        Logger.log(str)
        print("Received data of length: \(data.count) with hash: \(data.md5().toHexString())")
    }

    internal func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        print("Peripheral ready: \(remotePeripheral)")
    }

    // MARK: Target Actions

    // データの送信
    @objc fileprivate func sendData() {
//        let numberOfBytesToSend: Int = Int(arc4random_uniform(950) + 50)
        let data = "いのっちc".data(using: .utf8)!
//        let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
//        print("Prepared \(numberOfBytesToSend) bytes with MD5 hash: \(data.md5().toHexString())")
        print("Sending to \(remotePeripheral)")
        central.sendData(data, toRemotePeer: remotePeripheral) { data, remotePeripheral, error in
            guard error == nil else {
                print("Failed sending to \(remotePeripheral)")
                return
            }
            print("Sent to \(remotePeripheral)")
        }
    }

    // MARK: LoggerDelegate

    internal func loggerDidLogString(_ string: String) {
        if logTextView.text.characters.count > 0 {
            logTextView.text = logTextView.text + ("\n" + string)
        } else {
            logTextView.text = string
        }
        logTextView.scrollRangeToVisible(NSRange(location: logTextView.text.characters.count - 1, length: 1))
    }
}
