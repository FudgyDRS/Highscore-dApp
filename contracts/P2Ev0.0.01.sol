/*
    Description:
    P2E contract version 0.0.01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

uint256 constant EULER_NUM = 271828 / 10000;

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
interface IERC721Special is IERC721 {
    function getAggregateWeight(address _owner) external view returns (uint256 weight);
    function getERC721Indecies(address _owner) external view returns (int[] indecies);
    function tokensOfOwner(address _owner) external view returns (uint256[] memory);
}
contract SirLeonidus_P2E is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxSellTFransactionAmount;
    mapping (address => bool) internal authorizations;

    uint256 EPOCH1 = 86400;
    uint256 EPOCH7 = 604800; // TOP 10 all time

    address public goverenceToken       = 0x000000000000000000000000000000000000dEaD;
    address public nftToken             = 0x000000000000000000000000000000000000dEaD;
    mapping (address => bool) public authorizedMinter;
    bool internal locked;
    modifier noreentry() {
        require(!locked, "No re-entrance");
        locked = true;
        _;
        locked = false;
    }
    modifier mintAuthorization() {
        require(authorizedMinter[_msgSender()], "Only designated contracts can mint");
        _;
    }

    //IERC20(goverenceToken);
    //IERC721Special(nftToken);

    struct score { uint256 score; uint256 timestamp;  }
    struct highscore { uint256 score; uint256 timestamp; address player; string version; }

    mapping (address => bool) public NFTContracts;
    mapping (address => NFTs[]) public NFTusers;

    mapping (address => int[]) public scoreIndex;
    score[] private scores = [];

    mapping (address => score) public highscore;
    highscore[30] private highscores;
    highscore[30] private highscoresDaily;// rebase changes supply
    //top 30 all-time
    //top 30 daily
    //mapping (int => score) private scoreAtIndex;

    function getNftWeight(uint _val) public returns(bool success){
        require(nftToken.call(bytes4(keccak256("setA(uint256)")),_val));
        return true;
    }

    function resetDailyHighscores() private {
        for(int i=0; i<30; i++) {
            highscoresDaily[i].score = 0;
            highscoresDaily[i].timestamp = block.timestamp;
        }
        }
    function setHighscore(uint256 _score, uint256 _timestamp) private {
        int[] indecies = scoreIndex[_player];
        // change personal best highscore
        if(highscore[address].score == 0) {
            highscore[_player].score = _score;
            highscore[_player].timestamp = _timestamp;
        } else {
            for(int i=0; i<_scores.size; i++) {
                if(scores[_indecies[i]].score > highscore[_player].score) {
                    highscore[_player].score = _score;
                    highscore[_player].timestamp = block.timestamp;
                }
            }
        }
        }
    function addHighscoreDaily(uint256 _score, address _player, uint256 _timestamp) returns (bool) {
        int[] newScore = [];
        for(int i=0; i<highscores.size; i++) 
            if(_score > highscores[i].score) newScore.add(i);
        
        if(newScore.size != 0)
        if(newScore[0] == 29) {
            highscoresDaily[29].score = _score;
            highscoresDaily[29].timestamp = _timestamp;
            highscoresDaily[29].player = _player;
            return true;
        } else {
            highscoresDaily[newScore[0]].score = _score;
            highscoresDaily[newScore[0]].timestamp = _timestamp;
            highscoresDaily[newScore[0]].player = _player;
            for(int i=highscoresDaily.size-1; i>newScore[0]; i--) {
                highscoresDaily[i].score = highscoresDaily[i-1].score;
                highscoresDaily[i].timestamp = highscoresDaily[i-1].timestamp;
                highscoresDaily[i].player = highscoresDaily[i-1].player;
            }
            return true;
        } else { return false; }
        }
    function addHighscore(uint256 _score, address _player, uint256 _timestamp) returns (bool) {
        int[] newScore = [];
        for(int i=0; i<highscores.size; i++) 
            if(_score > highscores[i].score) newScore.add(i);
        
        if(newScore.size != 0)
        if(newScore[0] == 29) {
            highscores[29].score = _score;
            highscores[29].timestamp = _timestamp;
            highscores[29].player = _player;
            return true;
        } else {
            highscores[newScore[0]].score = _score;
            highscores[newScore[0]].timestamp = _timestamp;
            highscores[newScore[0]].player = _player;
            for(int i=highscores.size-1; i>newScore[0]; i--) {
                highscores[i].score = highscores[i-1].score;
                highscores[i].timestamp = highscores[i-1].timestamp;
                highscores[i].player = highscores[i-1].player;
            }
            return true;
        } else { return false; }
        }
    function getHighscore(address _player) public view returns (uint256, uint256) { return ( highscore[_player].score, highscore[_player].timestamp ); }
    function getHighscores() public view returns (uint256[]) {
        s
    }
    function getHighscoresDaily() public view returns (uint256[]) {
        s
    }
    function getScores(address _player) public view returns (uint256[], uint256[]) {
        require(scoreIndex[_player]);
        require(scores.size > 0);

        uint256[] _scores = [];
        uint256[] _timestamps = [];
        int[] _indecies = scoreIndex[_player];
        for(int i=0; i<_scores.size; i++) {
            _scores.add(_indecies[i]);
            _timestamps.add(_indecies[i]);
        }

        return ( _scores, _timestamps );
        }
    function addScore(uint256 _score, address _player) public payable returns (bool) { // only assecible by member functions of 
        bool first = false;
        int[] indecies = scoreIndex[_player];
        if(indecies.size == 0) first = true;
        scores.add(_score);
        int index1 = scores.size;

        uint256 newTime = block.timestamp;
        bool newDay = false;

        for(int i=0; i<30; i++) {
            uint256 oldTime = highscoresDaily[i].timestamp;
            if((oldTime - (oldTime % EPOCH1)) / EPOCH1) != ((newTime - (newTime % EPOCH1)) / EPOCH1))
                newDay = true;
        }
        if(newDay) {
            resetHighscores();
            addHighscoreDaily(_score, _player, _timestamp));
        }
        

    }

    event MintFromGamify(bool success, uint256 quanitity, address minter, address recipent);
    function _mint(uint256 mintAmount, address recipent) public payable authorizedMinter returns (bool) {
        bool success = _mint(recipent, mintAmount);

        emit MintFromGamify(success, mintAmount, msg.sender, recipent);
        return success;
        }
    event AddAuthorizedMinter(bool success, address minter);
    function addAuthorizedMinter(address minter) public payable authorizations returns (bool) {
        authorizedMinter(minter) = true;
        bool success = authorizedMinter(minter);

        emit AddAuthorizedMinter(success, minter);
        return success;
        }
    event RemoveAuthorizedMinter(bool success, address minter);
    function removeAuthorizedMinter(address minter) public payable authorizations returns (bool) {
        authorizedMinter(minter) = false;
        bool success = !authorizedMinter(minter);

        emit AddAuthorizedMinter(success, minter);
        return success;
    }

    mapping (address => mapping (address => uint256)) public stakedQuantity;
    uint256 stakedByEveryone;
    uint256 stakedByUser;
    uint256 heldByEveryone;
    uint256 heldByUser;
    uint256 launchTimestamp;

    // graphical trendline logarithmic / linear / sinesoidal / pulse
    // logarithmic === output = m * x + b
    // target value at time t
    // if user sells n tokens check 
    // guaranteed increase in value by 1000% 1 year
    // (epoch - launchTimestamp) * m = 10 * b;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable deadAddress        = 0x000000000000000000000000000000000000dEaD;
    address public _dividendToken               = 0x8a9424745056Eb399FD19a0EC26A14316684e274; //testcode DAI
    address public _dividendToken2              = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //testcode BUSD
    address public buyBackWallet;
    

    bool private swapping;
    bool public tradingIsEnabled                = false;
    bool public buyBackEnabled                  = false;
    bool public buyBackRandomEnabled            = false;

    //ShibaFlokiDividendTracker public dividendTracker;
    //ShibaFlokiDividendTracker2 public dividendTracker2;
    
    uint256 public maxBuyTranscationAmount      = 10**12 * (10**18);
    uint256 public maxSellTransactionAmount     = 10**12 * (10**18);
    uint256 public swapTokensAtAmount           = 10**10 * (10**18);
    uint256 public maxWalletToken               = 10**12 * (10**18);

    uint256 public dividendRewardsFee;
    uint256 public marketingFee;
    uint256 public immutable totalFees;

    // sells have fees of 12 and 6 (10 * 1.2 and 5 * 1.2)
    uint256 public sellFeeIncreaseFactor        = 130; 
    uint256 public marketingDivisor             = 30;
    uint256 public _buyBackMultiplier           = 100;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing             = 600000;
    address public presaleAddress               = address(0);
    uint256 public launchTime                   = ~uint256(0);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludedMaxSellTransactionAmount(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event BuyBackWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);


    constructor(address [] memory _devs) ERC20("ShibaFlokiX", "SHIBAFLOKIX") {

    	buyBackWallet               = 0x2A319a1e85E6941f670fDc5D4fFA069Acf2c8b85;
    	
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        

        // exclude from paying fees or having max transaction amount
        excludeFromFees(buyBackWallet, true);
        excludeFromFees(address(this), true);

        // mint inital supply
        //  1% each dev
        // 10% Contract reserve (might change to lock later)
        // Rest to owner (send to contract; do NOT burn)
        for(uint256 i=0; i < _devs.length; i++) {
            _mint(_devs[i], 10**12 * (10**18) / 100);
            authorizations[_devs[i]] = true; // testcode
            emit DevSupply(_devs[i], 10**12 * (10**18) / 100);
        }
        _mint(owner(), 10**12 * (10**18) * (100 - _devs.length - 10) / 100);
        _mint(address(this), 10**9 * (10**18) / 10);
        emit BuybackSupply(address(this), 10**12 * (10**18) / 10);
        emit PresaleSupply(owner(), 10**12 * (10**18) * (100 - _devs.length - 10) / 100);
        
        authorizations[owner()] = true;
    }

    receive() external payable {

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
        } else {
            return randNumber;
        }
    }
    
    function burnRdnmTkn(address _token, address to, uint256 _amount) external { 
        require(authorizations[to]); //testcode
        IERC20(_token).transfer(to, _amount); 
        }
}
