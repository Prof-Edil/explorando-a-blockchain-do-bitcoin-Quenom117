# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

#!/bin/bash

# Definir o TXID da transação fornecida
TXID="37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517"

# Obter os detalhes da transação de entrada
TX_DATA=$(bitcoin-cli getrawtransaction "$TXID" true)

# Inicializar um array para armazenar chaves públicas únicas
declare -A PUBKEYS

# Iterar sobre cada input da transação
for INDEX in $(echo "$TX_DATA" | jq -r '.vin | to_entries | .[].key'); do
    # Obter os dados do input
    INPUT=$(echo "$TX_DATA" | jq -r ".vin[$INDEX]")

    # Obter o TXID da transação de entrada
    INPUT_TXID=$(echo "$INPUT" | jq -r '.txid')

    # Obter os detalhes da transação de entrada
    INPUT_TX=$(bitcoin-cli getrawtransaction "$INPUT_TXID" true)

    # Primeiro, tentar extrair a chave pública de scriptPubKey (P2PKH, P2SH-P2PKH)
    SCRIPT_PUBKEYS=$(echo "$INPUT_TX" | jq -r '.vout[].scriptPubKey.asm' | tr ' ' '\n' | grep -E '^(02|03)[0-9a-fA-F]{64}$')

    # Se não encontramos chaves públicas no scriptPubKey, verificar no witness (SegWit)
    if [[ -z "$SCRIPT_PUBKEYS" ]]; then
        WITNESS_PUBKEY=$(echo "$INPUT" | jq -r '.witness | .[-1]' | grep -E '^(02|03)[0-9a-fA-F]{64}$')
        if [[ -n "$WITNESS_PUBKEY" ]]; then
            SCRIPT_PUBKEYS=$WITNESS_PUBKEY
        fi
    fi

    # Adicionar as chaves públicas extraídas ao array associativo
    for PUB in $SCRIPT_PUBKEYS; do
        PUBKEYS["$PUB"]=1
    done
done

# Converter array associativo para um array normal
PUBKEYS_LIST=("${!PUBKEYS[@]}")

# Verificar se temos exatamente 4 chaves públicas
if [[ ${#PUBKEYS_LIST[@]} -ne 4 ]]; then
    echo "Erro: Foram encontradas ${#PUBKEYS_LIST[@]} chaves públicas, mas são necessárias exatamente 4." >&2
    exit 1
fi

# Criar um JSON válido com as 4 chaves públicas
PUBKEYS_JSON=$(printf '%s\n' "${PUBKEYS_LIST[@]}" | jq -R . | jq -s .)

# Criar um endereço multisig 1-de-4
bitcoin-cli createmultisig 1 "$PUBKEYS_JSON" | jq -r '.address'
