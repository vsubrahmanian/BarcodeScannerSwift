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
        // Do any additional setup after loading the view, typically from a nib.
        self.setupScanningSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Start the camera capture session as soon as the view appears completely.
        self.captureSession.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rescanButtonPressed(sender: AnyObject) {
        // Start scanning again.
        self.captureSession.startRunning()
    }
    
    @IBAction func copyButtonPressed(sender: AnyObject) {
        // Copy the barcode text to the clipboard.
        let clipboard = UIPasteboard.generalPasteboard()
        clipboard.string = self.scannedBarcode.text
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Local method to setup camera scanning session.
    func setupScanningSession() {
        // Set camera capture device to default.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSErrorPointer = nil
        
        if let input: AnyObject = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: error) {
            // Adding input souce for capture session.
            self.captureSession.addInput(input as! AVCaptureInput)
        } else {
            println("Error Getting Camera Input")
        }
        
        let output = AVCaptureMetadataOutput()
        // Set recognisable barcode types as all available barcodes.
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // Create a new queue and set delegate for metadata objects scanned
        let dispatchQueue = dispatch_queue_create("scanQueue", nil)
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        // Set output to camera session.
        self.captureSession.addOutput(output)
        
        self.captureLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as? AVCaptureVideoPreviewLayer
        self.captureLayer!.frame = self.cameraPreviewView.frame
        self.captureLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        self.cameraPreviewView.layer.addSublayer(self.captureLayer)
    }
    
    // AVCaptureMetadataOutputObjectsDelegate method
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Do your action on barcode capture here:
        var capturedBarcode: String
        
        // Speify the barcodes you want to read
        let supportedBarcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]
        
        // In all scanned values..
        for barcodeMetadata in metadataObjects {
            // ..check if it is a suported barcode
            for supportedBarcode in supportedBarcodeTypes {
                
                if supportedBarcode == barcodeMetadata.type {
                    // This is a supported barcode
                    // Note barcodeMetadata is of type AVMetadataObject
                    // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                    let barcodeObject = self.captureLayer!.transformedMetadataObjectForMetadataObject(barcodeMetadata as! AVMetadataObject)
                    capturedBarcode = (barcodeObject as! AVMetadataMachineReadableCodeObject).stringValue
                    // Got the barcode. Set the text in the UI and break out of the loop.
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.captureSession.stopRunning()
                        self.scannedBarcode.text = capturedBarcode
                    })
                    return
                }
            }
        }
    }
}