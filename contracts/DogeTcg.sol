//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ERC404.sol";
import "./lib/CardManagementLib.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract DogeTCG is Ownable, ERC404 {

    using CardManagementLib for CardManagementLib.CardData;

    CardManagementLib.CardData private cardData;

    string[] private imgSources;
    string[] private rareImageSources;
    string[] private firstNames = ["Ren", "Jiro", "Yuna", "Kai", "Mila", "Finn", "Zane", "Lex", "Taro", "Niko", "Sora", "Elle", "Riku", "Lutz", "Glen", "Hiro", "Lina", "Otto", "Yuki", "Emi"];
    string[] private breedTypes = ["Fireoge", "Wateroge", "Grassoge", "Earthoge", "Psyoge", "Plainoge"];
    string[] private attacks = ["Fire Ball", "Fire Punch", "Water Gun", "Water Splash", "Grass Whip", "Grass Punch", "Mud Splash", "Earth Punch", "Psy Shock", "Psy Punch", "Headbutt", "Scratch"];
    string[] private specialAttacks = ["Fire Blast", "Hydro Pump", "Solar Beam", "Earthquake", "Psy Beam", "Hyper Beam"];
    string[] private rareBreeds = ["Angeloge", "Godoge", "VoidWalker", "Deviloge"];
    string[] private rareAttacks = ["Celestial Strike", "Divine Judgment", "Abyssal Fire", "Solar Flare", "Tsunami Wave", "Seismic Quake", "Mind Crush", "Void Slash"];
    string[] private rareSpecialAttacks = ["Heaven's Grace", "Darkness Overwhelm", "Phoenix Rebirth", "Leviathan's Rage", "Gaia's Embrace", "Titan's Stomp", "Psychic Storm", "Ethereal Strike"];

    uint256 private maxLife = 100;

    string private bosterImg = "bafybeic5zmxvk6mmacsivnt2mm3ps5ahfylunekbe7m76wh3dcdjg5pvra";
    string private providerSource = "https://ipfs.io/ipfs/";
    mapping(uint256 => uint256) public revealedCards;

    event CardRevealed(uint256 indexed tokenId, uint256 indexed cardTypeId, address indexed owner);

    constructor() ERC404("DogeTCG","DOGT", 18) Ownable(msg.sender) {
        _setERC721TransferExempt(msg.sender, true);
        _mintERC20(msg.sender, 10000 * units, false);
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function bulkRevealCards(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            revealCard(tokenIds[i]);
        }
    }

    function revealCard(uint256 tokenId) public {
        require(_getOwnerOf(tokenId) == msg.sender, "You must own the token to reveal it");
        require(revealedCards[tokenId] == 0, "Card is already revealed");

        uint256 cardTypeId = _createCardType();
        revealedCards[tokenId] = cardTypeId;

        emit CardRevealed(tokenId, cardTypeId, msg.sender);
    }

    function _createCardType() internal returns (uint256){
        CardManagementLib.CreateCardTypeParams memory params = CardManagementLib.CreateCardTypeParams({
            firstNames: firstNames,
            breedTypes: breedTypes,
            attacks: attacks,
            specialAttacks: specialAttacks,
            rareBreeds: rareBreeds,
            rareAttacks: rareAttacks,
            rareSpecialAttacks: rareSpecialAttacks,
            imgSources: imgSources,
            rareImageSources: rareImageSources,
            maxLife: maxLife
        });

        uint256 cardTypeId = CardManagementLib.createCardType(cardData, params);
        return cardTypeId;
    }

    function changeIpfsProvider(string memory _ipfsProviderSource) public onlyOwner {
        providerSource = _ipfsProviderSource;
    }

    function addImgSource(string memory _source) public onlyOwner {
        imgSources.push(_source);
    }

    function addMultipleImgSource(string[] memory _sources) public onlyOwner {
        for (uint256 i = 0; i < _sources.length; i++) {
            imgSources.push(_sources[i]);
        }
    }

    function addRareImgSource(string memory _source) public onlyOwner {
        rareImageSources.push(_source);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (revealedCards[tokenId] > 0) {
            CardManagementLib.CardType memory card = cardData.cardTypes[revealedCards[tokenId]];
            string memory output = string(abi.encodePacked(
                '{"name": "',
                card.name,
                '", "description": "DogeTCG - Generation #1", "image": "',
                providerSource,
                card.img,
                '", "attributes": [',
                '{"trait_type": "Family", "value": "',
                card.breed,
                '"},',
                '{"trait_type": "Attack 1", "value": "',
                card.attacks[0],
                '"},',
                '{"trait_type": "Attack 2", "value": "',
                card.attacks[1],
                '"},',
                '{"trait_type": "Special Attack", "value": "',
                card.attacks[2],
                '"},',
                '{"trait_type": "Life", "value": ',
                Strings.toString(card.life),
                '}',
                ']',
                '}'
            ));
            return output;
        } else {
            return string(abi.encodePacked(
                '{"name": "Hidden Card", "description": "DogeTCG - Generation #1. Reveal the booster to see its stats.", "image": "',
                providerSource,
                bosterImg,
                '"}'
            ));
        }
    }
}