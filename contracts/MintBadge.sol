//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IBadge {
    function mint(
        uint8 roleIndex,
        uint256 to,
        uint32 value,
        uint32 eventKey
    ) external;

    function roles(uint8 roleIndex) external view returns (address);
}

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }
        return computedHash;
    }
}

contract MintBadge {
    address public badge;
    bool private initialized;

    function initialize(address badge_) public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;

        badge = badge_;
    }

    function claim_(
        uint8 roleIndex,
        uint256 tokenId,
        uint32 eventKey,
        bytes32[] calldata _merkleProof
    ) external {
        bytes32 merkleRoot = 0xc4aa592ea71eb67ce5800208d4fa40d5382dc1f6f7efc26041da662b8742cca9;

        uint32 value;
        // 10: mining3 auction
        // 11: mining3 badge
        if (eventKey == 10) {
            value = 40;
        } else if (eventKey == 11) {
            value = 10;
        }

        address role = IBadge(badge).roles(roleIndex);

        require(_isApprovedOrOwner(msg.sender, tokenId, role), "Not approved");

        bytes32 node = keccak256(
            abi.encodePacked(roleIndex, tokenId, eventKey)
        );

        require(
            MerkleProof.verify(_merkleProof, merkleRoot, node),
            "Invalid proof"
        );

        IBadge(badge).mint(roleIndex, tokenId, value, eventKey);
    }

    function _isApprovedOrOwner(
        address operator,
        uint256 tokenId,
        address role
    ) private view returns (bool) {
        address TokenOwner = IERC721(role).ownerOf(tokenId);
        return (operator == TokenOwner ||
            IERC721(role).getApproved(tokenId) == operator ||
            IERC721(role).isApprovedForAll(TokenOwner, operator));
    }
}
