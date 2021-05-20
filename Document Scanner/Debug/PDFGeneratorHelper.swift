//
//  PDGGenerator.swift
//  Document Scanner
//
//  Created by Sandesh on 18/05/21.
//

import UIKit
import TPPDF

struct PDFGeneratorHelper {
    
    
    static func generatePDF(for document: Document) -> Data {
        let pdfDocument = PDFDocument(format: PDFPageFormat.a4)
         
        for index in 0 ..< document.pages.count {
            let page = document.pages[index]
            let pdfImage = PDFImage(image: page.editedImage!)
            pdfDocument.add(.contentCenter, image: pdfImage)
            if index != document.pages.count - 1 {
                pdfDocument.createNewPage()
            }
        }
        
        let generator = PDFGenerator(document: pdfDocument)
        
        guard let pdfDocumentURL = try? generator.generateURL(filename: document.name),
              let data = try? Data(contentsOf: pdfDocumentURL) else {
            fatalError("Unable to generate PDF file")
        }
        return data
    }
}

