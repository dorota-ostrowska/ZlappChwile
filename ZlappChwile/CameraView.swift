//
//  CameraView.swift
//  ZlappChwile
//
//  Created by Dorota Ostrowska on 02/02/2026.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {

                let finalImage: UIImage

                if picker.cameraDevice == .front {
                    // 👀 przednia kamera → lustrzane (jak preview)
                    finalImage = mirrorImage(image)
                } else {
                    // 📷 tylna kamera → normalne
                    finalImage = image
                }

                parent.onImagePicked(finalImage)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }


        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

func mirrorImage(_ image: UIImage) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()!

    context.translateBy(x: image.size.width, y: 0)
    context.scaleBy(x: -1, y: 1)

    image.draw(in: CGRect(origin: .zero, size: image.size))
    let mirrored = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return mirrored ?? image
}

