# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

# Obtendo os 'public keys' dos inputs da transação
PUBKEYS=$(bitcoin-cli getrawtransaction 37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517 true | \
          jq -r '.vin[].scriptSig.asm' | awk '{print $2}' | jq -R -s 'split("\n") | map(select(length > 0))')

# Criando o endereço multisig 1-a-4
bitcoin-cli createmultisig 1 "$PUBKEYS" | jq -r '.address'
