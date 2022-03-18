//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Badge is AccessControl{
    mapping(uint8 => address) public roles;

    mapping(uint => uint32) public events;
    mapping(uint32 => string) public achievements;
    mapping(uint => uint32) public points;
    
    uint private counter;

    mapping(uint256 => uint256) private _owners;
    mapping(uint256 => uint8) private _ownersOfRole;
    mapping(uint8 => mapping(uint256 => uint256)) private _balances;

    // {eventKey: {tokenID : was minted}}
    mapping (uint32 => mapping (bytes => bool)) private _hasMinted;

    event Transfer(
        uint256 indexed from,
        uint8 roleIndex,
        uint256 indexed to,
        uint256 indexed tokenId
    );

    event Minted(
        uint8 indexed roleIndex,
        uint256 indexed to,
        uint256 indexed tokenId,
        uint32 value,
        uint32 eventKey
    );

    event Cleared(
        uint256 indexed tokenId,
        uint32 indexed value
    );

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");

    constructor(address safe) {
        _setupRole(DEFAULT_ADMIN_ROLE, safe);

        // rarity
        roles[1] = 0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb;
        // monster genesis
        roles[2] = 0x2D2f7462197d4cfEB6491e254a16D3fb2d2030EE;
        // monster reborn
        roles[3] = 0x881c9c392F4E02Dd599dE22CaDAa98977c4CFB90;

        achievements[1] = "First Time Being Parent";
        achievements[2] = "Big Family";
        achievements[3] = "The Great Parent";
        achievements[4] = "First Time To Explore";
        achievements[5] = "Busy Miner";
        achievements[6] = "Busy Explorer";
    }

    function setRole(uint8 index, address role) external onlyRole(UPDATE_ROLE) {
        roles[index] = role;
    }

    function setAchievements(uint32 eventKey, string memory achievement) external onlyRole(UPDATE_ROLE) {
        achievements[eventKey] = achievement;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != uint256(0);
    }

    function _encode(uint8 roleIndex, uint to) internal pure returns (bytes memory) {
        return abi.encodePacked(roleIndex, to);
    }

    function hasMinted(uint8 roleIndex, uint to, uint32 eventKey) external view returns(bool){
        bytes memory cha = _encode(roleIndex, to);

        return _hasMinted[eventKey][cha];
    }

    function mint(uint8 roleIndex, uint to, uint32 value, uint32 eventKey) external onlyRole(MINTER_ROLE){
        bytes memory cha = _encode(roleIndex, to);
        require(!_hasMinted[eventKey][cha], "Has minted");
        counter ++;
        points[counter] = value;
        events[counter] = eventKey;

        _hasMinted[eventKey][cha] = true;
        _mint(roleIndex, to, counter);

        emit Minted(roleIndex, to, counter, value, eventKey);
    }

    function _mint(uint8 roleIndex, uint256 to, uint256 tokenId) internal {
        require(roles[roleIndex] != address(0), "MERC721: mint to the nonexistent role");
        require(to != uint256(0), "MERC721: mint to the zero tokenId");
        require(!_exists(tokenId), "MERC721: token already minted");

        _balances[roleIndex][to] += 1;
        _ownersOfRole[tokenId] = roleIndex;
        _owners[tokenId] = to;

        emit Transfer(uint256(0), roleIndex, to, tokenId);
    }

    function clearPoints(uint256 tokenId) external onlyRole(UPDATE_ROLE){
        require(_exists(tokenId), "MERC721: token not minted");
        require(points[tokenId] > 0, "Has been cleared");

        uint32 value = points[tokenId];
        points[tokenId] = 0;
        emit Cleared(tokenId, value);
    }

    function burn(uint tokenId) external onlyRole(BURNER_ROLE){
        require(_exists(tokenId), "MERC721: token not minted");
        _burn(tokenId);
    }

    function _burn(uint256 tokenId) internal {
        uint256 owner = ownerOf(tokenId);
        uint8 roleIndex = ownerOfRole(tokenId);

        _balances[roleIndex][owner] -= 1;
        delete _owners[tokenId];
        delete _ownersOfRole[tokenId];

        emit Transfer(owner, roleIndex, uint256(0), tokenId);
    }

    function balanceOf(uint8 roleIndex, uint256 owner)
        public
        view
        returns (uint256)
    {
        require(
            owner != uint256(0),
            "MERC721: balance query for the zero tokenID"
        );
        return _balances[roleIndex][owner];
    }

    function ownerOfRole(uint256 tokenId)
        public
        view
        returns (uint8)
    {
        uint8 roleIndex = _ownersOfRole[tokenId];
        require(
            roleIndex != uint8(0),
            "ERC721: owner query for nonexistent token"
        );
        return roleIndex;
    }

    function ownerOf(uint256 tokenId)
        public
        view
        returns (uint256)
    {   
        uint256 owner = _owners[tokenId];
        require(
            owner != uint256(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

}