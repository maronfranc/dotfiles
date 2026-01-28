#!/usr/bin/env bash
API="https://api.kraken.com/0/public/Ticker"

fetch_kraken () {
  local pair="$1"
  local key="$2"

  curl -sf "${API}?pair=${pair}" \
    | jq -r ".result.${key}.c[0]" \
    | LC_NUMERIC=C xargs printf "%.2f"
}

btc_price=$(fetch_kraken "BTCUSD" "XXBTZUSD")
xmr_price=$(fetch_kraken "XMRUSD" "XXMRZUSD")

echo "BTC/USD \$$btc_price"
echo "XMR/USD \$$xmr_price"
