//
//  ViewController.swift
//  Projects25-27MS_100days
//
//  Created by user228564 on 4/10/23.
//

import UIKit

enum Position {
    case top
    case bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imageView = UIImageView()
    
    let button = UIButton()
    
    var topCaption: String?
    var bottomCaption: String?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        //imageView.image = UIImage(named: "myImage")
        view.addSubview(imageView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportAction))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importAction))
        
        button.frame = CGRect(x: 0, y: view.bounds.height - 80, width: view.bounds.width, height: 80)
        button.backgroundColor = .systemMint
        button.setTitle("Add caption", for: .normal)
        button.addTarget(self, action: #selector(addCaption), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    @objc func exportAction() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else { return }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    @objc func importAction() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        imageView.image = image

        self.image = image
        topCaption = nil
        bottomCaption = nil
        
        //updateButtonsState(enable: true)
    }
    
    @objc func addCaption() {
            let alertController = UIAlertController(title: "Enter Caption", message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "Top caption"
            }
            alertController.addTextField { textField in
                textField.placeholder = "Bottom caption"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let applyAction = UIAlertAction(title: "Apply", style: .default) { _ in
                guard let topCap = alertController.textFields?[0].text,
                      let bottomCap = alertController.textFields?[1].text else {
                    return
                }
                self.addTwoCaptions(topCap: topCap, bottomCap: bottomCap)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(applyAction)

            present(alertController, animated: true, completion: nil)
        }
    

    
    func addTwoCaptions(topCap: String, bottomCap: String) {
        guard let image = image else { return }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            drawText(text: topCap, position: .top, rendererSize: image.size)
            drawText(text: bottomCap, position: .bottom, rendererSize: image.size)
            
        }

        imageView.image = renderedImage
    }
    
    func drawText(text: String, position: Position, rendererSize: CGSize) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // accomodate all images sizes
        let sidesLength = rendererSize.width + rendererSize.height
        let fontSize = sidesLength / 20
        
        let attrs: [NSAttributedString.Key : Any] = [
            .strokeWidth: -3.0,
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)!,
            .paragraphStyle: paragraphStyle
        ]
        
        let margin = 32
        let textWidth = Int(rendererSize.width) - (margin * 2)
        let textHeight = computeTextHeight(for: text, attributes: attrs, width: textWidth)
        
        var startY: Int
        switch position {
        case .top:
            startY = margin
        case .bottom:
            startY = Int(rendererSize.height) - (textHeight + margin)
        }
        
        text.draw(with: CGRect(x: margin, y: startY, width: textWidth, height: textHeight), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    func computeTextHeight(for text: String, attributes: [NSAttributedString.Key : Any], width: Int) -> Int {
        let nsText = NSString(string: text)
        let size = CGSize(width: CGFloat(width), height: .greatestFiniteMagnitude)
        let textRect = nsText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return Int(ceil(textRect.size.height))
    }
}

