//
//  ContentView.swift
//  OCR-Test
//
//  Created by Md. Faysal Ahmed on 4/3/23.
//

import UIKit
import Vision
import AVFoundation

class CameraKeyboard: UIView {
    weak var textField: UITextField?

    public var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var recognizedTextBoxLayer: CALayer?

    private lazy var aimContainerView: UIView = {
        let view = UIView(frame: self.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0.7

        return view
    } ()

    init() {
        super.init(frame: .init(x: 0, y: 0, width: 320, height: 300))
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        addSubview(aimContainerView)
        NSLayoutConstraint.activate([
            aimContainerView.topAnchor.constraint(equalTo: topAnchor),
            aimContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            aimContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            aimContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        addAimView()
    }

    private func addAimView() {
        let upperView = UIView()
        let lowerView = UIView()
        let leftView = UIView()
        let rightView = UIView()

        let views: [UIView] = [upperView, lowerView, leftView, rightView]
        views.forEach {
            $0.backgroundColor = UIColor(red: 0.00, green: 0.53, blue: 0.75, alpha: 1.00)
            $0.translatesAutoresizingMaskIntoConstraints = false
            aimContainerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            upperView.bottomAnchor.constraint(equalTo: aimContainerView.centerYAnchor, constant: -4),
            upperView.centerXAnchor.constraint(equalTo: aimContainerView.centerXAnchor),
            upperView.heightAnchor.constraint(equalToConstant: 16),
            upperView.widthAnchor.constraint(equalToConstant: 2),

            lowerView.topAnchor.constraint(equalTo: aimContainerView.centerYAnchor, constant: 4),
            lowerView.centerXAnchor.constraint(equalTo: aimContainerView.centerXAnchor),
            lowerView.heightAnchor.constraint(equalToConstant: 16),
            lowerView.widthAnchor.constraint(equalToConstant: 2),

            leftView.trailingAnchor.constraint(equalTo: aimContainerView.centerXAnchor, constant: -4),
            leftView.centerYAnchor.constraint(equalTo: aimContainerView.centerYAnchor),
            leftView.heightAnchor.constraint(equalToConstant: 2),
            leftView.widthAnchor.constraint(equalToConstant: 16),

            rightView.leadingAnchor.constraint(equalTo: aimContainerView.centerXAnchor, constant: 4),
            rightView.centerYAnchor.constraint(equalTo: aimContainerView.centerYAnchor),
            rightView.heightAnchor.constraint(equalToConstant: 2),
            rightView.widthAnchor.constraint(equalToConstant: 16),
        ])
    }

    // MARK: Camera
    public func startCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            guard let self = self else { return }
            if response {
                self.setupAndStartCaptureSession()
            } else {
                // TODO: ask for permission
            }
        }
    }

    private func stopCamera() {
        previewLayer?.removeFromSuperlayer()
        captureSession?.stopRunning()

        previewLayer = nil
        captureSession = nil
        clearTextBoxLayer()
    }
    
    private func setupAndStartCaptureSession() {
        if let captureSession = self.captureSession {
            print("capture session already exists")
            setupPreviewLayer(captureSession: captureSession)
            return
        }

        // start camera session will block the main thread, so we start in background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let captureSession = AVCaptureSession()
            self.captureSession = captureSession
            captureSession.beginConfiguration()

            captureSession.sessionPreset = .medium // medium quality is good enough for text recognition
            self.setupCameraInput(captureSession: captureSession)
            self.setupOutput(captureSession: captureSession)

            captureSession.commitConfiguration()
            captureSession.startRunning()

            DispatchQueue.main.async {
                self.setupPreviewLayer(captureSession: captureSession)
            }
        }
    }

    private func setupCameraInput(captureSession: AVCaptureSession) {
        // use back camera only
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            //handle this appropriately for production purposes
            fatalError("no back camera")
        }

        guard let backInput = try? AVCaptureDeviceInput(device: device) else {
            fatalError("could not create input device from back camera")
        }

        guard captureSession.canAddInput(backInput) else {
            fatalError("could not add back camera input to capture session")
        }

        captureSession.addInput(backInput)
    }

    private func setupPreviewLayer(captureSession: AVCaptureSession) {
        guard previewLayer == nil else {
            print("preview layer already exists")
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = CGRect(origin: .zero, size: frame.size)
    }

    private func setupOutput(captureSession: AVCaptureSession) {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if captureSession.canAddOutput(videoOutput) == true {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }

        videoOutput.connections.first?.videoOrientation = .portrait
    }

    // MARK: text recognition
    private func detectText(buffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest(completionHandler: textRecognitionHandler)
        if let langs = try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequest.defaultRevision),
           langs.contains("zh-Hant") {
            // recognize chinese if supported
            request.recognitionLanguages = ["zh-Hant", "en-US", "ru", "es", "th", "de", "nl"]
        } else {
            request.recognitionLanguages = ["en-US"]
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        performDetection(request: request, buffer: buffer)
    }

    func performDetection(request: VNRecognizeTextRequest, buffer: CVPixelBuffer) {
        let requests = [request]
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }

    private func textRecognitionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            // no result
            DispatchQueue.main.async {
                self.clearTextBoxLayer()
            }
            return
        }

        let results = observations.compactMap { $0 as? VNRecognizedTextObservation }
        DispatchQueue.main.async {
            self.clearTextBoxLayer()
        }
        for result in results {
            // find the recognized text in the center of image with certain confidence
            for text in result.topCandidates(1)
            where text.confidence >= 0.5 && result.boundingBox.contains(.init(x: 0.5, y: 0.5)) {
                DispatchQueue.main.async {
                    self.textField?.text = text.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.textField?.sendActions(for: .valueChanged)
                    print("Poo: ", text.string.trimmingCharacters(in: .whitespacesAndNewlines))

                    self.highlightWord(box: result)
                }

                return // use the first one only
            }
        }
    }

    private func highlightWord(box: VNRecognizedTextObservation) {
        recognizedTextBoxLayer?.removeFromSuperlayer()

        // the bounding box is originated from bottom left corner with normalized value (0-1)
        // so we need to convert it to the view coordinate system
        let xCord = box.topLeft.x * frame.size.width - 5
        let yCord = (1 - box.topLeft.y) * frame.size.height - 5
        let width = (box.topRight.x - box.bottomLeft.x) * frame.size.width + 10
        let height = (box.topLeft.y - box.bottomLeft.y) * frame.size.height + 10

        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.red.cgColor
        recognizedTextBoxLayer = outline

        if let layer = previewLayer {
            layer.insertSublayer(outline, above: layer)
        } else {
            layer.insertSublayer(outline, at: 0)
        }
    }

    private func clearTextBoxLayer() {
        recognizedTextBoxLayer?.removeFromSuperlayer()
        recognizedTextBoxLayer = nil
    }
}

extension CameraKeyboard: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        detectText(buffer: cvBuffer)
    }
}
