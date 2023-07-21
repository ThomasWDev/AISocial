//
//  ScannerView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 25/5/23.
//

import Foundation
import VisionKit
import SwiftUI
import Vision

struct ScannerView: UIViewControllerRepresentable {
    private let completionHandler: ([String]?) -> Void

    init(completion: @escaping ([String]?) -> Void) {
        self.completionHandler = completion
    }

    typealias UIViewControllerType = VNDocumentCameraViewController

    func makeUIViewController(context:
                              UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController,
                                context: UIViewControllerRepresentableContext<ScannerView>) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completionHandler)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([String]?) -> Void

        init(completion: @escaping ([String]?) -> Void) {
            self.completionHandler = completion
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            print("Document camera view controller did finish with ", scan)
            let recognizer = TextRecognizer(cameraScan: scan)
            recognizer.recognizeText(withCompletionHandler: completionHandler)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completionHandler(nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
        }
    }
}

final class TextRecognizer {
    let cameraScan: VNDocumentCameraScan
    init(cameraScan: VNDocumentCameraScan) {
        self.cameraScan = cameraScan
    }
    private let queue = DispatchQueue(label: "scan-codes", qos: .default, attributes: [],
                                      autoreleaseFrequency: .workItem)
    func recognizeText(withCompletionHandler completionHandler: @escaping ([String]) -> Void) {
        queue.async {
            let images = (0..<self.cameraScan.pageCount).compactMap({
                self.cameraScan.imageOfPage(at: $0).cgImage
            })
            let imagesAndRequests = images.map({(image: $0, request: VNRecognizeTextRequest())})
            let textPerPage = imagesAndRequests.map { image, request -> String in
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                    guard let observations = request.results else {return ""}
                    let result = observations.compactMap({$0.topCandidates(1).first?.string}).joined(separator: "\t")
                    return TextGeneratorViewModel.shared.formatToCodeIfNecessary(from: result)
                } catch {
                    print(error)
                    return ""
                }
            }
            DispatchQueue.main.async {
                completionHandler(textPerPage)
            }
        }
    }

    static func recognizeText(fromImage image: UIImage,
                              withCompletionHandler completionHandler: @escaping ([String]) -> Void) {
        var texts = [String]()
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!)
        let recogniseTextRequest = VNRecognizeTextRequest {(request, _) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            for observation in observations {
                let recognizedText = observation.topCandidates(1).first!.string
                texts.append(recognizedText)
            }
            completionHandler(texts)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([recogniseTextRequest])
            } catch {
                print(error)
            }
        }
    }
}

struct ScanData: Identifiable {
    var id = UUID()
    let content: String

    init(content: String) {
        self.content = content
    }
}
