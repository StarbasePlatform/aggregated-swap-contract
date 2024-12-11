//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./abstract/Base.sol";
import {IWETH} from "./interface/IWETH.sol";
import {CallSwapTool} from "./CallSwapTool.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Common} from "./library/Common.sol";
/**
* @title AggregatedSwapRouter
 * @dev An aggregated swap router contract that allows approved addresses to swap tokenA to the tokenB.
 * @notice This contract supports swap from eth and swap for eth.
 * @author StarBase
 */
contract AggregatedSwapRouter is Base {
    using Address for address;
    using SafeERC20 for IERC20;

    // ============ immutable proxy contract address ============
    address public immutable _CallSwapTool;// the proxy contract

    // ============ Modifiers ============
    /**
     * @dev Modifier to ensure that the contract is not zero address.
     */
    modifier notZeroAddress(address receiver) {
        require(receiver != address(0), "Receiver address cannot be the zero address");
        _;
    }
    /**
     * @dev Contract constructor to initialize the contract with proxy contract, the StarBaseApprove contract.
     * @param CallSwapTool_ The proxy contract.
     * @param IWETH_ The Wrapped Ether.
     */
    constructor(address CallSwapTool_, address IWETH_)Base(IWETH_) {
        Common._validateAddress(CallSwapTool_);
        Common._validateAddress(IWETH_);
        _CallSwapTool = CallSwapTool_;
    }
    /**
     * @dev swap token without to call back aggregated swap router contract.
     * @param amountIn Amount of source tokens to swap
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenIn Source in token.
     * @param tokenOut Destination out token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address tokenOut,
        address receiver,
        address callSwapAddr,
        bytes calldata datas
    ) external notZeroAddress(receiver){
        IERC20(tokenIn).safeTransferFrom(msg.sender, callSwapAddr, amountIn);
        uint balanceBefore = IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "E"); //SWAP ERROR
        require(
            IERC20(tokenOut).balanceOf(receiver) >=
                (balanceBefore + amountOutMin),
            "OT"
        ); //INSUFFICIENT_OUTPUT_AMOUNT
    }
   /**
     * @dev swap token with call back aggregated swap router contract.
     * @param amountIn Amount of source tokens to swap
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenIn Source in token.
     * @param tokenOut Destination out token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function defiSwap(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address tokenOut,
        address receiver,
        address callSwapAddr,
        bytes calldata datas
    ) external notZeroAddress(receiver) {
        assetTransfer = abi.encodePacked(msg.sender, tokenIn, amountIn);
        uint balanceBefore = IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "E"); //SWAP ERROR
        require(
            IERC20(tokenOut).balanceOf(receiver) >=
                (balanceBefore + amountOutMin),
            "OT"
        ); //INSUFFICIENT_OUTPUT_AMOUNT
        if (assetTransfer.length > 0) {
            assetTransfer = new bytes(0);
        }
    }
    /**
      * @dev swap token for ether with call back aggregated swap router contract.
     * @param amountIn Amount of source tokens to swap
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenIn Source in token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function defiSwapForEth(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address payable receiver,
        address callSwapAddr,
        bytes calldata datas
    ) external notZeroAddress(receiver) {
        assetTransfer = abi.encodePacked(msg.sender, tokenIn, amountIn);
        uint balanceBefore = receiver.balance;
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "FE"); //SWAP ERROR
        require(receiver.balance >= (balanceBefore + amountOutMin), "FOT"); //INSUFFICIENT_OUTPUT_AMOUNT
        if (assetTransfer.length > 0) {
            assetTransfer = new bytes(0);
        }
    }
    /**
     * @dev swap token for ether without to call back aggregated swap router contract.
     * @param amountIn Amount of source tokens to swap
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenIn Source in token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function swapForEth(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address payable receiver,
        address callSwapAddr,
        bytes calldata datas
    ) external notZeroAddress(receiver) {
        IERC20(tokenIn).safeTransferFrom(msg.sender, callSwapAddr, amountIn);
        uint balanceBefore = receiver.balance;
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "FE"); //SWAP ERROR
        require(receiver.balance >= (balanceBefore + amountOutMin), "FOT"); //INSUFFICIENT_OUTPUT_AMOUNT
    }
    /**
     * @dev swap ether for erc20 token with call back aggregated swap router contract.
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenOut Destination out token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function defiSwapFromEth(
        uint amountOutMin,
        address tokenOut,
        address receiver,
        address callSwapAddr,
        bytes calldata datas
    ) external payable  notZeroAddress(receiver){
        IWETH(_IWETH).deposit{value: msg.value}();
        assetTransfer = abi.encodePacked(msg.value);
        uint balanceBefore = IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "FRE"); //SWAP ERROR
        require(
            IERC20(tokenOut).balanceOf(receiver) >=
                (balanceBefore + amountOutMin),
            "FROT"
        );
        if (assetTransfer.length > 0) {
            uint remain;
            bytes memory _assetTransfer = assetTransfer;
            
            assembly {  
                 remain := mload(add(_assetTransfer, 0x20))
            }
            
            assetTransfer = new bytes(0);
            if (remain > 44000 * tx.gasprice) {
                IWETH(_IWETH).withdraw(remain);
                (bool success, ) = msg.sender.call{value: remain}(new bytes(0));
                require(success, "STE");
            }
        }
    }
    /**
     * @dev swap ether for erc20 token without to call back aggregated swap router contract.
     * @param amountOutMin The min amount of destination tokens to receive
     * @param tokenOut Destination out token.
     * @param receiver Address that will receive swap funds.
     * @param callSwapAddr Aggregated swap address.
     * @param datas Aggregated swap call datas.
     */
    function swapFromEth(
        uint amountOutMin,
        address tokenOut,
        address receiver,
        address payable callSwapAddr,
        bytes calldata datas
    ) external payable notZeroAddress(receiver) {
        callSwapAddr.transfer(msg.value);
        uint balanceBefore = IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(_CallSwapTool).callswap(callSwapAddr, datas, "FRE"); //SWAP ERROR
        require(
            IERC20(tokenOut).balanceOf(receiver) >=
                (balanceBefore + amountOutMin),
            "FROT"
        );
    }
}
 
