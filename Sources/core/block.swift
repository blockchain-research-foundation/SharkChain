//    MIT License
//
//    Copyright (c) 2018 SharkChain Team
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import CryptoSwift

public class Block {
    
    // block variables
    public var height: UInt64
    public var hash: String?

    // block contents
    public var oreSeed: String?
    public var transactions: [Ledger] = []
    
    // initializer
    public init(height: UInt64) {
        self.height = height
    }
    
    public func LatestTimestamp() -> UInt64 {
        
        var latest: UInt64 = 0
        
        for t in transactions {
            if t.date ?? 0 > latest {
                latest = t.date ?? 0
            }
        }
        
        return 0
        
    }
    
    public func GenerateHashForBlock(previousHash: String) -> String {
        
        // the hash is based on, the previous hash or "" for the genesis and all of the transaction summary data
        var data = "\(self.height)\(previousHash)\(self.height)"
        for t in self.transactions {
            data += "\(t.block ?? 0)\(t.checksum ?? "")\(t.date ?? 0)\(t.op ?? 0)\(t.owner ?? "")\(t.token ?? "")\(t.transaction ?? "")"
        }
        
        return data.sha224()
        
    }
    
}
