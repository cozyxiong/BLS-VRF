# BLS-VRF
**BLS-VRF: Verifiable Random Function with BLS Signatures**

BLS-VRF is an implementation of Verifiable Random Function (VRF) using Boneh-Lynn-Shacham (BLS) signatures on the Ethereum blockchain. This project provides a secure and efficient way to generate on-chain verifiable randomness, crucial for applications.

## Build
```shell
$ forge build
```

## Env
```shell
Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#]\S+)\s*=\s*(.*)\s*$") {
        $varName = $matches[1]
        $varValue = $matches[2] -replace '^"|"$|^''|''$'  # 去除可能的引号
        Set-Item -Path "env:$varName" -Value $varValue
    }
}

echo $env:PRIVATE_KEY
echo $env:RPC_URL
```

## Deploy
```shell
forge script ./script/VRFDeploy.s.sol:VRFDeployScript --rpc-url $env:RPC_URL --private-key $env:PRIVATE_KEY --broadcast
```

## Call Function
```shell
cast send --rpc-url $env:RPC_URL --private-key $env:PRIVATE_KEY 0xdFd5C407705c20d6982cD96E3d5681590966d4BA "requestRandomWords(uint256,uint256)" 10000, 2
```

## Address
```
bls proxy contract deployed at: 0xd8895d06A09F0B69027713f5304722F2a3043353
vrf logic contract deployed at: 0x2C0617A4AEA3e474d2eEF9b91302B175Cd7B0C4b
vrf proxy contract deployed at: 0xdFd5C407705c20d6982cD96E3d5681590966d4BA
vrf factory contract deployed at: 0xE78fA60399e3844E3f9220ec7f27E9477c7D115a
```
