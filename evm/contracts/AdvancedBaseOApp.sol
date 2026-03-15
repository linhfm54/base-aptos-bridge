```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedBaseOApp is OApp, OAppOptionsType3 {
    using OptionsBuilder for bytes;

    uint8 public constant ACTION_UPDATE_STATE = 1;

    event CrossChainMessageSent(bytes32 indexed guid, uint32 dstEid, bytes payload);

    constructor(address _endpoint, address _delegate) OApp(_endpoint, _delegate) Ownable(_delegate) {}

    function quoteFee(
        uint32 _dstEid,
        string memory _message,
        bytes calldata _extraOptions
    ) public view returns (MessagingFee memory fee) {
        bytes memory payload = _buildPayload(ACTION_UPDATE_STATE, _message);
        bytes memory options = combineOptions(_dstEid, msg.sig, _extraOptions);
        return _quote(_dstEid, payload, options, false);
    }

    function sendCrossChainMessage(
        uint32 _dstEid,
        string memory _message,
        bytes calldata _extraOptions
    ) external payable {
        bytes memory payload = _buildPayload(ACTION_UPDATE_STATE, _message);
        bytes memory options = combineOptions(_dstEid, msg.sig, _extraOptions);

        MessagingFee memory fee = _quote(_dstEid, payload, options, false);
        require(msg.value >= fee.nativeFee, "AdvancedBaseOApp: Insufficient gas");

        MessagingReceipt memory receipt = _lzSend(
            _dstEid,
            payload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit CrossChainMessageSent(receipt.guid, _dstEid, payload);
    }

    function _buildPayload(uint8 _action, string memory _message) internal pure returns (bytes memory) {
        bytes memory msgBytes = bytes(_message);
        require(msgBytes.length <= type(uint16).max, "Payload too large");
        
        return abi.encodePacked(_action, uint16(msgBytes.length), msgBytes);
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _payload,
        address _executor,
        bytes calldata _extraData
    ) internal override {}
}
