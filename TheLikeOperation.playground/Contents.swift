import SwiftUI
import PlaygroundSupport
import Foundation

public enum OperationState: Int {
    case ready
    case executing
    case finished
}


open class TSUOperation: Operation {
    
    public var state: OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    open override var isExecuting: Bool {
        return state == .executing
    }
    
    open override var isFinished: Bool {
        return state == .finished
    }
    
    open override var isReady: Bool {
        return state == .ready
    }
    
    open override var isAsynchronous: Bool {
        return true
    }
    
}


class LikeOperation : TSUOperation {
    
    let like:Bool
    let id:Int
    
    init(_ like:Bool, id:Int) {
        self.like = like
        self.id  = id
        super.init()
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        let txt = like ? "Like" : "Dislike"
        print("Operation \(self.id) - \(txt) - API call sent")
        let secondsToDelay = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            print("Operation \(self.id) - \(txt) - API call response")
            self.state = .finished
        }
    }
}

var queue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
}()

struct ContentView: View {
    @State private var showDetails = false
    @State var index = 1
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(!index.isMultiple(of: 2) ? "   Like   " : " Dislike ") {
                
                print ("tapped \(index) times")
                
                let operation = LikeOperation(!index.isMultiple(of: 2), id:index)
                var lastAPICall: Bool?
                
                
                if let last = queue.operations.last{
                    queue.isSuspended = true
                    operation.addDependency(last)
                }
                
                operation.completionBlock = { [operation] in
                    
                    var allOp = queue.operations
                    var lastInArray: LikeOperation?
                    
                    let txt = operation.isCancelled ? "got cancelled" : "successfully completed"
                    print ("operation \(operation.id) \(txt)")
                    
                    if !operation.isCancelled {
                        lastAPICall = operation.like
                    }
                    
                    if allOp.count > 0 {
                        lastInArray = allOp.removeLast() as? LikeOperation
                    }
                    
                    allOp.forEach { op in
                        op.cancel()
                    }
                    
                    if let thelast = lastInArray, thelast.like == lastAPICall {
                        thelast.cancel()
                    }
                    
                    queue.isSuspended = false
                }
                
                queue.addOperation(operation)
                
                index = index + 1
                
            }
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())





