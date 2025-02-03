# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`


#!/bin/bash
TXID="37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517"
# Para cada input: se scriptSig.asm existir e não estiver vazio, extrai o segundo token; caso contrário, extrai o segundo item do array txinwitness.
PUBKEYS_JSON=$(bitcoin-cli -rpcconnect=84.247.182.145 getrawtransaction "$TXID" true | \
  jq -r '[.vin[] | if (.scriptSig.asm // "") != "" then (.scriptSig.asm | split(" ") | .[1]) else (.txinwitness[1]) end]')
# Cria o endereço 1-of-4 P2SH multisig a partir dos public keys extraídos e imprime somente o endereço.
bitcoin-cli -rpcconnect=84.247.182.145 createmultisig 1 "$PUBKEYS_JSON" | jq -r '.address'
