//
//  ViewController.swift
//  inClass-TableViewBluetoothChat
//
//  Created by Marcea Decker on 4/21/15.
//  Copyright (c) 2015 md. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate,CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Core Bluetooth "Global" Variables
    var myCentralManager = CBCentralManager() // only one instance of this
    var peripheralArray = [CBPeripheral]() // an array of CBPeripherals
    
    // CB Arrays and Dictionary
    var fullPeripheralArray = [("","","","")] // Array of tuples, data goes here first
    var myPeripheralDictionary : [String:(String, String, String, String)] = ["Key" : ("","","","")]// Make dictionary for the above tuples to show only unique values, data goes here second...
    var cleanAndSortedArray = [("","","","")] // Clean and sort fullPeripheralArray, needs same count as above, data goes here third - build table view from here

    
    //Outlet Stuff
    @IBOutlet weak var myTableView: NSTableView!
    @IBOutlet weak var statusLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshArrays()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //Button actions
    
    @IBAction func scanButton(sender: NSButton) {
        myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services
        statusLabel.stringValue = "Scanning for Peripherals..."
        println("Scanning for Peripherals")
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        myCentralManager.stopScan()   // stop scanning to save power
        myPeripheralDictionary.removeAll(keepCapacity: false)
        myTableView.reloadData()
        statusLabel.stringValue = "Refreshing..."
        println("Refresh")
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        myPeripheralDictionary.removeAll(keepCapacity: false)
        myCentralManager.stopScan()   // stop scanning to save power
        statusLabel.stringValue = "Stopped Scanning"
        println("Stopped Scanning")
    }

    func refreshArrays(){
        
        fullPeripheralArray.removeAll(keepCapacity: true)
        cleanAndSortedArray.removeAll(keepCapacity: true)
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int {
        return 1
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return cleanAndSortedArray.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        var CID = tableColumn?.identifier
        
        switch (CID!) {
            
        case "c1":
            return cleanAndSortedArray[row].0
            break;
            
        case "c2":
            return cleanAndSortedArray[row].1
            break;
            
        case "c3":
            return cleanAndSortedArray[row].2
            break;
            
        case "c4":
            return cleanAndSortedArray[row].3
            break;
            
        default:
            return nil
            break;
        }
    }
    
    
    // Configure the cell...
    
    
    func tableView(tableView: NSTableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Proximity / Name  "
        }else if section == 1{
            return "Far Away"
        } else {
            return "Misc"
        }
    }

    // Core Bluetooth Stuff
    
    // Put Central Manager into the main queue
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    //Did Update State
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        // tells us if device BLE is on or off
        // tells user to turn it on...
        
        switch central.state{
        case .PoweredOn:
            println("poweredOn")
            //statusLabel.text = "BLE ON"
            
        case .PoweredOff:
            println("poweredOff")
            //statusLabel.text = "BLE OFF"
            
        default:
            println("Central State None of the Above")
        }
    }
    
    // Did Discover Peripherals
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println("Did Discover Peripheral")
        
        // Refresh Entry or Make an New Entry into Dictionary
        let myUUIDString = peripheral.identifier.UUIDString
        let myRSSIString = String(RSSI.intValue) // creating String instance, passing NSNumber to intValue w/ RSSI.intValue
        var myNameString = peripheral.name
        var myAdvertisedService = peripheral.services
        var myAdvertString = "\(myAdvertisedService)"
        var myAdvertisedServices = peripheral.services
        
        
        var keyNameString = "\(advertisementData[CBAdvertisementDataLocalNameKey]?.name)"
        
        var myArray = advertisementData
        var advertString = "\(advertisementData)"
        
        
        // RSSI = 127 0 - -100
        if RSSI.intValue < 0 {
            
            let myTuple = (myUUIDString, myRSSIString, "\(myNameString)", myAdvertString)
            myPeripheralDictionary[myTuple.0] = myTuple // No Duplicate Peripherals
            
            // Clean Array
            fullPeripheralArray.removeAll(keepCapacity: false)
            
            // Transfer Dictionary into Array
            for eachItem in myPeripheralDictionary{
                fullPeripheralArray.append(eachItem.1)
            }
            
            // Sort Array by RSSI
            cleanAndSortedArray = sorted(fullPeripheralArray, { (str1: (String, String, String, String), str2: (String, String, String, String)) -> Bool in
                return str1.1.toInt() > str2.1.toInt()
            })
        }
        
        println("\(cleanAndSortedArray)") //Debug
        myTableView.reloadData()
    }
    
}

