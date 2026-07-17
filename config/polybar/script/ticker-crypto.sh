#!/usr/bin/env bash
API="https://api.kraken.com/0/public/Ticker"

fetch_kraken () {
    local pair="$1"
    local key="$2"

    curl -sf "${API}?pair=${pair}" \
    | jq -r ".result.${key}.c[0]"
}

fetch_kraken_cents() {
    local result=$(fetch_kraken $1 $2)
    echo $result | LC_NUMERIC=C xargs printf "%.2f"
}

fetch_kraken_penny() {
    local result=$(fetch_kraken $1 $2)
    echo $result | LC_NUMERIC=C xargs printf "%.8f"
}

btc_price=$(fetch_kraken_cents "BTCUSD" "XXBTZUSD")
xmr_price=$(fetch_kraken_cents "XMRUSD" "XXMRZUSD")
sui_price=$(fetch_kraken_penny "SUIUSD" "SUIUSD")

echo "BTC/USD \$$btc_price"
echo "XMR/USD \$$xmr_price"
echo "SUI/USD \$$sui_price"
