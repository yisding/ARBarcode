//
//  SwiftUIView.swift
//  ARBarcode
//
//  Created by Yi Ding on 7/13/21.
//

import SwiftUI

struct ScannedRecords: View {
    @Binding var scannedBarcodes: [ Barcode ]

    var body: some View {
        VStack {
            Text("Scanned Barcodes")
            List {
                ForEach(scannedBarcodes) { barcode in
                    Text("\(barcode.barcodeString)")
                }
            }
            Text("\(scannedBarcodes.count)")
        }
    }
}

struct ScannedRecords_Previews: PreviewProvider {
    @State static var scannedBarcodes: [ Barcode ] = []
    
    static var previews: some View {
        ScannedRecords(scannedBarcodes: $scannedBarcodes)
    }
}
