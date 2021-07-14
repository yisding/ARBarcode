//
//  ARViewContainer.swift
//  ARBarcode
//
//  Created by Yi Ding on 7/13/21.
//

import SwiftUI
import RealityKit
import Vision
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var scannedBarcodes: [ Barcode ]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

//        arView.debugOptions.insert([.showAnchorGeometry, .showAnchorOrigins, .showWorldOrigin])
        // Comment out these two lines if running on Simulator/SwiftUI Preview
        arView.session.delegate = context.coordinator
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        for i in scannedBarcodes.indices {
            let barcode = scannedBarcodes[i]
            if !barcode.placed, let raycastQuery = barcode.raycastQuery {
//                print("Trying to raycast")
                guard let raycastResult = uiView.session.raycast(raycastQuery).first else {
//                    print("No results")
                    scannedBarcodes[i].raycastQuery = nil
                    continue
                }
//                print("Raycast result transform: \(raycastResult.worldTransform)")
                let anchorEntity = AnchorEntity(world: raycastResult.worldTransform)
                let mesh = MeshResource.generateBox(width: 0.05, height: 0.002, depth: 0.02)
                let material = SimpleMaterial(color: .green, roughness: 0, isMetallic: false)
                let modelEntity = ModelEntity(mesh: mesh, materials: [material])
                anchorEntity.addChild(modelEntity)
                uiView.scene.anchors.append(anchorEntity)
//                print("Placed box!")
                scannedBarcodes[i].placed = true
            }
        }
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = VNDetectBarcodesRequest(completionHandler: self.handleDetectedBarcodes)
        var detectionInFlight = false
        var detectionFrame: ARFrame? = nil
        
        init(_ arViewContainer: ARViewContainer) {
            parent = arViewContainer
//            barcodeDetectionRequest.symbologies = [.UPCE] // We can set specific symbologies if we want
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
//            print("Got frame! camera transform: \(frame.camera.transform) eulerAngles: \(frame.camera.eulerAngles)" )
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if (self.detectionInFlight) {
                        return
                    } else {
                        self.detectionInFlight = true
                        self.detectionFrame = frame
                        // .right matches human orientation in vertical screen, but we need .up for raycasting.
                        let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .up, options: [:])
                        try requestHandler.perform([self.barcodeDetectionRequest])
                    }
                } catch {
                    print("Caught error from initiating detection request")
                }
            }
        }
        
        func handleDetectedBarcodes(request: VNRequest, error: Error?) {
//            print("handleDetectedBarcodes called")
            if let results = request.results {
                // TODO sometimes the barcode scanner finds multiple barcodes that
                // are actually the same one.
                // Right now we'll just ignore all but the first time we see a barcode, but in the future
                // we need to figure out how to combine multiple observations of the same barcode.
                // This also means that if we currently see the same barcode multiple times we won't be able
                // to recognize it. Next step would be to do some kind of ray tracing test to see if two
                // observations are indeed the same barcode or different barcodes.
                for r in results {
                    if let result = r as? VNBarcodeObservation {
                        var alreadyFound = false
                        if let payloadStringValue = result.payloadStringValue {
                            for barcode in self.parent.scannedBarcodes {
                                if barcode.barcodeString == payloadStringValue && barcode.placed {
                                    alreadyFound = true
                                }
                            }
                            
                            if !alreadyFound {
//                                // The y values here are inverted.
                                let center = CGPoint(x: result.boundingBox.midX, y: 1 - result.boundingBox.midY)
                                print("Midpoint: \(center)")
                                let query = self.detectionFrame?.raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
                                var alreadyInArray = false
                                for i in self.parent.scannedBarcodes.indices {
                                    if self.parent.scannedBarcodes[i].barcodeString == payloadStringValue {
                                        self.parent.scannedBarcodes[i].raycastQuery = query!
                                        alreadyInArray = true
                                        break
                                    }
                                }
                                
                                if !alreadyInArray {
                                    self.parent.scannedBarcodes.append(Barcode(barcodeString: payloadStringValue, raycastQuery: query!, placed: false))
                                }
                            }
                        }
                    }
                }
//                if results.count > 0 {
//                    print("Got this many results: \(results.count)")
//                }
                self.detectionInFlight = false
            } else {
                self.detectionInFlight = false
            }
        }
    }
}
    
