//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

 
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
abstract contract Base{
    address immutable creater;

    address public immutable _IWETH;
    constructor (address IWETH_)  payable {
        creater=msg.sender;
        _IWETH = IWETH_;
    }

    receive() external payable {}
    fallback() external payable {}
    bytes assetTransfer;

    function functionCall(address target,bytes memory data,string memory errorMessage)internal {
        (bool success, bytes memory returndata) = target.call(data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
    
    
    function defiCallBack(address to,uint value)external{
        if(assetTransfer.length==72){
            bytes memory _assetTransfer=assetTransfer;
            address from;
            address token;
            uint amount;
            assembly {
                from := shr(96, mload(add(add(_assetTransfer, 0x20), 0)))
                token := shr(96, mload(add(add(_assetTransfer, 0x20), 0x14)))
                amount := mload(add(add(_assetTransfer, 0x20), 0x28))
            }
            //0x23b872dd=bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
            if(amount>value){
                assetTransfer=abi.encodePacked(from,token,amount-value);
                functionCall(token,abi.encodeWithSelector(0x23b872dd,from,to,value),'TF');//defiCallBack: TRANSFER_FROM_FAILED
            }else if(amount>0){
                assetTransfer=new bytes(0);
                functionCall(token,abi.encodeWithSelector(0x23b872dd,from,to,amount),'TF');//defiCallBack: TRANSFER_FROM_FAILED
            }
        }else if(assetTransfer.length==32){
            bytes memory _assetTransfer=assetTransfer;
            uint amount;
            assembly {
                 amount := mload(add(_assetTransfer, 0x20))
            }
            //0xa9059cbb=bytes4(keccak256(bytes('transfer(address,uint256)')));
            if(amount>value){
                assetTransfer=abi.encodePacked(amount-value);
                functionCall(_IWETH, abi.encodeWithSelector(0xa9059cbb, to, value), 'TF');//defiCallBack: TRANSFER_FAILED
            }else if(amount>0){
                assetTransfer=new bytes(0);
                functionCall(_IWETH, abi.encodeWithSelector(0xa9059cbb, to, amount), 'TF');//defiCallBack: TRANSFER_FAILED
            }
        }
    }
    function defiSync(address token)external {
        if(_IWETH==token){
            uint bal=address(this).balance;
            if(bal>0){
                (bool success,) = creater.call{value: bal}(new bytes(0));
                require(success, 'defiSync:STE');
            }
        }
        uint tokenBal=IERC20(token).balanceOf(address(this));
        if(tokenBal>0){
            functionCall(token, abi.encodeWithSelector(0xa9059cbb, creater, tokenBal), 'defiSync: TRANSFER_FAILED');
        }
    }
}