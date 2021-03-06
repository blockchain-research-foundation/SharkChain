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
import Foundation
import PerfectHTTP
import VeldsparCore

let banLock: Mutex = Mutex()
var bans: [String:Int] = [:]

enum RPCErrors : Error {
    case InvalidRequest
    case DuplicateRequest
    case Banned
}

func handleRequest() throws -> RequestHandler {
    return {
        
        request, response in
        
        let body = request.postBodyString ?? ""
        var json: JSON = JSON.null
        if body != "" {
            json = try! JSON(data: body.data(using: .utf8, allowLossyConversion: false)!)
        }
        let payload = json.dictionaryObject
        
        debug("RPC request '\(request.path)' received")
        if request.queryParams.count > 0 {
            for p in request.queryParams {
                debug("RPC request query parameters '\(p.0)' = '\(p.1)'")
            }
        }
        
        response.setHeader(.contentType, value: "application/json")
        response.setHeader(.accessControlAllowOrigin, value: "*")
        response.setHeader(.accessControlAllowMethods, value: "GET, POST, PATCH, PUT, DELETE, OPTIONS")
        response.setHeader(.accessControlAllowHeaders, value: "Origin, Content-Type, X-Auth-Token")
        
        if request.method == .get {
            
            do {
                
                if request.path == "/" {
                    try response.setBody(json: ["Server" : "\(Config.CurrencyName) Node", "version" : "\(Config.Version)"])
                }
                
                if request.path == "/info/timestamp" {
                    try response.setBody(json: ["timestamp" : consensusTime()])
                }
                
                if request.path == "/blockchain/currentheight" {
                    try response.setBody(json: ["height" : blockchain.height()])
                }
                
                if request.path == "/blockchain/seeds" {
                    let encodedData = try String(bytes: JSONEncoder().encode(RPCOreSeeds.action()), encoding: .ascii)
                    response.setBody(string: encodedData!)
                }
                
                if request.path == "/blockchain/stats" {
                    response.setBody(string: RPCStats.action())
                }
                
                if request.path == "/blockchain/block" {
                    
                    // query the ledger at a specific height, and return the transactions.  Used for wallet implementations
                    var height = 0
                    for p in request.queryParams {
                        if p.0 == "height" {
                            height = Int(p.1) ?? 0
                        }
                    }
                    
                    let encodedData = try String(bytes: JSONEncoder().encode(RPCGetBlock.action(height)), encoding: .ascii)
                    response.setBody(string: encodedData!)
                    
                    
                }
                
                if request.path == "/wallet/sync" {
                    
                    // query the ledger at a specific height, and return the transactions.  Used for wallet implementations
                    var height = 0
                    var address = ""
                    for p in request.queryParams {
                        if p.0 == "height" {
                            height = Int(p.1) ?? 0
                        }
                        if p.0 == "address" {
                            address = p.1
                        }
                    }
                    
                    let encodedData = try String(bytes: JSONEncoder().encode(RPCSyncWallet.action(address: address, height: height)), encoding: .ascii)
                    response.setBody(string: encodedData!)
                    
                    
                }
                
                if request.path == "/token/register" {
                    
                    var token = ""
                    var address = ""
                    for p in request.queryParams {
                        if p.0 == "token" {
                            token = p.1
                        }
                        if p.0 == "address" {
                            address = p.1
                        }
                    }
                    
                    try response.setBody(json: RPCRegisterToken.action(["token" : token, "address" : address], host: request.remoteAddress.host))
                }
                
            } catch RPCErrors.Banned {
                
                response.status = .forbidden
                
            } catch {
                
                debug("(handleRequest) call to RPCServer caused an exception.")
                
            }
            
            
            
        } else if request.method == .post {
            
            do {
                
                if payload != nil {
                    
                    if request.path == "/token/register" {
                        try response.setBody(json: RPCRegisterToken.action(payload!, host: request.remoteAddress.host))
                    }
                    
                    if request.path == "/token/transfer" {
                        try response.setBody(json: RPCTransferToken.action(payload!))
                    }
                    
                } else {
                    
                    
                }
                
            } catch RPCErrors.DuplicateRequest {
                
                
                
            } catch RPCErrors.InvalidRequest {
                
                
                
            } catch {
                
                
                
            }
            
        }
        
        response.completed()
    }
}
