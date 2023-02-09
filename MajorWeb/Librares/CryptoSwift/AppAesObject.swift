//
//  AppAesTest.swift
//  MajorWeb
//
//  Created by zengbiwang on 2018/11/30.
//  Copyright © 2018 cxh. All rights reserved.
//

import Foundation

//AES256
@objc class AppAesObject: NSObject {
    @objc(DecryptDes:data:)
      class  func DecryptDes(key:String,data:NSData)->String{
        var encrypted: [UInt8] = []
        let count = data.length
        // 把data 转成byte数组
        for i in 0..<count {
            var temp:UInt8 = 0
            data.getBytes(&temp, range: NSRange(location: i,length:1 ))
            encrypted.append(temp)
        }
        
       // var aesKey = key.bytes;
//AES(
        //let aes = AES(
        
        let aes = try! AES(key: Padding.pkcs7.add(to: key.bytes, blockSize: AES.blockSize),
                          blockMode: ECB())
        let decrypted = try! aes.decrypt(encrypted)
        let encoded = Data(decrypted)
        let str = String(bytes: encoded.bytes, encoding: .utf8)!
       return  str;
    }
}
