# Which tx in block 257,343 spends the coinbase output of block 256,128?

# Definição dos blocos relevantes
BLOCK_SPENDING=257343
BLOCK_COINBASE=256128

# Obtém o hash do bloco 256128
COINBASE_BLOCK_HASH=$(bitcoin-cli getblockhash $BLOCK_COINBASE 2>/dev/null)
if [ -z "$COINBASE_BLOCK_HASH" ]; then
  echo "Error for 1 $BLOCK_COINBASE"
  exit 1
fi

# Obtém o TXID da coinbase do bloco 256128
COINBASE_TXID=$(bitcoin-cli getblock $COINBASE_BLOCK_HASH 2 2>/dev/null | jq -r '.tx[0].txid')
if [ -z "$COINBASE_TXID" ] || [ "$COINBASE_TXID" == "null" ]; then
  echo "Error for block1 $BLOCK_COINBASE"
  exit 1
fi

# Obtém o hash do bloco 257343
BLOCK_SPENDING_HASH=$(bitcoin-cli getblockhash $BLOCK_SPENDING 2>/dev/null)
if [ -z "$BLOCK_SPENDING_HASH" ]; then
  echo "Error for 2 $BLOCK_SPENDING"
  exit 1
fi

# Obtém todas as transações do bloco 257343
TRANSACTIONS=$(bitcoin-cli getblock $BLOCK_SPENDING_HASH 2 2>/dev/null | jq -c '.tx[]')
if [ -z "$TRANSACTIONS" ]; then
  echo "Error for block2 $BLOCK_SPENDING"
  exit 1
fi

# Percorre todas as transações para verificar se alguma gasta a coinbase de 256128
while read -r tx; do
  TXID=$(echo "$tx" | jq -r '.txid')
  INPUT_TXIDS=$(echo "$tx" | jq -r '.vin[].txid // empty')

  # Verifica se a coinbase TXID está nas entradas
  if echo "$INPUT_TXIDS" | grep -q "$COINBASE_TXID"; then
    echo "$TXID"
    exit 0
  fi
done <<< "$TRANSACTIONS"

# Se nada foi encontrado
echo "Nenhuma transacao encontrada $BLOCK_COINBASE"
exit 1
