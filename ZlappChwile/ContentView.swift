import SwiftUI
import UIKit
import Photos

struct ContentView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var framedImage: UIImage?

    var body: some View {
        VStack(spacing: 40) {

            // 🟢 EKRAN STARTOWY
            if framedImage == nil {

                Text("Złapp Chwilę 📸")
                    .font(.largeTitle)
                    .bold()

                Button("Zrób zdjęcie") {
                    showCamera = true
                }
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            }

            // 📸 EKRAN PO ZDJĘCIU
            if let image = framedImage {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)

                HStack(spacing: 20) {

                    Button("Powtórz") {
                        framedImage = nil
                        capturedImage = nil
                        showCamera = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)

                    Button("Drukuj") {
                        printImage()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }

        .sheet(isPresented: $showCamera) {
            CameraView { image in
                let framed = applyFrame(to: image)

                framedImage = framed
                saveToGallery(image: framed)
            }
        }
    }
    @MainActor
    func printImage() {
        guard let image = framedImage else { return }

        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "Zdjęcie weselne"
        printInfo.orientation = .portrait

        printController.printInfo = printInfo
        printController.printingItem = image
        printController.showsNumberOfCopies = true
        
        printController.present(animated: true) { controller, completed, error in
            if completed {
                showPrintSuccessAlert()
            }
        }
    }
}


@MainActor
func saveToGallery(image: UIImage) {
    PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized || status == .limited {
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}


@MainActor
func applyFrame(to image: UIImage) -> UIImage {
    guard let frame = UIImage(named: "weddingFrame") else {
        return image
    }

    let canvasSize = CGSize(width: 1200, height: 1800)

    let renderer = UIGraphicsImageRenderer(size: canvasSize)
    return renderer.image { _ in

        // 🔢 obliczamy skalę aspectFill
        let imageRatio = image.size.width / image.size.height
        let canvasRatio = canvasSize.width / canvasSize.height

        var drawRect: CGRect

        if imageRatio > canvasRatio {
            // zdjęcie za szerokie → przycinamy boki
            let height = canvasSize.height
            let width = height * imageRatio
            let x = (canvasSize.width - width) / 2
            drawRect = CGRect(x: x, y: 0, width: width, height: height)
        } else {
            // zdjęcie za wysokie → przycinamy górę/dół
            let width = canvasSize.width
            let height = width / imageRatio
            let y = (canvasSize.height - height) / 2
            drawRect = CGRect(x: 0, y: y, width: width, height: height)
        }

        // 📸 rysujemy zdjęcie BEZ rozciągania
        image.draw(in: drawRect)

        // 🖼️ rysujemy ramkę na wierzchu
        frame.draw(in: CGRect(origin: .zero, size: canvasSize))
    }
}

@MainActor
func showPrintSuccessAlert() {
    let alert = UIAlertController(
        title: "Świetnie! 📸",
        message: "Pamiętaj, żeby wywołać zdjęcie, wkleić je do księgi gości (obok) i napisać nam coś miłego ❤️",
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "OK", style: .default))

    UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?
        .rootViewController?
        .present(alert, animated: true)
}

