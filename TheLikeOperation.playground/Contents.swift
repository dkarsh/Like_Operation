import SwiftUI
import PlaygroundSupport
import Foundation

open class AsynchronousOperation: Operation {
    public override var isAsynchronous: Bool {
        return false
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    open override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
        }
    }
    
    public func finish() {
        state = .finished
    }
    
    // MARK: - State management
    
    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    /// Thread-safe computed state value
    public var state: State {
        get {
            stateQueue.sync {
                return stateStore
            }
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                stateStore = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    private let stateQueue = DispatchQueue(label: "AsynchronousOperation State Queue", attributes: .concurrent)
    /// Non thread-safe state storage, use only with locks
    private var stateStore: State = .ready
}

class LikeOperation : AsynchronousOperation {
    
    let like:Bool
    let id:Int
    
    init(_ like:Bool, id:Int) {
        self.like = like
        self.id  = id
        super.init()
    }
    
    override func main() {
        super.main()
        let txt = like ? "Like" : "Dislike"
        print("Operation \(self.id) - \(txt) - API call sent")
        let secondsToDelay = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            print("Operation \(self.id) - \(txt) - API call respond")
            self.finish()
        }
    }
}

struct ContentView: View {
    @State private var showDetails = false
    let queue = OperationQueue()
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





