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
        string[] breedTypes;
        string[] attacks;
        string[] specialAttacks;
        string[] rareBreeds;
        string[] rareAttacks;
        string[] rareSpecialAttacks;
        string[] imgSources;
        string[] rareImageSources;
        uint256 maxLife;
    }

    struct CardData {
        mapping(uint256 => CardType) cardTypes;
        uint256 cardTypeLength;
    }

    function generateRandom(uint256 seed, uint256 mod) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed))) % mod;
    }

    function createCardType(
        CardData storage data,
        CreateCardTypeParams memory params
    ) internal returns (uint256) {
        data.cardTypeLength++;
        uint256 id = data.cardTypeLength;

        uint256 rand = generateRandom(id, params.firstNames.length + params.breedTypes.length);

        bool isRareBreed = generateRandom(rand, 100) < 5; // 5% chance for rare breed
        bool isRareAttack = generateRandom(rand + 1, 100) < 10; // 10% chance for rare attack
        bool isRareSpecialAttack = generateRandom(rand + 2, 100) < 15; // 15% chance for rare special attack
        bool isRareImage = generateRandom(rand + 3, 100) < 5; // 5% chance for rare image

        string[3] memory selectedAttacks;
        selectedAttacks[0] = isRareAttack ? params.rareAttacks[generateRandom(rand, params.rareAttacks.length)] : params.attacks[generateRandom(rand, params.attacks.length)];
        selectedAttacks[1] = params.attacks[generateRandom(rand + 1, params.attacks.length)];
        selectedAttacks[2] = isRareSpecialAttack ? params.rareSpecialAttacks[generateRandom(rand + 2, params.rareSpecialAttacks.length)] : params.specialAttacks[generateRandom(rand + 3, params.specialAttacks.length)];

        uint256 firstNameIndex = generateRandom(rand, params.firstNames.length);
        string memory breed = isRareBreed ? params.rareBreeds[generateRandom(rand + 4, params.rareBreeds.length)] : params.breedTypes[generateRandom(rand + 5, params.breedTypes.length)];
        string memory fullName = string(abi.encodePacked(params.firstNames[firstNameIndex], " ", breed));

        CardType memory newCardType = CardType({
            name: fullName,
            breed: breed,
            attacks: selectedAttacks,
            life: (generateRandom(rand + 6, params.maxLife) + 1),
            img: isRareImage ? params.rareImageSources[generateRandom(rand + 7, params.rareImageSources.length)] : params.imgSources[generateRandom(rand + 8, params.imgSources.length)]
        });

        data.cardTypes[id] = newCardType;

        return id;
    }
}
