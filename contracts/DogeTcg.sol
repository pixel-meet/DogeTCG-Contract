//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC404.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * Keep it simple - TCG Game based on ERC404
 * The better the types match the better the card and power is of the card. E.g =  cid + lastname + breedtype + attack1 = x4 Power
 * Rare matches are x5 Power 
 */ 
contract DogeTCG is ERC404 {

    struct CardType {
        string name;
        string attack1;
        string attack2;
        string attack3;
        uint256 life;
        string img;//ipfs CID
    }
    mapping(uint256 => CardType) public cardTypes;
    uint256 public cardTypeLength = 0;

    mapping(uint256 => string) public imgSources;
    uint256 public imgSourcesLength = 0;

    // 20 different first names
    string[] public firstNames = ["Ren", "Jiro", "Yuna", "Kai", "Mila", "Finn", "Zane", "Lex", "Taro", "Niko", "Sora", "Elle", "Riku", "Lutz", "Glen", "Hiro", "Lina", "Otto", "Yuki", "Emi"];
    // 20 different fantasy last names based on breed Types mixed names like WaterBender or BolderBro or else
    string[] public lastNames = ["FireSenshi", "WaterShogun", "GrassRonin", "EarthSamurai", "PsyNinja", "NormalKenshi", "FireKami", "WaterOni", "GrassShinobi", "EarthKaiju", "PsySage", "NormalMiko", "FireYokai", "WaterDragon", "GrassMonk", "EarthGolem", "PsyOracle", "NormalGuardian", "FirePhoenix", "WaterKappa"];
    // 6 types
    string[] public breedTypes = ["Fire", "Water", "Grass", "Earth", "Psy", "Normal"];
      // 2 attack for each type
    string[] public attacks = ["Fire Ball", "Fire Punch", "Water Gun", "Water Splash", "Grass Whip", "Grass Punch", "Mud Splash", "Earth Punch", "Psy Shock", "Psy Punch", "Tackle", "Scratch"];
    // 1 special attack for each type
    string[] public specialAttacks = ["Fire Blast", "Hydro Pump", "Solar Beam", "Earthquake", "Psy Beam", "Hyper Beam"];

    // For Rarity purposes to make it more interesting
    string[] public rareBreeds = ["Angel", "God", "Demon", "Devil"];
    // 10 rare attacks 1 for each rare breed and rest based on breed types
    string[] public rareAttacks = ["Celestial Strike", "Divine Judgment", "Abyssal Fire", "Unholy Fury", "Solar Flare", "Tsunami Wave", "Nature's Wrath", "Seismic Quake", "Mind Crush", "Void Slash"];
    // 10 rare speical attack  1 for each rare breed and rest based on breed types
     string[] public rareSpecialAttacks = ["Heaven's Grace", "Omnipotent Blast", "Infernal Chains", "Darkness Overwhelm", "Phoenix Rebirth", "Leviathan's Rage", "Gaia's Embrace", "Titan's Stomp", "Psychic Storm", "Ethereal Strike"];

    uint256 public maxLife = 100;

    string public providerSource = "https://ipfs.io/ipfs/";
    mapping(uint256 => uint256) public revealedCards;

    event CardRevealed(uint256 indexed tokenId, uint256 indexed cardTypeId, address indexed owner);

    constructor(
        address _owner
    ) ERC404("dogt", "DogeTCG", 18, 20000, _owner) {
        balanceOf[_owner] = 20000 * 10 ** 18;

        addImgSource("QmZ3");
        addImgSource("Qmtrert");
    }

    function bulkRevealCards(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            revealCard(tokenIds[i]);
        }
    }

    function revealCard(uint256 tokenId) public {
        require(balanceOf[msg.sender] > 0, "You don't have any cards");
        require(_ownerOf[tokenId] == msg.sender, "You must own the token to reveal it");
        require(revealedCards[tokenId] == 0, "Card is already revealed");

        uint256 cardTypeId = _createCardType();
        revealedCards[tokenId] = cardTypeId;

        emit CardRevealed(tokenId, cardTypeId, msg.sender);
    }

    function _random(string memory input) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input, block.timestamp, block.difficulty, msg.sender)));
    }

    function _createCardType() internal returns (uint256){
        cardTypeLength++;
        uint256 id = cardTypeLength;
        uint256 rand = _random(Strings.toString(id));

        bool isRareBreed = (rand % 100) < 5; // 5% chance for rare breed
        bool isRareAttack = (rand % 100) < 10; // 10% chance for rare attack
        bool isRareSpecialAttack = (rand % 100) < 15; // 15% chance for rare special attack

        string memory breed = isRareBreed ? rareBreeds[rand % rareBreeds.length] : breedTypes[rand % breedTypes.length];
        string memory attack1 = isRareAttack ? rareAttacks[rand % rareAttacks.length] : attacks[rand % attacks.length];
        string memory attack2 = attacks[(rand + 1) % attacks.length];
        string memory attack3 = isRareSpecialAttack ? rareSpecialAttacks[rand % rareSpecialAttacks.length] : specialAttacks[rand % specialAttacks.length];

        uint256 life = (rand % maxLife) + 1;
        string memory img = imgSources[rand % imgSourcesLength];
        cardTypes[id] = CardType(breed, attack1, attack2, attack3, life, img);

        return id;
    }


    function changeIpfsProvider(string memory _ipfsProviderSource) public payable onlyOwner {
        providerSource = _ipfsProviderSource;
    }

    function addImgSource(string memory _source) public payable onlyOwner {
        imgSources[imgSourcesLength] = _source;
        imgSourcesLength++;
    }

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "Token does not exist");

        if (revealedCards[tokenId] > 0) {
            CardType memory card = cardTypes[revealedCards[tokenId]];
            string memory output = string(abi.encodePacked(
                '{"name": "',
                card.name,
                '", "description": "DogeTCG is a TCG game where you can collect and battle with your cards. You can reveal your cards to see their stats and use them in battles.", "image": "',
                providerSource,
                card.img,
                '", "attributes": [',
                '{"trait_type": "Attack 1", "value": "',
                card.attack1,
                '"},',
                '{"trait_type": "Attack 2", "value": "',
                card.attack2,
                '"},',
                '{"trait_type": "Attack 3", "value": "',
                card.attack3,
                '"},',
                '{"trait_type": "Life", "value": ',
                Strings.toString(card.life),
                '}',
                ']',
                '}'
            ));
            return output;
        } else {
            return "https://raw.githubusercontent.com/devlordmonarch/metadata/main/unrevealed.json";
        }
    }
}