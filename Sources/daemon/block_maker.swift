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
import VeldsparCore

// this class is a background thread which constantly monitors the time, and creates new blocks when required, checks quorum, and queries other nodes to make sure we posess all of the transactions and none are missed.

class BlockMaker {
    
    class func Loop() {
        
        while true {
            
            let currentTime = consensusTime()
            if UInt64(currentTime) > UInt64(Config.BlockchainStartDate) {
                
                // get the current height, and work out which block should be created and when
                let currentHeight = blockchain.height()
                
                let blockHeightForTime = ((currentTime - UInt64(Config.BlockchainStartDate)) / UInt64(Config.BlockTime * 1000))
                
                if (blockHeightForTime - UInt64(currentHeight)) > 1 {
                    
                    // we are significantly behind
                    
                    // TODO:  Canvas the list of peers to get their transactions, then merge the results and write them into the pending table.
                    
                }
                
                if currentHeight < blockHeightForTime {
                    
                    for index in Int(currentHeight+1)...Int(blockHeightForTime) {
                        
                        // produce the block, hash it, seek quorum, then write it
                        let previousBlock = blockchain.blockAtHeight(UInt32(index-1))
                        let newBlock = Block(height: UInt32(index))
                        
                        // query the pending table for this target block height
                        let ledgers = blockchain.pendingLedgersForBlock(UInt32(index))
                        
                        for l in ledgers {
                            newBlock.transactions.append(l)
                            blockchain.aggregateStatsForLedger(l)
                        }
                        
                        newBlock.hash = newBlock.GenerateHashForBlock(previousHash: previousBlock?.hash ?? "")
                        
                        //TODO: call out to other nodes and wait for their hash results to come back, then set the confirms
                        
                        if !blockchain.addBlock(newBlock) {
                            break;
                        }
                        
                        
                    }
                    
                    // update the global stats
                    blockchain.setAddressCount(addressCount: blockchain.countOfAddresses(), blockCount: Int(blockchain.height()))
                    
                }
                
            }
            
            Thread.sleep(forTimeInterval: 5)

            
        }
        
    }
    
}
