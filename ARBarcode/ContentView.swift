//
//  ContentView.swift
//  ARBarcode
//
//  Created by Yi Ding on 7/13/21.
//

import SwiftUI
import RealityKit
import Vision
import ARKit

struct ContentView: View {
    @State var scannedBarcodes: [ Barcode ] = []
//        Barcode(barcodeString: "ABCDEFG"),
//        Barcode(barcodeString: "HIJKLMN")
    
    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
//            Text("Hello").tabItem { Text("Hello" )}.tag(1)
            ARViewContainer(scannedBarcodes: $scannedBarcodes).edgesIgnoringSafeArea(.all).tabItem { Text("Scan Barcodes") }.tag(1)
            ScannedRecords(scannedBarcodes: $scannedBarcodes).tabItem { Text("Already Scanned") }.tag(2)
        }.ignoresSafeArea()
    }
}
    
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
