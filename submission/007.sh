# Only one single output remains unspent from block 123,321. What address was it sent to?

#!/bin/bash

# Obtém o hash do bloco 123321
blockhash=$(bitcoin-cli getblockhash 123321) || { 
    echo "ERRO: Falha ao obter hash do bloco 123321" >&2
    exit 1
}

# Obtém lista de transações do bloco
txids=$(bitcoin-cli getblock "$blockhash" 1 | jq -r '.tx[]') || {
    echo "ERRO: Falha ao listar transações do bloco" >&2
    exit 1
}

# Varredura sequencial das transações
for txid in $txids; do
    # Obtém detalhes completos da transação
    tx_data=$(bitcoin-cli getrawtransaction "$txid" 1) || continue
    
    # Conta número de outputs
    vout_count=$(echo "$tx_data" | jq '.vout | length')
    
    # Verifica cada output
    for ((vout=0; vout<vout_count; vout++)); do
        # Consulta UTXO
        txout=$(bitcoin-cli gettxout "$txid" "$vout")
        
        if [[ "$txout" != "null" && -n "$txout" ]]; then
            # Extrai endereço diretamente
            address=$(echo "$txout" | jq -r '.scriptPubKey.address')
            
            # Decodifica script se necessário
            if [[ "$address" == "null" || -z "$address" ]]; then
                script_hex=$(echo "$txout" | jq -r '.scriptPubKey.hex')
                address=$(bitcoin-cli decodescript "$script_hex" | jq -r '.addresses[0]')
            fi
            
            # Retorna endereço válido
            if [[ -n "$address" && "$address" != "null" ]]; then
                echo "$address"
                exit 0
            fi
        fi
    done
done

echo "ERRO: Nenhum UTXO encontrado no bloco 123321" >&2
exit 1
