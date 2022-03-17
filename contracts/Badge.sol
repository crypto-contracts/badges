//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Badge {
    mapping(uint8 => address) public roles;

    mapping(uint => uint32) public events;
    mapping(uint32 => string) public achievements;
    mapping(uint => uint32) public points;
    
    uint private counter;

    mapping(uint256 => uint256) private _owners;
    mapping(uint256 => uint8) private _ownersOfRole;
    mapping(uint8 => mapping(uint256 => uint256)) private _balances;

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

    constructor() {
        // rarity
        roles[1] = 0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb;
        // monster genesis
        roles[2] = 0x2D2f7462197d4cfEB6491e254a16D3fb2d2030EE;
        // monster reborn
        roles[3] = 0x881c9c392F4E02Dd599dE22CaDAa98977c4CFB90;

        achievements[1] = "the first time parent";
        achievements[2] = "big family";
        achievements[3] = "the great parent";
        achievements[4] = "the first time miner mine season I";
        achievements[5] = "busy miner mine season I";
        achievements[6] = "brave explorer mine season I";
        achievements[7] = "conantur repugnare mine season II";
        achievements[8] = "brave explorer mine season II";
        achievements[9] = "confident beast mine season II";
        achievements[10] = "monster hunter mine season II";
        achievements[11] = "gatekeeper mine season II";
    }

    function setRole(uint8 index, address role) external{
        roles[index] = role;
    }

    function setSymoblMap(uint32 eventKey, string memory achievement) external {
        achievements[eventKey] = achievement;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != uint256(0);
    }

    function mint(uint8 roleIndex, uint to, uint32 value, uint32 eventKey) external {
        counter ++;
        points[counter] = value;
        events[counter] = eventKey;

        _mint(roleIndex, to, counter);

        emit Minted(roleIndex, to, counter, value, eventKey);
    }

    function _mint(uint8 roleIndex, uint256 to, uint256 tokenId) internal {
        require(roles[roleIndex] != address(0), "MERC721: mint to the zero tokenID");
        require(to != uint256(0), "MERC721: mint to the nonexistent role");
        require(!_exists(tokenId), "MERC721: token already minted");

        _balances[roleIndex][to] += 1;
        _ownersOfRole[tokenId] = roleIndex;
        _owners[tokenId] = to;

        emit Transfer(uint256(0), roleIndex, to, tokenId);
    }

    function burn(uint tokenID) external{
        require(_exists(tokenID), "MERC721: token not minted");
        _burn(tokenID);
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