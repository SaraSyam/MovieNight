import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: String? // Changed to String
    
    private init() {
        monitor = NWPathMonitor()
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied

            if #available(iOS 13.0, *) {
                           if path.usesInterfaceType(.wifi) {
                               self.connectionType = "WiFi"
                           } else if path.usesInterfaceType(.cellular) {
                               self.connectionType = "Cellular"
                           } else if path.usesInterfaceType(.wiredEthernet) {
                               self.connectionType = "Ethernet"
                           } else if path.usesInterfaceType(.loopback) {
                               self.connectionType = "Loopback"
                           } else {
                               self.connectionType = "Other"
                           }
                       } else {
                           // Simplified for older iOS versions (less precise)
                           if path.usesInterfaceType(.wifi) {
                               self.connectionType = "WiFi"
                           } else if path.usesInterfaceType(.cellular) {
                               self.connectionType = "Cellular"
                           } else {
                               self.connectionType = "Unknown" // Could be other types
                           }
                       }
                       print("Connection Status: \(self.isConnected ? "Connected" : "Not Connected"), Type: \(self.connectionType ?? "N/A")")
                   }
               }

               func startMonitoring() {
                   monitor.start(queue: queue)
               }

               func stopMonitoring() {
                   monitor.cancel()
               }
           }
