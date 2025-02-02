# Using descriptors, compute the taproot address at index 100 derived from this extended public key:
#   `xpub6Cx5tvq6nACSLJdra1A6WjqTo1SgeUZRFqsX5ysEtVBMwhCCRa4kfgFqaT2o1kwL3esB1PsYr3CUdfRZYfLHJunNWUABKftK2NjHUtzDms2`

# Definir o descritor base
DESCRIPTOR="tr(xpub6Cx5tvq6nACSLJdra1A6WjqTo1SgeUZRFqsX5ysEtVBMwhCCRa4kfgFqaT2o1kwL3esB1PsYr3CUdfRZYfLHJunNWUABKftK2NjHUtzDms2/0/100)"

# Obter o descritor completo com checksum
DESCRIPTOR_WITH_CHECKSUM=$(bitcoin-cli getdescriptorinfo "$DESCRIPTOR" | jq -r '.descriptor')

# Derivar o endereço Taproot correspondente e imprimir a saída
bitcoin-cli deriveaddresses "$DESCRIPTOR_WITH_CHECKSUM" | jq -r '.[0]'