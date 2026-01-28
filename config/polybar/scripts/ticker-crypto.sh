#!/usr/bin/env bash
API="https://api.kraken.com/0/public/Ticker"

fetch_price () {
  local pair="$1"
  local key="$2"

  curl -sf "${API}?pair=${pair}" \
    | jq -r ".result.${key}.c[0]" \
    | LC_NUMERIC=C xargs printf "%.2f"
}

btc_price=$(fetch_price "BTCUSD" "XXBTZUSD")
xmr_price=$(fetch_price "XMRUSD" "XXMRZUSD")

# ɱ$xmr_price
echo "$btc_price|XMR $xmr_price"
