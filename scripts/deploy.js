const { ethers } = require("hardhat");

(async () => {
    const factory = await ethers.getContractFactory("Forum");
    const contract = await factory.deploy();

    await contract.waitForDeployment();
    console.log(`\u001b[32mContract deployed at address: ${await contract.getAddress()}\u001b[0m`);
})().catch((error) => {
    console.log(error);
    process.exitCode = -1;
})