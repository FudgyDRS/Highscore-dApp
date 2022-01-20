/*
    Description:
    P2E contract version 0.0.03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

uint256 constant EULER_NUM = 271828; // EULAR_NUM / 10000

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) { return payable(msg.sender); }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
        }
    }
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) { return _owner; }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        }
    }

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    }
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
    function name() public view virtual returns (string memory) { return _name; }
    function symbol() public view virtual returns (string memory) { return _symbol; }
    function decimals() public view virtual returns (uint8) { return _decimals; }
    function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
        }
    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
        }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
        }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
        }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
        }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        }
    function _setupDecimals(uint8 decimals_) internal virtual { _decimals = decimals_; }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    }
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
        }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
        }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
        }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
        }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
        }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
        }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
        }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
        }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
        }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
        }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
        }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
        }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
        }
    }
interface IUniswapV2Factory {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    }
interface IUniswapV2Pair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    }
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    }
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    }

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    }
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    }
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
    }
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
    }
interface IERC721Special {
    function getAggregateWeight(address _owner) external view returns (uint256);
    function getERC721Indecies(address _owner) external view returns (int[] memory);
    function tokensOfOwner(address _owner) external view returns (uint256[] memory);
    function getNftWeight(address _owner) external view returns(uint256);
}
interface IERC20Special {
    function mintFromGamify(uint256 _amount, address _recipient) external payable returns (bool);
}
contract SirLeonidus_P2E is ERC20, Ownable {
    mapping (address => bool) internal authorizations;
    mapping (address => bool) public authorizedMinter;

    uint256 EPOCH1 = 86400;
    uint256 EPOCH7 = 604800; // TOP 10 all time

    address public goverenceToken = 0x000000000000000000000000000000000000dEaD;
    address public nftToken       = 0x000000000000000000000000000000000000dEaD;

    string public version;
// ----------------------------------------------------------------------------
    
    bool internal locked;
    modifier noreentry() {
        require(!locked, "No re-entrance");
        locked = true;
        _;
        locked = false;
        }
    modifier mintAuthorization() { require(authorizedMinter[_msgSender()], "Only designated contracts can mint"); _; }

    struct score { uint256 score; uint256 timestamp; string version; }
    struct highscore { uint256 score; uint256 timestamp; address player; string version; }

    mapping (address => bool) public NFTRewardsEnabled;
    address[] public NFTContracts;

    mapping (address => uint256[]) public scoreIndex;
    score[] private scores;

    mapping (address => score) public playerHighscore;
    highscore[30] private highscores;          //top 30 all-time
    highscore[30] private highscoresDaily;     //top 30 daily

    function getVersion() public view returns(string memory) { return version; }
    function setVersion(string memory _version) public payable onlyOwner { version = _version; }
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {  i++; }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) { bytesArray[i] = _bytes32[i]; }
        return string(bytesArray);
        }
    function bytes32ToUint256(bytes32 bs, uint start) internal pure returns (uint) {
        require(bs.length >= start + 32, "slicing out of range");
        uint x;
        assembly { x := mload(add(bs, add(0x20, start))) }
        return x;
        }
    function rand() public view returns(uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / 
                    (block.timestamp)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / 
                    (block.timestamp)) + block.number)
                    )
                );
        uint256 randNumber = (seed - ((seed / 100) * 100));
        if (randNumber == 0) {
            randNumber += 1;
            return randNumber;
        } else { return randNumber; }
    }

    function resetDailyHighscores() internal {
        for(uint256 i=0; i<30; i++) {
            highscoresDaily[i].score = 0;
            highscoresDaily[i].timestamp = block.timestamp;
            highscoresDaily[i].version = getVersion();
        }
        }
    function addPlayerHighscore(uint256 _score, address _player, uint256 _timestamp) internal returns (bool) {
        uint256[] memory _indecies = scoreIndex[_player];
        // change personal best highscore
        if(playerHighscore[_player].score == 0) {
            playerHighscore[_player].score = _score;
            playerHighscore[_player].timestamp = _timestamp;
            playerHighscore[_player].version = getVersion();
            return true;
        } else {
            for(uint256 i=0; i<_indecies.length; i++) {
                if(scores[_indecies[i]].score > playerHighscore[_player].score) {
                    playerHighscore[_player].score = _score;
                    playerHighscore[_player].timestamp = _timestamp;
                    playerHighscore[_player].version = getVersion();
                    return true;
                }
            }
        }
        return false;
        }
    function addHighscoreDaily(uint256 _score, address _player, uint256 _timestamp) internal returns (bool) {
        int newScore = 999;
        for(int i=0; i<30; i++) 
            if(_score > highscoresDaily[uint256(i)].score) newScore = i;
        
        if(newScore != 999)
        if(newScore == 29) {
            highscoresDaily[29].score = _score;
            highscoresDaily[29].timestamp = _timestamp;
            highscoresDaily[29].player = _player;
            highscoresDaily[29].version = getVersion();
            return true;
        } else {
            highscoresDaily[uint256(newScore)].score = _score;
            highscoresDaily[uint256(newScore)].timestamp = _timestamp;
            highscoresDaily[uint256(newScore)].player = _player;
            for(uint256 i=highscoresDaily.length-1; i>uint256(newScore); i--) {
                highscoresDaily[i].score = highscoresDaily[i-1].score;
                highscoresDaily[i].timestamp = highscoresDaily[i-1].timestamp;
                highscoresDaily[i].player = highscoresDaily[i-1].player;
                highscoresDaily[i].version = getVersion();
            }
            return true;
        }
        return false;
        }
    function addHighscore(uint256 _score, address _player, uint256 _timestamp) internal {
        int newScore = 999;
        for(int i=0; i<30; i++) 
            if(_score > highscores[uint256(i)].score) newScore = i;
        
        if(newScore != 999)
        if(newScore == 29) {
            highscores[29].score = _score;
            highscores[29].timestamp = _timestamp;
            highscores[29].player = _player;
            highscores[29].version = getVersion();
            //return true;
        } else {
            highscores[uint256(newScore)].score = _score;
            highscores[uint256(newScore)].timestamp = _timestamp;
            highscores[uint256(newScore)].player = _player;
            for(uint256 i=highscores.length-1; i>uint256(newScore); i--) {
                highscores[i].score = highscores[i-1].score;
                highscores[i].timestamp = highscores[i-1].timestamp;
                highscores[i].player = highscores[i-1].player;
                highscores[i].version = getVersion();
            }
            //return true;
        }
        //return false;
        }
    function addScore(uint256 _score, address _player) public payable {
        // add score
        scores.push(score(_score, block.timestamp, getVersion()));
        scoreIndex[_player].push(scores.length);

        // test for new day
        uint256 newTime = block.timestamp;
        bool newDay = false;
        for(uint256 i=0; i<30; i++) {
            uint256 oldTime = highscoresDaily[i].timestamp;
            if(((oldTime - (oldTime % EPOCH1)) / EPOCH1) != ((newTime - (newTime % EPOCH1)) / EPOCH1))
                newDay = true;
        }

        //payout
        if(newDay) { 
            if(mintForHighscoreDaily())
                mintForHighscore();
            resetDailyHighscores();
        }

        // check highscore status
        if(addPlayerHighscore(_score, _player, newTime))
            if(addHighscoreDaily(_score, _player, newTime))
                addHighscore(_score, _player, newTime);

        // payout rewards
        // NFTs

    }

    function getHighscore(address _player) public view returns (uint256, uint256, string memory) { return ( playerHighscore[_player].score, playerHighscore[_player].timestamp, playerHighscore[_player].version ); }
    function getHighscores() public view returns (uint256[30] memory, address[30] memory, uint256[30] memory, string[30] memory) {
        uint256[30] memory _scores;
        address[30] memory _players;
        uint256[30] memory _timestamps;
        string[30] memory _version;
        for(uint256 i=0; i<30; i++) {
            _scores[i] = highscores[i].score;
            _players[i] = highscores[i].player;
            _timestamps[i] = highscores[i].timestamp;
            _version[i] = highscores[i].version;
        }
        return (_scores, _players, _timestamps, _version);
        }
    function getHighscoresDaily() public view returns (uint256[30] memory, address[30] memory, uint256[30] memory, string[30] memory) {
        uint256[30] memory _scores;
        address[30] memory _players;
        uint256[30] memory _timestamps;
        string[30] memory _version;
        for(uint256 i=0; i<30; i++) {
            _scores[i] = highscoresDaily[i].score;
            _players[i] = highscoresDaily[i].player;
            _timestamps[i] = highscoresDaily[i].timestamp;
            _version[i] = highscoresDaily[i].version;
        }
        return (_scores, _players, _timestamps, _version);
        }
    function getScores(address _player) external view returns (uint256[] memory, uint256[] memory, string[] memory) {
        require(scoreIndex[_player].length != 0);
        require(scores.length > 0);

        uint256[] memory _scores;
        uint256[] memory _timestamps;
        string[] memory _version;
        for(uint256 i=0; i<scoreIndex[_player].length; i++) {
            _scores[i] = scores[scoreIndex[_player][i]].score;
            _timestamps[i] = scores[scoreIndex[_player][i]].timestamp;
            _version[i] = scores[scoreIndex[_player][i]].version;
        }

        return ( _scores, _timestamps, _version );
    }

    // Possible multiple NFT contracts (all MUST use "getNFTWeight"):
    mapping(address => bool) internal nftContract;                      // NFT > is contract with active rewards
    mapping(address => mapping(address => uint256)) public rewards;     // NFT > user > total rewards
    mapping(address => mapping(address => uint256)) public lastClaim;   // NFT > user > last claim
    mapping(address => uint256) public totalRewards;                    // NFT > overall total rewards
    mapping(address => uint256) internal nftWeight;                     // NFT > top n number of NFTs to calculate reward

    uint256[10] public dailyPayoutRate;
    uint256[10] public weeklyPayoutRate;

    uint256 public dailyPayout;
    uint256 public weeklyPayout;
    uint256 public dayEndTimestamp;
    uint256 public weekEndTimestamp;

    event MintForGamify(bool success, uint256 quanitity, address minter, address recipent);
    event AddAuthorizedMinter(bool success, address minter);
    event RemoveAuthorizedMinter(bool success, address minter);
    // function getNftWeight(address _owner) external noreentry returns(bytes32) {
    //     (bool success, bytes memory result) = nftToken.call(bytes4(keccak256("ownerWeight(address)")),_owner);
    //     return bytes32ToUint256(result);
    //     }
    // function getNftWeight(address _owner, address _token) external noreentry returns(bytes32) {
    //     (bool success, bytes memory result) = _token.call(bytes4(keccak256("ownerWeight(address)")),_owner);
    //     return bytes32ToUint256(result);
    // }

    // add function to add end-to-end encryption (E2EE) to verify source abi request
    //  instantiate the contract with uint256 private _key (key for editing contract state)
    //  key is hashed via keccak256()
    //  add to contract mapping (uint256 => mapping (uint256 => bool)) private providedKeyStatus;
    //  function to generate key data (public pure function)
    //  function to add key
    //  function to edit providedKeyStatus state
    //function mintForGamify(uint256 mintAmount, address _recipent) internal noreentry returns (bool) {
        // mint for NFT rewards
        //bool success = _mint(recipent, mintAmount); 
        // set time restriction: if duration exceeds time cancel reward

        //emit MintForGamify(success, mintAmount, msg.sender, recipent);
    //    return false;
    //    }
    function mintForHighscoreDaily() internal noreentry returns (bool) {
        uint256 newTime = block.timestamp;
        uint256 oldTime = dayEndTimestamp;
        bool success = false;
        if(((oldTime - (oldTime % EPOCH1)) / EPOCH1) != ((newTime - (newTime % EPOCH1)) / EPOCH1)) {
            for(uint256 i=0; i<10; i++) {
                if(highscoresDaily[i].player != address(0) && dailyPayout * dailyPayoutRate[i] != 0) {
                    success = mintReward(dailyPayout * dailyPayoutRate[i] / 100, highscoresDaily[i].player);
                    emit MintForGamify(success, dailyPayout * dailyPayoutRate[i], address(this), highscoresDaily[i].player);
                }
            }
        }
        if(success) dayEndTimestamp = dayEndTimestamp + EPOCH1;
        return success;
        }
    function mintForHighscore() internal noreentry {
        uint256 newTime = block.timestamp;
        uint256 oldTime = weekEndTimestamp;
        bool success = false;
        if(((oldTime - (oldTime % EPOCH7)) / EPOCH7) != ((newTime - (newTime % EPOCH7)) / EPOCH7)) {
            for(uint256 i=0; i<10; i++) {
                if(highscores[i].player != address(0) && weeklyPayout * weeklyPayoutRate[i] != 0) {
                    success = mintReward(weeklyPayout * weeklyPayoutRate[i] / 100, highscores[i].player);
                    emit MintForGamify(success, weeklyPayout * weeklyPayoutRate[i], address(this), highscores[i].player);
                }
            }
        }
        if(success) weekEndTimestamp = weekEndTimestamp + EPOCH7;
        }
    function mintReward(uint256 mintAmount, address _recipient) internal noreentry mintAuthorization returns(bool) {
        //require(block.timestamp - lastClaim[_recipient] > EPOCH1, "Reward already claimed today.");

        //uint256 value = ownerWeight(_recipent) * 10000; // for NFTs
        //(bool success, bytes memory result) = goverenceToken.call(bytes4(keccak256("mintFromGamify(uint256,address)")),mintAmount,_recipient);
        IERC20Special(goverenceToken).mintFromGamify(mintAmount, _recipient);
        //lastClaim[_recipient] = block.timestamp;
        return true;

        //emit mintRewardToNFTOwner(value, _recipent, success);
        // add mintOutput event
        }
    function addAuthorizedMinter(address minter) public payable returns (bool) {
        require(authorizations[msg.sender], "Not authorized to edit this contract");
        authorizedMinter[minter] = true;
        bool success = authorizedMinter[minter];

        emit AddAuthorizedMinter(success, minter);
        return success;
        }
    function removeAuthorizedMinter(address minter) public payable returns (bool) {
        require(authorizations[msg.sender], "Not authorized to edit this contract");
        authorizedMinter[minter] = false;
        bool success = !authorizedMinter[minter];

        emit AddAuthorizedMinter(success, minter);
        return success;
    }

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing             = 600000;
    uint256 public launchTime                   = ~uint256(0);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);


    constructor(address [] memory _devs) ERC20("P2E V1", "P2Ev1") { 
        authorizations[owner()] = true;
        for(uint256 i=0; i<_devs.length; i++)
            authorizations[_devs[i]] = true;

        dailyPayoutRate = [40, 30, 15, 9, 1, 1, 1, 1, 1, 1];
        weeklyPayoutRate = [40, 30, 15, 9, 1, 1, 1, 1, 1, 1];

        dailyPayout = 100;
        weeklyPayout = 500;

        uint256 current = block.timestamp;
        dayEndTimestamp = current - current % EPOCH1 + EPOCH1;
        weekEndTimestamp; current - current % EPOCH7 + EPOCH7;
        }
    receive() external payable {}
    function burnRdnmTkn(address _token, address to, uint256 _amount) external { 
        require(authorizations[to]); //testcode
        IERC20(_token).transfer(to, _amount); 
        }
}
