//
//  FillAspectImage.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import SwiftUI
import Kingfisher

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func pixelData() -> [Int]? {
            guard let cgImage = self.cgImage else { return nil }
            
            let width = cgImage.width
            let height = cgImage.height
            let bitsPerComponent = 8
            let bytesPerRow = width * 4 // Assuming 4 bytes per pixel (RGBA)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var pixelData = [Int](repeating: 0, count: width * height)
            
            guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
                return nil
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            return pixelData
        }
}

public struct FillAspectImage: View {
    let url: URL?
    
    @State private var finishedLoading: Bool = false
    @State private var imageWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var animLeft: Bool = false
    @Binding var color: UIColor?
    
    public init(url: URL?, doesAnimateHorizontal: Bool, color: Binding<UIColor?>) {
        self.url = url
        self._color = color
    }
    
    func convertDictionaryToColorList(_ dictionary: [Int: Int]) -> [Color] {
        return dictionary.map { (colorValue, _) in
            let hexString = String(format: "#%06X", colorValue & 0xFFFFFF)
            print(hexString)
            return Color(hex: hexString)
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            KFImage.url(url)
                .onSuccess { image in
                    finishedLoading = true
                    print(image.image.averageColor)
                    color = image.image.averageColor
                    
                    /*
                    let pixels = image.image.pixelData()
                    if let pixels {
                        let result = QuantizerCelebi().quantize(pixels, 20)
                        
                        // 0 -> almost black
                        // 1 -> primary
                        // 2 -> Tertiary?
                        // 3 -> Secondary?
                        // 4 -> idk
                        // 5 ->
                        
                        color = UIColor(convertDictionaryToColorList(result.colorToCount)[10])
                        //print(color)
                    }
                     */
                }
                .onFailure { _ in
                    finishedLoading = true
                }
                .resizable()
                .scaledToFill()
                .transition(.opacity)
                .opacity(finishedLoading ? 1.0 : 0.0)
                .background(Color(white: 0.05))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .clipped()
                .animation(.easeInOut(duration: 0.5), value: finishedLoading)
        }
    }
}

struct FillAspectImage_Previews: PreviewProvider {
    static var previews: some View {
        FillAspectImage(url: URL(string: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/98659-u46B5RCNl9il.jpg"), doesAnimateHorizontal: true, color: .constant(nil))
            .frame(height: 400)
    }
}

