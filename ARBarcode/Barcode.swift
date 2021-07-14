//
//  Barcode.swift
//  ARBarcode
//
//  Created by Yi Ding on 7/13/21.
//

//import simd
import CoreImage
import ARKit

struct Barcode: Identifiable {
    var id = UUID()
    var barcodeString: String
//    var worldTransform: simd_float4x4
    var raycastQuery: ARRaycastQuery?
    var placed: Bool
}
