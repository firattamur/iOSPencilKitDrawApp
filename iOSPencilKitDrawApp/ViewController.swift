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
    
    private let canvasWidth: CGFloat = 768
    private let canvasOverScrollHight: CGFloat = 500

    private var toolPicker : PKToolPicker!
    
    private var undoBarButton : UIButton = {
        
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        barButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        barButton.translatesAutoresizingMaskIntoConstraints = false

        return barButton
        
    }()

    private var redoBarButton : UIButton = {
        
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "arrowshape.turn.up.forward"), for: .normal)
        barButton.addTarget(self, action: #selector(redo), for: .touchUpInside)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        
        return barButton
        
    }()
        
    var drawing = PKDrawing()
    
    @IBOutlet weak var canvasView: PKCanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setup top tools bar
        self.setupNavigationCenterButtons()
        
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
    
    @objc private func undo() {
        
        
    }
    
    @objc private func redo() {
        
        
    }
    
    private func setupNavigationCenterButtons() {
        
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        stackView.addArrangedSubview(self.undoBarButton)
        stackView.addArrangedSubview(self.redoBarButton)
        
        self.navigationItem.titleView = stackView

    }
    
    @IBAction func pencilBarAction(_ sender: Any) {
        
        canvasView.allowsFingerDrawing.toggle()
        pencilBarButton.title = canvasView.allowsFingerDrawing ? "Scroll" : "Draw"
        
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

