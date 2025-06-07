//
//  StoreManger.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 5.06.2025.
//

import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    @Published var products: [SKProduct] = []

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func refreshReceiptIfNeededAndSend() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            print("📥 Receipt not found, refreshing...")
            let refreshRequest = SKReceiptRefreshRequest()
            refreshRequest.delegate = self
            refreshRequest.start()
            return
        }

        sendReceiptToBackend()
    }

    func requestDidFinish(_ request: SKRequest) {
        print("✅ Receipt refresh completed")

        // Receipt refresh bitti → receipt'ı gönder
        sendReceiptToBackend()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ Receipt refresh failed: \(error.localizedDescription)")
    }


    func fetchProducts() {
        let productIDs: Set<String> = ["com.synapseai.credits100"]
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("📦 Products received: \(response.products.count)")
        print("❌ Invalid products: \(response.invalidProductIdentifiers)")
        
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                refreshReceiptIfNeededAndSend()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    func sendReceiptToBackend() {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                 let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
               print("❌ No receipt found")
               return
           }

           let receiptString = receiptData.base64EncodedString()
        
        FetchService().executeRequest(url: "/payments/validate-apple", method: "POST", data: ["receipt": receiptString]) {
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
        }
    }
}
