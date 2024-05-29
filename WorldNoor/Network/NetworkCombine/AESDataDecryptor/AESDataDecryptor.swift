//
//  CollectionReusableView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//
import Foundation
import CommonCrypto


class AESDataDecryptor {
    
    static func decryptAESData(encryptedHexString: String, completion: @escaping (String?)->Void){
        let encryptionKey = "6fea2c60ed4f4415af0c31e5386a960679998d6f7b08adcecb0c35844a385509"
        let initializationVector = "011c1469aecac04781eb43121adbf159"
        
        guard let keyData = hexStringToData(hexString: encryptionKey),
              let ivData = hexStringToData(hexString: initializationVector),
              let encryptedData = hexStringToData(hexString: encryptedHexString) else {
            return completion(nil)
        }
        
        var decryptedData: Data?
        
        encryptedData.withUnsafeBytes { encryptedBytes in
            keyData.withUnsafeBytes { keyBytes in
                ivData.withUnsafeBytes { ivBytes in
                    let keyLength = size_t(kCCKeySizeAES256)
                    var decryptedBytes = [UInt8](repeating: 0, count: encryptedData.count + kCCBlockSizeAES128)
                    
                    var numBytesDecrypted = 0
                    let cryptStatus = CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress,
                        keyLength,
                        ivBytes.baseAddress,
                        encryptedBytes.baseAddress,
                        encryptedData.count,
                        &decryptedBytes,
                        decryptedBytes.count,
                        &numBytesDecrypted
                    )
                    
                    if cryptStatus == kCCSuccess {
                        decryptedData = Data(bytes: decryptedBytes, count: numBytesDecrypted)
                    }
                }
            }
        }
        completion(String(data: decryptedData ?? Data(), encoding: .utf8))
    }
    
    private static func hexStringToData(hexString: String) -> Data? {
        var hex = hexString
        var data = Data()
        
        while(hex.count > 0) {
            let index = hex.index(hex.startIndex, offsetBy: 2)
            let hexByte = String(hex[..<index])
            hex = String(hex[index...])
            
            if var num = UInt8(hexByte, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data
    }
}
