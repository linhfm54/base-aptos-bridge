module base_aptos_bridge::advanced_receiver {
    use std::string::{Self, String};
    use std::vector;
    use std::signer;
    use aptos_framework::event;

    const EUNAUTHORIZED: u64 = 1;
    const EINVALID_PAYLOAD_LENGTH: u64 = 2;
    const EUNKNOWN_ACTION: u64 = 3;

    const ACTION_UPDATE_STATE: u8 = 1;

    struct BridgeState has key {
        admin: address,
        last_sender_chain: u32,
        last_message: String,
    }

    #[event]
    struct MessageProcessedEvent has drop, store {
        src_chain_id: u32,
        action: u8,
        message: String,
    }

    public entry fun init_module(account: &signer) {
        move_to(account, BridgeState {
            admin: signer::address_of(account),
            last_sender_chain: 0,
            last_message: string::utf8(b""),
        });
    }

    public entry fun lz_receive(
        _account: &signer, 
        src_chain_id: u32,
        _src_address: vector<u8>,
        _nonce: u64,
        payload: vector<u8>
    ) acquires BridgeState {
        assert!(vector::length(&payload) >= 3, EINVALID_PAYLOAD_LENGTH);

        let action = *vector::borrow(&payload, 0);
        
        let len_byte1 = (*vector::borrow(&payload, 1) as u64);
        let len_byte2 = (*vector::borrow(&payload, 2) as u64);
        let msg_length = (len_byte1 << 8) | len_byte2;

        assert!(vector::length(&payload) == 3 + msg_length, EINVALID_PAYLOAD_LENGTH);

        let msg_bytes = vector::empty<u8>();
        let i = 3;
        while (i < 3 + msg_length) {
            vector::push_back(&mut msg_bytes, *vector::borrow(&payload, i));
            i = i + 1;
        };
        let decoded_msg = string::utf8(msg_bytes);

        if (action == ACTION_UPDATE_STATE) {
            process_update_state(src_chain_id, decoded_msg, action);
        } else {
            abort EUNKNOWN_ACTION
        }
    }

    fun process_update_state(src_chain_id: u32, message: String, action: u8) acquires BridgeState {
        let state = borrow_global_mut<BridgeState>(@base_aptos_bridge);
        state.last_message = message;
        state.last_sender_chain = src_chain_id;

        event::emit(MessageProcessedEvent {
            src_chain_id,
            action,
            message,
        });
    }
}
