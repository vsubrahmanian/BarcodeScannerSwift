//
//  ScanController.swift
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

import UIKit
import AVFoundation

class ScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var scannedBarcode: UITextView!
    @IBOutlet weak var cameraPreviewView: UIView!
    
    let captureSession = AVCaptureSession()
    var captureLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // prepare scanning session
        setupScanningSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the camera capture session as soon as the view appears completely.
        captureSession.startRunning()
    }
    
    @IBAction func rescanButtonPressed(_ sender: AnyObject) {
        // Start scanning again.
        scannedBarcode.text = nil
        captureSession.startRunning()
    }
    
    @IBAction func copyButtonPressed(_ sender: AnyObject) {
        // Copy the barcode text to the clipboard.
        let clipboard = UIPasteboard.general
        clipboard.string = scannedBarcode.text
    }
    
    // Local method to setup camera scanning session.
    func setupScanningSession() {
        // Set camera capture device to default.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create input souce for capture session.
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        }
        catch _ {
            print("Error Getting Camera Input")
        }
        
        let output = AVCaptureMetadataOutput()
        
        // Create a new queue and set delegate for metadata objects scanned
        let dispatchQueue = DispatchQueue(label: "scanQueue", attributes: [])
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        // Set output to camera session.
        captureSession.addOutput(output)
        
        // Set recognisable barcode types as all available barcodes.
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        //make layer
        if let captureLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            captureLayer.frame = cameraPreviewView.bounds
            captureLayer.videoGravity = AVLayerVideoGravityResizeAspect
            cameraPreviewView.layer.addSublayer(captureLayer)
            
            self.captureLayer = captureLayer
        }
        else {
            print("Error Creating Preview Layer")
        }
    }
    
    override func viewDidLayoutSubviews() {
        captureLayer?.frame = cameraPreviewView.bounds
    }
    
    // AVCaptureMetadataOutputObjectsDelegate method
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Do your action on barcode capture here:
        var capturedBarcode: String
        
        // Speify the barcodes you want to read
        let supportedBarcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        
        // In all scanned values..
        for barcodeMetadata in metadataObjects as! [AVMetadataObject] {
            // ..check if it is a suported barcode
            for supportedBarcode in supportedBarcodeTypes {
                if supportedBarcode == barcodeMetadata.type {
                    // This is a supported barcode
                    // Note barcodeMetadata is of type AVMetadataObject
                    // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                    let barcodeObject = captureLayer!.transformedMetadataObject(for: barcodeMetadata)
                    capturedBarcode = (barcodeObject as! AVMetadataMachineReadableCodeObject).stringValue
                    // Got the barcode. Set the text in the UI and break out of the loop.
                    
                    DispatchQueue.main.sync(execute: { () -> Void in
                        captureSession.stopRunning()
                        scannedBarcode.text = capturedBarcode
                    })
                    return
                }
            }
        }
    }
}
