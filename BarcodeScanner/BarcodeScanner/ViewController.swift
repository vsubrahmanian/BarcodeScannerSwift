//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scannedBarcodeText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set the barcode text which is copied to the clipboard.
        let clipboard = UIPasteboard.generalPasteboard()
        // Reading the barcode (if any) from the clipboard and setting the text.
        if let barcode = clipboard.string {
            self.scannedBarcodeText.text = barcode;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

