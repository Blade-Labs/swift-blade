# ParametersBuilder class

[blade-sdk.js](https://github.com/Blade-Labs/blade-sdk.js/blob/release/0.5.0/docs/contents.md) / ParametersBuilder

## Class: ParametersBuilder

ParametersBuilder is a helper class to build contract function parameters

**`Example`**

```ts
const params = new ParametersBuilder()
   .addAddress("0.0.123")
   .addUInt8(42)
   .addBytes32([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F])
   .addString("Hello World")
   .addTuple(new ParametersBuilder().addAddress("0.0.456").addUInt8(42))
 ;
```

### Table of contents

#### Constructors

* [constructor](parametersbuilder.md#constructor)

#### Properties

* [params](parametersbuilder.md#params)

#### Methods

* [addAddress](parametersbuilder.md#addaddress)
* [addAddressArray](parametersbuilder.md#addaddressarray)
* [addBytes32](parametersbuilder.md#addbytes32)
* [addInt64](parametersbuilder.md#addint64)
* [addString](parametersbuilder.md#addstring)
* [addStringArray](parametersbuilder.md#addstringarray)
* [addTuple](parametersbuilder.md#addtuple)
* [addTupleArray](parametersbuilder.md#addtuplearray)
* [addUInt256](parametersbuilder.md#adduint256)
* [addUInt256Array](parametersbuilder.md#adduint256array)
* [addUInt64](parametersbuilder.md#adduint64)
* [addUInt64Array](parametersbuilder.md#adduint64array)
* [addUInt8](parametersbuilder.md#adduint8)
* [encode](parametersbuilder.md#encode)

### Constructors

#### constructor

• **new ParametersBuilder**()

### Properties

#### params

• `Private` **params**: `ContractFunctionParameter`\[] = `[]`

**Defined in**

[ParametersBuilder.ts:22](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L22)

### Methods

#### addAddress

▸ **addAddress**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type                  |
| ------- | --------------------- |
| `value` | `string` \| `default` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:24](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L24)

***

#### addAddressArray

▸ **addAddressArray**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type                        |
| ------- | --------------------------- |
| `value` | `string`\[] \| `default`\[] |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:29](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L29)

***

#### addBytes32

▸ **addBytes32**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type                        |
| ------- | --------------------------- |
| `value` | `number`\[] \| `Uint8Array` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:34](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L34)

***

#### addInt64

▸ **addInt64**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type        |
| ------- | ----------- |
| `value` | `BigNumber` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:61](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L61)

***

#### addString

▸ **addString**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type     |
| ------- | -------- |
| `value` | `string` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:86](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L86)

***

#### addStringArray

▸ **addStringArray**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type        |
| ------- | ----------- |
| `value` | `string`\[] |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:91](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L91)

***

#### addTuple

▸ **addTuple**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type                                        |
| ------- | ------------------------------------------- |
| `value` | [`ParametersBuilder`](parametersbuilder.md) |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:76](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L76)

***

#### addTupleArray

▸ **addTupleArray**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type                                           |
| ------- | ---------------------------------------------- |
| `value` | [`ParametersBuilder`](parametersbuilder.md)\[] |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:81](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L81)

***

#### addUInt256

▸ **addUInt256**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type        |
| ------- | ----------- |
| `value` | `BigNumber` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:66](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L66)

***

#### addUInt256Array

▸ **addUInt256Array**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type           |
| ------- | -------------- |
| `value` | `BigNumber`\[] |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:71](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L71)

***

#### addUInt64

▸ **addUInt64**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type        |
| ------- | ----------- |
| `value` | `BigNumber` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:51](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L51)

***

#### addUInt64Array

▸ **addUInt64Array**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type           |
| ------- | -------------- |
| `value` | `BigNumber`\[] |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:56](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L56)

***

#### addUInt8

▸ **addUInt8**(`value`): [`ParametersBuilder`](parametersbuilder.md)

**Parameters**

| Name    | Type     |
| ------- | -------- |
| `value` | `number` |

**Returns**

[`ParametersBuilder`](parametersbuilder.md)

**Defined in**

[ParametersBuilder.ts:46](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L46)

***

#### encode

▸ **encode**(): `string`

Encodes the parameters to a base64 string, compatible with the methods of the BladeSDK Calling this method is optional, as the BladeSDK will automatically encode the parameters if needed

**Returns**

`string`

**Defined in**

[ParametersBuilder.ts:100](https://github.com/Blade-Labs/blade-sdk.js/blob/d578d13/src/ParametersBuilder.ts#L100)
