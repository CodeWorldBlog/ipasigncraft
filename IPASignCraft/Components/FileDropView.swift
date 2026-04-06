//
//  FileDropView.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 17/03/26.
//

import SwiftUI

struct FileDropView: View {
    let title: String
    @Binding var filePath: String
    
    var body: some View {

        VStack {
            Text(title)
            Text(filePath.isEmpty ? "Drop file here" : filePath)
                .font(.caption)
                .foregroundColor(.secondary)
            FilePickerView(title: self.title, supportedTypes: [".ipa"], filePath: $filePath)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in

            providers.first?.loadItem(forTypeIdentifier: "public.file-url",
                                      options: nil) { data, _ in
                DispatchQueue.main.async {

                    if let data = data as? Data,
                       let url = URL(dataRepresentation: data,
                                     relativeTo: nil) {

                        filePath = url.path
                    }
                }
            }

            return true
        }
    }
}

#Preview {
    FileDropView(
        title: "FileDropView",
        filePath: .constant("/path/to/file.ipa")
    )
}
