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
import SnapKit
import BluetoothKit
import CryptoSwift

internal class PeripheralViewController: UIViewController, AvailabilityViewController, BKPeripheralDelegate, LoggerDelegate, BKRemotePeerDelegate {

    @IBOutlet weak var textView: UITextView!

    // MARK: Properties

    internal var availabilityView = AvailabilityView()

    fileprivate let peripheral = BKPeripheral()
//    fileprivate let logTextView = UITextView()
//    fileprivate lazy var sendDataBarButtonItem: UIBarButtonItem! = { UIBarButtonItem(title: "Send Data", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PeripheralViewController.sendData)) }()
    
    var count = 0

    // MARK: UIViewController Life Cycle

    internal override func viewDidLoad() {
        navigationItem.title = "Peripheral"
        view.backgroundColor = UIColor.white
        Logger.delegate = self
        applyAvailabilityView() // 画面下のbluetoothのオンオフのstatusを表示
//        logTextView.isEditable = false
//        logTextView.alwaysBounceVertical = true
        textView.isEditable = false
        textView.alwaysBounceVertical = true
//        view.addSubview(logTextView)
//        applyConstraints()
        startPeripheral()
//        sendDataBarButtonItem.isEnabled = false
//        navigationItem.rightBarButtonItem = sendDataBarButtonItem
    }

    deinit {
        _ = try? peripheral.stop()
    }

    // MARK: Functions

//    fileprivate func applyConstraints() {
//        logTextView.snp.makeConstraints { make in
//            make.top.equalTo(topLayoutGuide.snp.bottom)
//            make.leading.trailing.equalTo(view)
//            make.bottom.equalTo(availabilityView.snp.top)
//        }
//        logTextView.backgroundColor = UIColor.cyan
//    }

    fileprivate func startPeripheral() {
        do {
            peripheral.delegate = self
            peripheral.addAvailabilityObserver(self)
            let dataServiceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let dataServiceCharacteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let localName = Bundle.main.infoDictionary!["CFBundleName"] as? String
            let configuration = BKPeripheralConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            print("Awaiting connections from remote centrals")
        } catch let error {
            print("Error starting: \(error)")
        }
    }

    fileprivate func refreshControls() {
        navigationItem.rightBarButtonItem?.isEnabled = peripheral.connectedRemoteCentrals.count > 0
//        sendDataBarButtonItem.isEnabled = peripheral.connectedRemoteCentrals.count > 0
    }

    // MARK: Target Actions

    // データの送信
//    @objc fileprivate func sendData() {
//        count += 1
//        let str = String("+1")
//        let data = str!.data(using: .utf8)!
//        for remoteCentral in peripheral.connectedRemoteCentrals {
//            print("Sending to \(remoteCentral)")
//            peripheral.sendData(data, toRemotePeer: remoteCentral) { data, remoteCentral, error in
//                guard error == nil else {
//                    print("Failed sending to \(remoteCentral)")
//                    return
//                }
//                print("Sent to \(remoteCentral)")
//            }
//        }
//    }
    
    @IBAction func sendButton(_ sender: UIBarButtonItem) {
        count += 1
        let str = String("+1")
        let data = str!.data(using: .utf8)!
        for remoteCentral in peripheral.connectedRemoteCentrals {
            print("Sending to \(remoteCentral)")
            peripheral.sendData(data, toRemotePeer: remoteCentral) { data, remoteCentral, error in
                guard error == nil else {
                    print("Failed sending to \(remoteCentral)")
                    return
                }
                print("Sent to \(remoteCentral)")
            }
        }

    }
    

    // MARK: BKPeripheralDelegate

    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("Remote central did connect: \(remoteCentral)")
        remoteCentral.delegate = self
        refreshControls()
    }

    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("Remote central did disconnect: \(remoteCentral)")
        refreshControls()
    }

    // MARK: BKRemotePeerDelegate

    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        let str: String! = String(data: data, encoding: .utf8)
        if str == "+1" { count += 1 }
        Logger.log(String(count))
        print("Received data of length: \(data.count) with hash: \(data.md5().toHexString())")
    }

    // MARK: LoggerDelegate

    internal func loggerDidLogString(_ string: String) {
//        if logTextView.text.characters.count > 0 {
//            logTextView.text = logTextView.text + ("\n" + string)
//        } else {
//            logTextView.text = string
//        }
//        logTextView.scrollRangeToVisible(NSRange(location: logTextView.text.characters.count - 1, length: 1))

        if textView.text.characters.count > 0 {
            textView.text = textView.text + ("\n" + string)
        } else {
            textView.text = string
        }
        textView.scrollRangeToVisible(NSRange(location: textView.text.characters.count - 1, length: 1))
    
    }

}
