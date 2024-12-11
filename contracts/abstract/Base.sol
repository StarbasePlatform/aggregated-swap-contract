//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
abstract contract Base{
    using SafeERC20 for IERC20;
    // ============ immutable contract creator address ============
    address immutable creator;
    // ============ immutable wrapped ether address ============
    address public immutable _IWETH;
    /**
     * @dev Contract constructor to initialize the wrapped ether address and contract creator
     * @param IWETH_ The Wrapped Ether.
     */
    constructor (address IWETH_)  payable {
        creator=msg.sender;
        _IWETH = IWETH_;
    }

    receive() external payable {}
    fallback() external payable {}

    // ============ Storage ============
    bytes assetTransfer;// asset and payer infos
    /**
     * @dev call back by swap contract address.
     * @param to Transfer token to swap receiver.
     * @param value Transfer token to swap receiver.
     */
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
            if(amount>value){
                assetTransfer=abi.encodePacked(from,token,amount-value);
                IERC20(token).safeTransferFrom(from, to, value);
            }else if(amount>0){
                assetTransfer=new bytes(0);
                IERC20(token).safeTransferFrom(from, to, amount);
            }
        }else if(assetTransfer.length==32){
            bytes memory _assetTransfer=assetTransfer;
            uint amount;
            assembly {
                 amount := mload(add(_assetTransfer, 0x20))
            }
            if(amount>value){
                assetTransfer=abi.encodePacked(amount-value);
                IERC20(_IWETH).safeTransfer(to, value);
            }else if(amount>0){
                assetTransfer=new bytes(0);
                IERC20(_IWETH).safeTransfer(to, amount);
            }
        }
    }
    /**
     * @dev @notice Transfers the full amount of a token held by this contract to recipient
     * @param token The contract address of the token which will be transferred to `recipient`
     */
    function defiSync(address token)external {
        if(_IWETH==token){
            uint bal=address(this).balance;
            if(bal>0){
                (bool success,) = creator.call{value: bal}(new bytes(0));
                require(success, 'defiSync:STE');
            }
        }
        uint tokenBal=IERC20(token).balanceOf(address(this));
        if(tokenBal>0){
            IERC20(token).safeTransfer(creator, tokenBal);
        }
    }
}