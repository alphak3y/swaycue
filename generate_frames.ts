import { BigNumberish, Wallet } from "fuels";
import BN from "./utils/BN";
import { BilliardAbi__factory } from "./types";

const initContractId = "0xb021b238d430b7584c8b86b82372984d2b08221eac1d08e37b22227dd2132218";

export default async function callInit() {
    const wallet = Wallet.generate();
    const contract = BilliardAbi__factory.connect(initContractId, wallet);
    const { transactionId, value } = await contract.functions
    .init(BN.parseUnits("100", 0).toString(), BN.parseUnits(100,0).toString())
    .call();
    console.log(value);
}

callInit();