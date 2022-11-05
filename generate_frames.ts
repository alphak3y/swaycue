import { BilliardAbi__factory } from "./types";
import { Wallet } from "fuels";

async function callInit() {
    const contractId = "0x...";
    const wallet = Wallet.generate();
    const contract = BilliardAbi__factory.connect(contractId, wallet);
}