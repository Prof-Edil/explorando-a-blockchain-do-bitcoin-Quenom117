# Which public key signed input 0 in this tx:
#   `e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163`

# TXID da transação alvo
TXID="e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163"

# Obter a transação em formato JSON com bitcoin-cli
TX_JSON=$(bitcoin-cli getrawtransaction "$TXID" 1)

# Extrair o terceiro elemento do array txinwitness (índice 2) usando jq
WITNESS_SCRIPT=$(echo "$TX_JSON" | jq -r '.vin[0].txinwitness[2]')

PUBKEY=$(echo "$WITNESS_SCRIPT" | cut -c 5-70)

# Imprimir a chave pública
echo "$PUBKEY"
