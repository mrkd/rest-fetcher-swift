import Foundation
import SwiftyJSON


public class RestApiBaseRequest<T: RestApiBaseResponse> {
    
        private var _cancel = false
        private var _restFetcher : RestFetcher?
        public var restFetcherBuilder : RestFetcherBuilder
        
        var successCallback : (response:T)->() = {(response: RestApiBaseResponse)->()in}
        var errorCallback : (error:RestError)->() = {(error:RestError)->()in}
        
        public init(successCallback:(response:T)->(), errorCallback:(error:RestError)->()) {
            self.successCallback = successCallback
            self.errorCallback = errorCallback
            self.restFetcherBuilder = RestFetcher.Builder()
        }
    
        public func setRestFetcherBuilder(restFetcherBuilder: RestFetcherBuilder) {
            self.restFetcherBuilder = restFetcherBuilder
        }
    
        public func getRestMethod() -> RestMethod {
            return RestMethod.GET
        }
        
        public func getApiResource() -> String {
            return "http://google.com"
        }
        
        public func getBody() -> String {
            let bodyDict = getBodyDict()
            if bodyDict.count == 0 {
                return ""
            }
            let bodyJson = JSON(bodyDict)
            if let output = bodyJson.rawString() {
                var value = output.stringByReplacingOccurrencesOfString("\n", withString: "")
                value = value.stringByReplacingOccurrencesOfString(" ", withString: "")
                return value
            }
            return "" // will never be hit in this code
        }
    
        public func getBodyDict() -> Dictionary<String, AnyObject> {
            return Dictionary<String, AnyObject>()
        }

        
        public func getHeaders() -> Dictionary<String, String> {
            var headers = Dictionary<String,String>()
            headers["Accept"] = "application/json; version=1"
            headers["Content-Type"] = "application/json; charset=utf-8"
            return headers
        }
    
        func createResponse(response:RestResponse) -> T {
            return RestApiBaseResponse(response: response) as! T
        }
        
        func restFetcherSuccess(response:RestResponse) {
            if !_cancel {
                successCallback(response: createResponse(response))
            }
        }
        
        func restFetcherError(error:RestError) {
            if !_cancel {
                errorCallback(error: error)
            }
        }
        
        public func prepare() {
            _restFetcher = restFetcherBuilder.createRestFetcher(getApiResource(), method: getRestMethod(), headers: getHeaders(), body: getBody(), successCallback: restFetcherSuccess, errorCallback: restFetcherError)
        }
        
        public func fetch() {
            if let fetcher = _restFetcher {
                fetcher.fetch()
            } else {
                prepare()
                fetch()
            }
        }
        
        public func cancel() {
            _cancel = true
        }
    }
    
    public class RestApiBaseResponse {
        
        private var _code : RestResponseCode = RestResponseCode.UNKNOWN
        public let response : RestResponse!
        var code: RestResponseCode {
            get {
                return _code
            }
        }
        
        public init(response:RestResponse) {
            self.response = response
            processResponse(response)
        }
        
        internal func processResponse(response:RestResponse) {
            _code = response.code
        }
    }
