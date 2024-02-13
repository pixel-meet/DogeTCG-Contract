// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library CardManagementLib {
    struct CardType {
        string name;
        string breed;
        string[3] attacks;
        uint256 life;
        string img;
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

    struct RarityParams {
        uint256 randBase;
        bool isRareBreed;
        bool isRareAttack;
        bool isRareSpecialAttack;
        bool isRareImage;
    }

    struct CardCreationContext {
        CreateCardTypeParams params;
        RarityParams rarity;
        uint256 id;
    }

    function generateRandom(uint256 seed, uint256 mod) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, seed))) % mod;
    }

    function createCardType(CardData storage data, CreateCardTypeParams memory params) internal returns (uint256) {
        data.cardTypeLength++;
        uint256 id = data.cardTypeLength;
        RarityParams memory rarity = computeRarityParams(id, params);

        CardCreationContext memory ctx = CardCreationContext({
            params: params,
            rarity: rarity,
            id: id
        });

        CardType memory newCardType = constructCardType(ctx);
        data.cardTypes[id] = newCardType;

        return id;
    }

    function constructCardType(CardCreationContext memory ctx) internal view returns (CardType memory) {
        string memory breed = selectBreed(ctx.params, ctx.rarity);
        string memory fullName = constructFullName(ctx.params.firstNames[generateRandom(ctx.rarity.randBase, ctx.params.firstNames.length)], breed);

        return CardType({
            name: fullName,
            breed: breed,
            attacks: selectAttacks(ctx.params, ctx.rarity),
            life: generateRandom(ctx.rarity.randBase + 6, ctx.params.maxLife) + 1,
            img: selectImage(ctx.params, ctx.rarity)
        });
    }

    function computeRarityParams(uint256 id, CreateCardTypeParams memory params) internal view returns (RarityParams memory) {
        uint256 randBase = generateRandom(id, params.firstNames.length + params.breedTypes.length);
        return RarityParams({
            randBase: randBase,
            isRareBreed: generateRandom(randBase, 100) < 5,
            isRareAttack: generateRandom(randBase + 1, 100) < 10,
            isRareSpecialAttack: generateRandom(randBase + 2, 100) < 15,
            isRareImage: generateRandom(randBase + 3, 100) < 5
        });
    }

    function selectAttacks(CreateCardTypeParams memory params, RarityParams memory rarity) internal view returns (string[3] memory) {
        string[3] memory selectedAttacks;
        selectedAttacks[0] = rarity.isRareAttack 
            ? params.rareAttacks[generateRandom(rarity.randBase, params.rareAttacks.length)] 
            : params.attacks[generateRandom(rarity.randBase, params.attacks.length)];
        selectedAttacks[1] = params.attacks[generateRandom(rarity.randBase + 1, params.attacks.length)];
        selectedAttacks[2] = rarity.isRareSpecialAttack 
            ? params.rareSpecialAttacks[generateRandom(rarity.randBase + 2, params.rareSpecialAttacks.length)] 
            : params.specialAttacks[generateRandom(rarity.randBase + 3, params.specialAttacks.length)];
        return selectedAttacks;
    }

    function selectBreed(CreateCardTypeParams memory params, RarityParams memory rarity) internal view returns (string memory) {
        return rarity.isRareBreed 
            ? params.rareBreeds[generateRandom(rarity.randBase + 4, params.rareBreeds.length)] 
            : params.breedTypes[generateRandom(rarity.randBase + 5, params.breedTypes.length)];
    }

    function constructFullName(string memory firstName, string memory breed) internal pure returns (string memory) {
        return string(abi.encodePacked(firstName, " ", breed));
    }

    function selectImage(CreateCardTypeParams memory params, RarityParams memory rarity) internal view returns (string memory) {
        return rarity.isRareImage 
            ? params.rareImageSources[generateRandom(rarity.randBase + 7, params.rareImageSources.length)] 
            : params.imgSources[generateRandom(rarity.randBase + 8, params.imgSources.length)];
    }

    function constructCardType(string memory name, string memory breed, string[3] memory attacks, uint256 life, string memory img) internal pure returns (CardType memory) {
        return CardType({
            name: name,
            breed: breed,
            attacks: attacks,
            life: life,
            img: img
        });
    }
}
