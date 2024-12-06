//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

 
contract CallSwapTool {

    error ZeroAddress();
    
    function callswap(
        address callSwapAddr,
        bytes calldata data,
        string memory message
    ) external {
        if (callSwapAddr == address(0)) revert ZeroAddress();
        (bool success, bytes memory returndata) = callSwapAddr.call(data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(message);
            }
        }
    }
}
