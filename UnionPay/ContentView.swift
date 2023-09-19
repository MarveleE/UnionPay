//
//  ContentView.swift
//  UnionPay
//
//  Created by grochgen on 2023/8/23.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var url: String = ""

}

struct ContentView: View {

    @EnvironmentObject var viewModel: ViewModel
    @State var text: String = ""

    @State var image: UIImage?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    TextField("tn号", text: $text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding(6)
                        .overlay(
                            Group {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)

                            }
                        )
                    Button {
                        UPPaymentControl.default().startPay(text, fromScheme: "unionpaydemo", mode: "00", viewController: UIViewController())
                    } label: {
                        Text("转换订单号")
                            .padding(.horizontal, 10)
                            .foregroundColor(Color.white)
                            .frame(height: 45)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                if let image {
                    Image(uiImage: image)
                        .frame(width: 200, height: 200)
                }

                TextEditor(text: $viewModel.url)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .overlay(
                        Group {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                    )
                Button {
                    UIPasteboard.general.string = viewModel.url
                } label: {
                    Text("复制跳转连接")
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button {
                    if let url = URL(string: viewModel.url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("打开云闪付")
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

            }
            .padding(.horizontal, 20)
            .onChange(of: viewModel.url) { newValue in
                // 调用示例
                let qrCodeSize = CGSize(width: 200, height: 200)
                if let qrCodeImage = generateQRCode(from: newValue, size: qrCodeSize) {
                    self.image = qrCodeImage
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import CoreImage

func generateQRCode(from string: String, size: CGSize) -> UIImage? {
    let data = string.data(using: .utf8)

    // 创建一个 CIQRCodeGenerator 过滤器
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // 设置纠错级别，这里选择 H

        // 生成 CIImage
        if let ciImage = filter.outputImage {
            let scaleX = size.width / ciImage.extent.size.width
            let scaleY = size.height / ciImage.extent.size.height

            // 对 CIImage 进行缩放
            let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            // 将 CIImage 转换成 UIImage
            if let cgImage = CIContext().createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
    }

    return nil
}
