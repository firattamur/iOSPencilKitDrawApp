//
//  ViewController.swift
//  iOSPencilKitDrawApp
//
//  Created by Firat Tamur on 5/9/21.
//

import UIKit
import PencilKit
import PhotosUI


class ViewController: UIViewController {

    @IBOutlet weak var pencilBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    let canvasWidth: CGFloat = 768
    let canvasOverScrollHight: CGFloat = 500
    
    private var toolPicker : PKToolPicker!
    
    var drawing = PKDrawing()
    
    @IBOutlet weak var canvasView: PKCanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
            
            toolPicker = PKToolPicker.init()
            
        } else {
            // Fallback on earlier versions
            
            canvasView.allowsFingerDrawing = true
            
            if let window = parent?.view.window {
                toolPicker = PKToolPicker.shared(for: window)
            }
            
        }
        
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        canvasView.becomeFirstResponder()
                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
    }
    
    @IBAction func pencilBarAction(_ sender: Any) {
        
        canvasView.allowsFingerDrawing.toggle()
        pencilBarButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
        
    }
    
    @IBAction func cameraBarAction(_ sender: Any) {
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAsset(from: image!)}) { (success, error) in
                
                // deal success case
                
            }
            
        }
        
    }
    
    private func updateContentSizeForDrawing() {
        
        let drawing = canvasView.drawing
        let contentHeight : CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height,
                                (drawing.bounds.maxY + self.canvasOverScrollHight) * canvasView.zoomScale)
        }else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale,
                                        height: contentHeight)
        
    }
    

}

extension ViewController: PKCanvasViewDelegate, PKToolPickerObserver {
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
}

