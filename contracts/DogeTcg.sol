// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ERC404.sol";
import "./lib/CardManagementLib.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ERC404UniswapV2Exempt } from "./ERC404UniswapV2Exempt.sol";

contract DogeTCG is Ownable, ERC404, ERC404UniswapV2Exempt {
    using CardManagementLib for CardManagementLib.CardData;

    CardManagementLib.CardData private cardData;

    bytes[] private imgSources;
    bytes[] private rareImageSources;
    bytes32[] private firstNames;
    bytes32[] private breedTypes;
    bytes32[] private attacks;
    bytes32[] private specialAttacks;
    bytes32[] private rareBreeds;
    bytes32[] private rareAttacks;
    bytes32[] private rareSpecialAttacks;

    uint256 private maxLife = 100;

    bytes32 private providerSource = bytes32("https://ipfs.io/ipfs/");
    uint16 private lastGenerationIncreaseTime = 0;
    uint64 private generationIncreaseInterval = 70 days;
    uint16 private generation = 1;

    mapping(uint256 => uint256) public revealedCards;

    event CardRevealed(uint256 indexed tokenId, uint256 indexed cardTypeId, address indexed owner);
   
    //0x7a250d5630b4cf539739df2c5dacb4c659f2488d Router address
    constructor(address uniswapV2Router_) ERC404("DogeTCG", "DOGT", 18) Ownable(msg.sender) ERC404UniswapV2Exempt(uniswapV2Router_){
        firstNames = [bytes32("Ren"), bytes32("Jiro"), bytes32("Yuna"), bytes32("Kai"), bytes32("Mila"), bytes32("Finn"), bytes32("Zane"), bytes32("Lex"), bytes32("Taro"), bytes32("Niko"), bytes32("Sora"), bytes32("Elle"), bytes32("Riku"), bytes32("Lutz"), bytes32("Glen"), bytes32("Hiro"), bytes32("Lina"), bytes32("Otto"), bytes32("Yuki"), bytes32("Emi")];
        breedTypes = [bytes32("Fireoge"), bytes32("Wateroge"), bytes32("Grassoge"), bytes32("Earthoge"), bytes32("Psyoge"), bytes32("Plainoge")];
        attacks = [bytes32("Fire Ball"), bytes32("Fire Punch"), bytes32("Water Gun"), bytes32("Water Splash"), bytes32("Grass Whip"), bytes32("Grass Punch"), bytes32("Mud Splash"), bytes32("Earth Punch"), bytes32("Psy Shock"), bytes32("Psy Punch"), bytes32("Headbutt"), bytes32("Scratch")];
        specialAttacks = [bytes32("Fire Blast"), bytes32("Hydro Pump"), bytes32("Solar Beam"), bytes32("Earthquake"), bytes32("Psy Beam"), bytes32("Hyper Beam")];
        rareBreeds = [bytes32("Angeloge"), bytes32("Godoge"), bytes32("VoidWalker"), bytes32("Deviloge")];
        rareAttacks = [bytes32("Celestial Strike"), bytes32("Divine Judgment"), bytes32("Abyssal Fire"), bytes32("Solar Flare"), bytes32("Tsunami Wave"), bytes32("Seismic Quake"), bytes32("Mind Crush"), bytes32("Void Slash")];
        rareSpecialAttacks = [bytes32("Heaven's Grace"), bytes32("Darkness Overwhelm"), bytes32("Phoenix Rebirth"), bytes32("Leviathan's Rage"), bytes32("Gaia's Embrace"), bytes32("Titan's Stomp"), bytes32("Psychic Storm"), bytes32("Ethereal Strike")];

        _setERC721TransferExempt(msg.sender, true);
        _mintERC20(msg.sender, 10000 * units);
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

    function _createCardType() internal returns (uint256) {
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
            maxLife: maxLife,
            generation: generation
        });

        uint256 cardTypeId = CardManagementLib.createCardType(cardData, params);
        return cardTypeId;
    }
    function changeIpfsProvider(bytes32 _ipfsProviderSource) public onlyOwner {
        providerSource = _ipfsProviderSource;
    }

    function addImgSources(bytes[] memory _sources) public onlyOwner {
        for (uint256 i = 0; i < _sources.length; i++) {
            imgSources.push(_sources[i]);
        }
    }

    function addRareImgSourcs(bytes[] memory _sources) public onlyOwner {
        for (uint256 i = 0; i < _sources.length; i++) {
            rareImageSources.push(_sources[i]);
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (revealedCards[tokenId] > 0) {
            CardManagementLib.CardType memory card = cardData.cardTypes[revealedCards[tokenId]];
            string memory output = string(
                abi.encodePacked(
                    '{"name": "',
                    card.firstName, " " ,card.breed,
                    '", "description": "DogeTCG - Generation #', Strings.toString(card.generation) ,'", "image": "',
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
                    '{"trait_type": "Life", "value": "',
                    Strings.toString(card.life),'"',
                    "}",
                    "]",
                    "}"
                )
            );
            return output;
        } else {
            return
                string(
                    abi.encodePacked(
                        '{"name": "Hidden Card", "description": "DogeTCG - Generation #', Strings.toString(generation) ,'. Reveal the booster to see its stats.", "image": "',
                        providerSource,
                        "bafybeic5zmxvk6mmacsivnt2mm3ps5ahfylunekbe7m76wh3dcdjg5pvra", // default booster img CID
                        '"}'
                    )
                );
        }
    }
}
