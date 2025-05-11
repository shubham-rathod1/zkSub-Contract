// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Logic is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Plan {
        uint256 price;
        uint256 cycle;
        address token;
        address payout;
        address provider;
        bool isPrivate;
        bool isActive;
        uint256 maxSubscribers;
    }

    mapping(bytes32 => Plan) public plans;
    mapping(bytes32 => uint256) public subscriptions;
    mapping(address => bytes32[]) public providerPlans;
    mapping(bytes32 => uint256) public planSubscribers;

    bool public isPaused;

    event PlanCreated(
        bytes32 indexed planId,
        address indexed provider,
        address payout,
        address token,
        uint256 price,
        uint256 cycle,
        uint256 maxSubscribers,
        bool isPrivate
    );
    event Subscribed(
        bytes32 indexed zkKey,
        bytes32 indexed planId,
        uint256 expiry
    );
    event PlanDeactivated(bytes32 indexed planId);
    event Paused(uint256 timestamp);
    event Unpaused(uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImpl) internal override onlyOwner {}

    function createPlan(
        bytes32 _planId,
        address _payout,
        address _token,
        uint256 _price,
        uint256 _cycle,
        bool _isPrivate,
        uint256 _maxSubscribers
    ) external {
        require(plans[_planId].price == 0, "Plan already exists");
        require(_token != address(0), "Invalid token");
        require(_payout != address(0), "Invalid payout");
        require(_price > 0, "Invalid price");

        plans[_planId] = Plan({
            price: _price,
            cycle: _cycle,
            token: _token,
            payout: _payout,
            provider: msg.sender,
            isPrivate: _isPrivate,
            isActive: true,
            maxSubscribers: _maxSubscribers
        });

        providerPlans[msg.sender].push(_planId);

        emit PlanCreated(
            _planId,
            msg.sender,
            _payout,
            _token,
            _price,
            _cycle,
            _maxSubscribers,
            _isPrivate
        );
    }

    function deactivatePlan(bytes32 _planId) external onlyProvider(_planId) {
        Plan storage plan = plans[_planId]; 
        require(plan.isActive, "Plan is not active");
        plan.isActive = false;
        emit PlanDeactivated(_planId);
    }

    function subscribe(bytes32 _planId, bytes32 _zkKey) external whenNotPaused {
        Plan memory plan = plans[_planId];
        require(plan.isActive, "Plan is not active");
        if(plan.maxSubscribers > 0) {
            require(planSubscribers[_planId] < plan.maxSubscribers,"Plan is full!");
            planSubscribers[_planId]++;
        }

        IERC20(plan.token).transferFrom(msg.sender,plan.payout,plan.price);

        uint256 expiry = block.timestamp + plan.cycle;
        subscriptions[_zkKey] = expiry;
        emit Subscribed(_zkKey, _planId, expiry);
    }

    function getExpiry(bytes32 _zkKey) external view returns(uint256) {
        return subscriptions[_zkKey];
    }

    function isActive(bytes32 _zkKey) external view returns(bool) {
        return subscriptions[_zkKey] > block.timestamp;
    }

    function getProviderPlan(address _provider) external view returns(bytes32[] memory) {
        return providerPlans[_provider];
    }
//     function isSubscribed(bytes32 zkKey, bytes32 planId) public view returns (bool) {
//     return subscriptions[keccak256(abi.encodePacked(zkKey, planId))] > block.timestamp;
// }

    // Admin Control

    function pause() external onlyOwner {
        isPaused = true;
        emit Paused(block.timestamp);
    }

    function unpause() external onlyOwner {
        isPaused = false;
        emit Unpaused(block.timestamp);
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    modifier onlyProvider(bytes32 _planId) {
    require(plans[_planId].provider == msg.sender, "Not provider");
    _;
}

uint256[50] private __gap;

}
