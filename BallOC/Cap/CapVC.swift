/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
//import Vision

//import RealityKit
//import ARKit

import Photos

class CapVC: CC_ViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    var prepareLabel: CC_Label!
    var nextButton: CC_Button!
    
    var sampleCount = 0
    var detectCount = 30
    var shootCount = 0
    var timeCount = 30
    
    var bufferCount = 0 // 第几帧
    var isRecording = false
    
    var writer: PBJMediaWriter!
    
    var scoreLabel: CC_Label! = nil
    var timeLabel: CC_Label! = nil
    
    @IBOutlet private var previewView: UIView!
    private let session = AVCaptureSession()
    private let recordSession = AVCaptureSession()
    
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    //  将捕获到的视频输出到文件
//    let recordOutput = AVCaptureMovieFileOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }
    
    override func cc_viewWillLoad() {
        
        self.cc_navigationBar.isHidden = true
    }
    
    override func cc_viewDidLoad() {

        self.setupTime()
        
        ccs.delay(1) {

            self.setupPreviewView()
            self.writer = PBJMediaWriter.init(outputName: "test1.mp4")
            self.setupAVCapture()
        }
        
    }
    
    override func cc_viewWillAppear() {
        ccs.setDeviceOrientation(.landscapeLeft)
    }
    
    override func cc_viewWillDisappear() {
        ccs.setDeviceOrientation(.portrait)
    }
    
    func setupRecordCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        recordSession.beginConfiguration()
        recordSession.sessionPreset = .vga640x480 // Model image size is smaller.
        recordSession.addInput(deviceInput)
//        recordSession.addOutput(recordOutput)
        
        recordSession.commitConfiguration()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPreviewView() {
//        previewView?.removeFromSuperview()
        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width
        previewView = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.view.addSubview(previewView)
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
//        if session.canAddOutput(recordOutput) {
//            session.addOutput(recordOutput)
//            NSLog("canAddOutput(recordOutput)")
//        } else {
//            NSLog("no canAddOutput(recordOutput)")
//        }
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.videoOrientation = .landscapeRight
        
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.connection?.videoOrientation = .landscapeRight
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        previewLayer.name = "previewLayer"
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
//    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        let buff = CMSampleBufferGetImageBuffer(didDropSampleBuffer)
//        // print("frame dropped")
//
//    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
//        let curDeviceOrientation = UIDevice.current.orientation
        
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}

extension CapVC {
    
    func finish() {
        self.isRecording = false
        ccs.timerCancel("time")
        self.writer.finishWriting {
            print(self.writer.error as Any)
            self.saveVideoToAlbum(videoUrl: self.writer.outputURL)
        }
    }
    
    func setupTime() {
        
        let scoreView = CC_View.init()
        scoreView.frame = CGRect(x: RH(80), y: RH(20), width: RH(100), height: RH(40))
        scoreView.layer.cornerRadius = 8
        scoreView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.view.addSubview(scoreView)
        
        timeLabel = CC_Label.init()
        timeLabel.size = CGSize(width: 200, height: 50)
        timeLabel.center = CGPoint(x: scoreView.width/2, y: scoreView.height/2)
        timeLabel.layer.cornerRadius = 4
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 22)
        timeLabel.textColor = UIColor.white
        timeLabel.text = ""
        scoreView.addSubview(timeLabel)
        
        timeCount = 10
        isRecording = true
        ccs.timerRegister("time", interval: 1) {
            self.updateTime()
        }
    }
    
    func updateTime() {

        if timeCount == 0 {
            ccs.timerCancel("time")
            if isRecording == false {
                return
            }
            self.finish()
            return
        }
        timeCount-=1
        if timeCount < 10 {
            timeLabel.text = String(format: "00:0%d",timeCount)
        } else {
            timeLabel.text = String(format: "00:%d",timeCount)
        }
    }
    
    func updateScore() {
        
        scoreLabel.text = String(format: "Shoot:%d|Goal:0",shootCount)
    }
    
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CapVC: AVCaptureFileOutputRecordingDelegate {
    /// 开始录制
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        PHPhotoLibrary.shared()
    }
    
    /// 结束录制
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//            operatorView.getVideoUrl(videoUrl: outputFileURL)
        
        saveVideoToAlbum(videoUrl: outputFileURL)
    }
    
    /**
     将视频保存到本地
     
     - parameter videoUrl: 保存链接
     */
    private func saveVideoToAlbum(videoUrl: URL) {
        var info = ""
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
        }) { (success, error) in
            if success {
                info = "保存成功"
            } else {
                info = "保存失败，err = \(error.debugDescription)"
            }
            
            print(info)
            
            
        }
    }
}

