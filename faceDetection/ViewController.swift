//
//  ViewController.swift
//  faceDetection
//
//  Created by Jasmeet Kaur on 09/06/18.
//  Copyright © 2018 Jasmeet Kaur. All rights reserved.
//

import UIKit
import AVFoundation
import Vision


class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var featureLayer = CAShapeLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startLiveVideo()
        startFaceDetection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        featureLayer.frame = view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
        featureLayer.strokeColor = UIColor.red.cgColor
        featureLayer.lineWidth = 2.0
        
        //needs to filp coordinate system for Vision
        featureLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        featureLayer.zPosition = 100
       // view.layer.addSublayer(featureLayer)
    }
   
    
    func startLiveVideo() {
        //1
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
       
        
        //2
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = self.view.bounds
        imageLayer.zPosition = 0
        self.view.layer.addSublayer(imageLayer)
        
        
        session.startRunning()
    }
    
    
    func startFaceDetection(){
        
        let request = VNDetectFaceLandmarksRequest(completionHandler: self.handleLandmark)
        
        self.requests = [request]
        }
    
    func handleLandmark(request:VNRequest,error:Error?){
        
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        DispatchQueue.main.async() {
            self.view.layer.sublayers?.removeSubrange(1...)
            for face in observations {
                self.addFaceLandmarksToImage(face)
            }
        }
        
        

    }

    
    func addFaceLandmarksToImage(_ face: VNFaceObservation) {
        
        //Bounding Box
        
        let boundingBox = face.boundingBox
        let size = CGSize(width: boundingBox.width * self.view.bounds.width,
                          height: boundingBox.height * self.view.bounds.height)
        let origin = CGPoint(x: boundingBox.minX * self.view.bounds.width,
                             y: (1 - boundingBox.maxY) * self.view.bounds.height)
        
        
        
        
        let outline = CALayer()
        outline.frame = CGRect(origin: origin, size: size)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        outline.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))

        self.view.layer.addSublayer(outline)
        
        if let landmark = face.landmarks?.faceContour {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        
        if let landmark = face.landmarks?.leftEye {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.rightEye {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.leftEyebrow {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.rightEyebrow {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.leftPupil {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.rightPupil {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.nose {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.noseCrest {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.outerLips {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
        
        if let landmark = face.landmarks?.innerLips {
            
            self.convetPoints(landmark:landmark,width:size.width,height:size.height,frame:outline.frame)
        }
      

    }
    
    
    
    func convetPoints(landmark :VNFaceLandmarkRegion2D,width:CGFloat,height:CGFloat,frame:CGRect){
        
        let path = UIBezierPath()
        
        for i in 0...landmark.pointCount - 1 { // last point is 0,0
            let point = landmark.normalizedPoints[i]
            if i == 0 {
                path.move(to: CGPoint(x: CGFloat(point.x) * width, y: CGFloat(point.y) * height))
            } else {
                path.addLine(to: CGPoint(x:  CGFloat(point.x) * width, y: CGFloat(point.y) * height))
            }
        }
          DispatchQueue.main.async {
            self.draw(path:path,frame:frame)
        }
    }
    
    func draw(path:UIBezierPath,frame:CGRect){
        
        let layer = CAShapeLayer()
       layer.frame = frame
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.blue.cgColor
        layer.fillColor = nil
        layer.path = path.cgPath
        layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
         self.view.layer.addSublayer(layer)
        
    }
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer  else {
            return
        }

        var requestOptions:[VNImageOption : Any] = [:]

        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }

        //let orientation = CGImagePropertyOrientation(rawValue: UInt32(compensatingEXIFOrientation(forDevicePosition:.front,deviceOrientation:UIDevice.current.orientation).rawValue))
        
        let orientation = UInt32(UIImage.Orientation.leftMirrored.rawValue)
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 5)!, options: requestOptions)

        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

}

