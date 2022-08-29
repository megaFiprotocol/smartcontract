// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface IERC20Token {
    function totalSupply() external  returns (uint);
    function balanceOf(address tokenlender) external  returns (uint balance);
    function allowance(address tokenlender, address spender) external  returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenlender, address indexed spender, uint tokens);
}

contract TokenMarket {

    uint immutable baseFee = 10;
    uint immutable baseDiv = 100;
    struct Listing {
    address seller;
    IERC20Token token;
    uint256 unitsAvailable;
    }
    Listing[] public listings;

    //Major events
    event ListingChanged(address indexed seller, uint256 indexed index);
    event RemainingUnit(address indexed seller, uint256 indexed index);
    event AmountBought(uint units, uint cost);

    //this helps to listen a token on the platform
    function list(IERC20Token token,uint256 units) public {
    Listing memory listing = Listing({
    seller: msg.sender,
    token: token,
    unitsAvailable: units
    // priceNumerator: numerator,
    // priceDenominator: denominator
    });
    listings.push(listing);
    emit ListingChanged(msg.sender, listings.length-1);
    }

    //this is to cancel specific listing by the lister
    function cancel(uint256 index) public {
    require(listings[index].seller == msg.sender);
    delete(listings[index]);
    emit ListingChanged(msg.sender, index);
    }

    function viewListing(uint sellerId) public view returns(uint) {
        Listing storage listing = listings[sellerId];
        return listing.unitsAvailable;
    }

    //This performs the function of selling the listed tokens from the lister to the buyer.

    function buy(uint256 index, uint256 units) payable public {
    Listing storage listing = listings[index];

        require(listing.unitsAvailable >= units);
        listing.unitsAvailable -= units;
        require(listing.token.transferFrom(listing.seller, msg.sender, units));

        uint256 cost = (units * baseFee) /
            baseDiv;
        require(msg.value == cost);
        payable(listing.seller).transfer(cost);

    emit ListingChanged(listing.seller, index);
    emit RemainingUnit(listing.seller, listing.unitsAvailable);
    emit AmountBought(units, cost);
    }

}
