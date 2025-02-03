import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new ride listing",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("drive-dock", "create-ride", [
        types.utf8("Downtown"),
        types.utf8("Airport"),
        types.uint(1234567),
        types.uint(4),
        types.uint(50)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(0);
  },
});

Clarinet.test({
  name: "Can book an available ride",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("drive-dock", "create-ride", [
        types.utf8("Downtown"),
        types.utf8("Airport"),
        types.uint(1234567),
        types.uint(4),
        types.uint(50)
      ], wallet_1.address),
      Tx.contractCall("drive-dock", "book-ride", [
        types.uint(0)
      ], wallet_2.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);
  },
});
