//
//  PDFViewController.swift
//  REroot
//
//  Created by Dhanunjay on 03/06/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
class PDFViewController: UIViewController {

    var pdfView = PDFView()
    var pdfURL: URL!
    
    override func viewDidLayoutSubviews() {
        pdfView.frame = view.frame
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.downloadButtonPressed(UIButton())
    }
    func openPDF(){

        view.addSubview(pdfView)

        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func downloadButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://buildez.s3.ap-south-1.amazonaws.com/reroot/downloads/1559554111679844.pdf") else { return }

        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())

        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
@available(iOS 11.0, *)
extension PDFViewController:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)

        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            self.pdfURL = destinationURL
            print(self.pdfURL!)
            DispatchQueue.main.async {
                self.openPDF()
            }
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
}
