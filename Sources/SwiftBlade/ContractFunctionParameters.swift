import WebKit
import BigInt

public class ContractFunctionParameters: NSObject {
    private var params: [ContractFunctionParameter] = []

    public func addAddress(value: String) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "address", value: [value]));
        return self;
    }

    public func addAddressArray(value: [String]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "address[]", value: value));
        return self;
    }

    public func addBytes32(value: [UInt8]) -> ContractFunctionParameters {
        do {
            let encodedValue = try JSONEncoder().encode(value).base64EncodedString();
            params.append(ContractFunctionParameter(type: "bytes32", value: [encodedValue]));
        } catch let error {
            print(error)
        }
        return self
    }

    public func addUInt8(value: UInt8) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint8", value: [String(value)]));
        return self
    }

    public func addUInt64(value: UInt64) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint64", value: [String(value)]));
        return self
    }

    public func addUInt64Array(value: [UInt64]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint64[]", value: value.map{ String($0)} ));
        return self
    }

    public func addInt64(value: Int64) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "int64", value: [String(value)]));
        return self
    }

    public func addUInt256(value: BigUInt) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint256", value: [String(value)]));
        return self;
    }

    public func addUInt256Array(value: [BigUInt]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "uint256[]", value: value.map{ String($0)} ));
        return self;
    }

    public func addTuple(value: ContractFunctionParameters) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "tuple", value: [value.encode()]));
        return self;
    }

    public func addTupleArray(value: [ContractFunctionParameters]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "tuple[]", value: value.map{$0.encode()}));
        return self;
    }

    public func addString(value: String) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "string", value: [value]));
        return self;
    }

    public func addStringArray(value: [String]) -> ContractFunctionParameters {
        params.append(ContractFunctionParameter(type: "string[]", value: value));
        return self;
    }

    public func encode() -> String {
        do {
            let encoder = JSONEncoder();
            encoder.outputFormatting = [.sortedKeys]
            let encodedValue = try encoder.encode(params).base64EncodedString();
            return encodedValue;
        } catch let error {
            print(error)
        }
        return "";
    }
}

public struct ContractFunctionParameter: Encodable {
    public var type: String
    public var value: [String] = []
}
