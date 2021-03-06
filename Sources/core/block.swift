//    MIT License
//
//    Copyright (c) 2018 Veldspar Team
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
    public var height: UInt32
    public var hash: String?
    public var confirms: UInt64 = 0
    public var shenanigans: UInt64 = 0

    // block contents
    public var oreSeed: String?
    public var transactions: [Ledger] = []
    
    // initializer
    public init(height: UInt32) {
        self.height = height
    }
        
    public func GenerateHashForBlock(previousHash: String) -> String {
        
        // the hash is based on, the previous hash or "" for the genesis and all of the transaction summary data
        var data = "\(self.height)\(previousHash)\(self.height)"
        for t in self.transactions {
            data += "\(t.transaction_id)\(t.block)\(t.checksum())\(t.date)\(t.op.rawValue))\(t.destination)\(t.token)\(t.spend_auth)\(t.transaction_group)"
        }
        
        return data.CryptoHash()
        
    }
    
}
