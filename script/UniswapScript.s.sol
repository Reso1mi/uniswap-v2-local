// script/UniswapScript.s.sol
pragma solidity ^0.8.0;
import "forge-std/console.sol";

import "forge-std/Script.sol";
import "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../lib/v2-periphery/contracts/interfaces/IERC20.sol";

contract UniswapScript is Script {
    
    // forge script script/UniswapScript.s.sol:UniswapScript --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
     function run() external {
        uint256 deployerPrivateKey =
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address user = vm.addr(deployerPrivateKey);

        address routerAddress = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6;
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        vm.startBroadcast(deployerPrivateKey);

        address factory = router.factory();
        address weth = router.WETH();
        console.log("Router factory:", factory);
        console.log("Router WETH:", weth);
        console.log("User (should be 0xf39F...266):", user);

        address tokenA = 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318;
        address tokenB = 0x610178dA211FEF7D417bC0e6FeD39F05609AD788;

        // 打印初始余额
        console.log("tokenA balance:", IERC20(tokenA).balanceOf(user));
        console.log("tokenB balance:", IERC20(tokenB).balanceOf(user));

        // 批准 Router
        IERC20(tokenA).approve(routerAddress, 1e18);
        IERC20(tokenB).approve(routerAddress, 1e18);

        // 检查 allowance
        console.log("tokenA allowance to router:", IERC20(tokenA).allowance(user, routerAddress));
        console.log("tokenB allowance to router:", IERC20(tokenB).allowance(user, routerAddress));

        // 添加流动性
        router.addLiquidity(
            tokenA,
            tokenB,
            1e18,
            1e18,
            0,
            0,
            user,
            block.timestamp + 600
        );

        vm.stopBroadcast();
    }
}
