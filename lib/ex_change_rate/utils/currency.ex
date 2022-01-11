defmodule ExChangeRate.Utils.Currency do
  @moduledoc """
  Functions for calculation, casting, conversion and formatting of currencies
  """

  @doc """
  Creates a new currency representation
  """
  def new(value, currency), do: Money.new(value, currency)

  @doc """
  Extracts the value from a currency representation
  """
  def get_value(%Money{amount: amount}), do: amount

  @doc """
  Given two exchange rates in a common base (EUR by default), calculates
  an exchange rate between the two
  """
  @spec calculate_exchange_rate(from_rate :: float(), to_rate :: float()) :: Decimal.t()
  def calculate_exchange_rate(from_rate, to_rate) do
    from_rate = from_rate |> Decimal.from_float() |> Decimal.round(3)
    to_rate = to_rate |> Decimal.from_float() |> Decimal.round(3)

    to_rate
    |> Decimal.div(from_rate)
    |> Decimal.round(3)
  end

  @doc """
  Given an amount, a conversion rate and a target currency, returns
  amount in target currency
  """
  @spec convert(amount :: integer(), rate :: Decimal.t(), target_currency :: String.t()) ::
          Money.t()
  def convert(amount, rate, target_currency) do
    amount
    |> new(target_currency)
    |> Money.multiply(rate)
  end

  @doc """
  Formats given currencies or rates to a string representation
  """
  @spec format_to_string(amount_currency_pair :: Money.t() | Decimal.t()) :: String.t()
  def format_to_string(%Money{} = amount_currency_pair) do
    Money.to_string(amount_currency_pair, separator: ".", delimiter: ",")
  end

  def format_to_string(%Decimal{} = rate) do
    Decimal.to_string(rate, :normal)
  end

  @doc """
  Returns a supported list of currencies
  """
  def supported_currencies_list do
    [
      "AED",
      "AFN",
      "ALL",
      "AMD",
      "ANG",
      "AOA",
      "ARS",
      "AUD",
      "AWG",
      "AZN",
      "BAM",
      "BBD",
      "BDT",
      "BGN",
      "BHD",
      "BIF",
      "BMD",
      "BND",
      "BOB",
      "BRL",
      "BSD",
      "BTC",
      "BTN",
      "BWP",
      "BYN",
      "BYR",
      "BZD",
      "CAD",
      "CDF",
      "CHF",
      "CLF",
      "CLP",
      "CNY",
      "COP",
      "CRC",
      "CUC",
      "CUP",
      "CVE",
      "CZK",
      "DJF",
      "DKK",
      "DOP",
      "DZD",
      "EGP",
      "ERN",
      "ETB",
      "EUR",
      "FJD",
      "FKP",
      "GBP",
      "GEL",
      "GGP",
      "GHS",
      "GIP",
      "GMD",
      "GNF",
      "GTQ",
      "GYD",
      "HKD",
      "HNL",
      "HRK",
      "HTG",
      "HUF",
      "IDR",
      "ILS",
      "IMP",
      "INR",
      "IQD",
      "IRR",
      "ISK",
      "JEP",
      "JMD",
      "JOD",
      "JPY",
      "KES",
      "KGS",
      "KHR",
      "KMF",
      "KPW",
      "KRW",
      "KWD",
      "KYD",
      "KZT",
      "LAK",
      "LBP",
      "LKR",
      "LRD",
      "LSL",
      "LTL",
      "LVL",
      "LYD",
      "MAD",
      "MDL",
      "MGA",
      "MKD",
      "MMK",
      "MNT",
      "MOP",
      "MRO",
      "MUR",
      "MVR",
      "MWK",
      "MXN",
      "MYR",
      "MZN",
      "NAD",
      "NGN",
      "NIO",
      "NOK",
      "NPR",
      "NZD",
      "OMR",
      "PAB",
      "PEN",
      "PGK",
      "PHP",
      "PKR",
      "PLN",
      "PYG",
      "QAR",
      "RON",
      "RSD",
      "RUB",
      "RWF",
      "SAR",
      "SBD",
      "SCR",
      "SDG",
      "SEK",
      "SGD",
      "SHP",
      "SLL",
      "SOS",
      "SRD",
      "STD",
      "SVC",
      "SYP",
      "SZL",
      "THB",
      "TJS",
      "TMT",
      "TND",
      "TOP",
      "TRY",
      "TTD",
      "TWD",
      "TZS",
      "UAH",
      "UGX",
      "USD",
      "UYU",
      "UZS",
      "VEF",
      "VND",
      "VUV",
      "WST",
      "XAF",
      "XAG",
      "XAU",
      "XCD",
      "XDR",
      "XOF",
      "XPF",
      "YER",
      "ZAR",
      "ZMK",
      "ZMW",
      "ZWL"
    ]
  end
end
