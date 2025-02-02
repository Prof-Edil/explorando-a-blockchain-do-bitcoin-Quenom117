# How many new outputs were created by block 123,456?

# Obtendo o hash do bloco 123456
BLOCK_HASH=$(bitcoin-cli getblockhash 123456)

# Obtendo os detalhes do bloco e contar os outputs de todas as transações
bitcoin-cli getblock "$BLOCK_HASH" 2 | jq '[.tx[].vout | length] | add'
