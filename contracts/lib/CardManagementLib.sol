// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library CardManagementLib {
    struct CardType {
        string name;
        string breed;
        string[3] attacks;
        uint256 life;
        string img; // IPFS CID
    }

    struct CreateCardTypeParams {
        string[] firstNames;
        string[] lastNames;
        string[] breedTypes;
        string[] attacks;
        string[] specialAttacks;
        string[] rareBreeds;
        string[] rareAttacks;
        string[] rareSpecialAttacks;
        string[] imgSources;
        uint256 maxLife;
        uint256 rand;
    }

    struct CardData {
        mapping(uint256 => CardType) cardTypes;
        uint256 cardTypeLength;
    }

    function createCardType(
        CardData storage data,
        CreateCardTypeParams memory params
    ) internal returns (uint256) {
        data.cardTypeLength++;
        uint256 id = data.cardTypeLength;

        bool isRareBreed = (params.rand % 100) < 5; // 5% chance for rare breed
        bool isRareAttack = (params.rand % 100) < 10; // 10% chance for rare attack
        bool isRareSpecialAttack = (params.rand % 100) < 15; // 15% chance for rare special attack

        // Selecting attacks based on rarity and randomness
        string[3] memory selectedAttacks;
        selectedAttacks[0] = isRareAttack ? params.rareAttacks[params.rand % params.rareAttacks.length] : params.attacks[params.rand % params.attacks.length];
        selectedAttacks[1] = params.attacks[(params.rand + 1) % params.attacks.length];
        selectedAttacks[2] = isRareSpecialAttack ? params.rareSpecialAttacks[params.rand % params.rareSpecialAttacks.length] : params.specialAttacks[params.rand % params.specialAttacks.length];

        // Simplify name creation by pre-calculating indices
        uint256 firstNameIndex = params.rand % params.firstNames.length;
        uint256 lastNameIndex = params.rand % params.lastNames.length;
        string memory fullName = string(abi.encodePacked(params.firstNames[firstNameIndex], " ", params.lastNames[lastNameIndex]));

        // Constructing the new CardType
        CardType memory newCardType = CardType({
            name: fullName,
            breed: isRareBreed ? params.rareBreeds[params.rand % params.rareBreeds.length] : params.breedTypes[params.rand % params.breedTypes.length],
            attacks: selectedAttacks,
            life: (params.rand % params.maxLife) + 1,
            img: params.imgSources[params.rand % params.imgSources.length]
        });

        data.cardTypes[id] = newCardType;

        return id;
    }

}
