defmodule AlphabetCipher.Coder do

  @doc """
  Uses the given key to encode the given message
  """
  @spec encode(string, string) :: string
  def encode(key, message) do
    match_chars(key, message)
    |> transform_chars(&(encode_char(&1)))
    |> List.to_string
  end

  @doc """
  Uses the given key to decode the given ciphertext
  """
  @spec decode(string, string) :: string
  def decode(key, message) do
    match_chars(key, message)
    |> transform_chars(&(decode_char(&1)))
    |> List.to_string
  end

  @doc """
  Uses the given ciphertext and message to find the key
  """
  @spec decipher(string, string) :: string
  def decipher(cipher, message) do
    match_chars(cipher, message)
    |> transform_chars(&(extract_key_char(&1)))
    |> find_repeat
    |> List.to_string
  end

  @doc """
  Matches the characters of the key to characters of the message
  """
  @spec match_chars(string, string) :: [{char, char}]
  def match_chars(key, message) when is_binary(key) do
    key_cycle = String.to_char_list(key) |> Stream.cycle
    String.to_char_list(message) |> Enum.zip(key_cycle)
  end
  def match_chars(key, message) when is_list(key) do
    key_cycle = Stream.cycle(key)
    message |> Enum.zip(key_cycle)
  end

  @doc """
  Transforms the list of characters using the given function
  """
  @spec transform_chars(list, function) :: char_list
  def transform_chars(char_list, transformation) do 
    Enum.map(char_list, transformation)
  end

  @doc """
  Returns the encoded character using the given message and key characters
  """
  @spec encode_char({char, char}) :: char
  def encode_char({message_char, key_char}) do 
    Enum.at(alphabet, rem( index_of(message_char) + index_of(key_char), 26))
  end

  @doc """
  Returns the decoded character using the given cipher and key characters
  """
  @spec decode_char({char, char}) :: char
  def decode_char({cipher_char, key_char}) do 
    Enum.at(alphabet, rem( ( index_of(cipher_char) - index_of(key_char) + 26 ), 26))
  end

  @doc """
  Returns the character that was used as the key for this encoding
  """
  @spec extract_key_char({char, char}) :: char
  def extract_key_char({message_char, cipher_char}) do 
    Enum.at(alphabet, rem( ( index_of(cipher_char) - index_of(message_char) + 26 ), 26))
  end

  @doc """
  Finds the repeated sequence in the given text
  """
  @spec find_repeat(char_list) :: char_list
  def find_repeat(key_chars) do 
    Enum.reduce(1..Enum.count(key_chars), nil, fn len, key ->
      candidate = Enum.slice(key_chars, 0..len)

      if !key && repeats(key_chars, candidate) do
        candidate
      else
        key 
      end

    end)
  end

  def repeats(list, pattern) do 
    match_chars(pattern, list)
    |> Enum.reduce(true, fn {char_1, char_2}, matches ->
      if char_1 == char_2 do
        # Pass along whether it already matches
        matches
      else
        false
      end
    end)
  end

  @doc """
  Returns the alphabet as a char list
  """
  @spec alphabet() :: char_list
  def alphabet do 
    Enum.to_list(?a..?z)
  end

  @doc """
  Returns the index of the given character within the alphabet
  """
  @spec index_of(char) :: integer
  def index_of(char) do 
    Enum.find_index(alphabet, &(&1 == char))
  end

end
