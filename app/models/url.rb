# frozen_string_literal: true

class Url < ApplicationRecord
  # scope :latest, -> {}

  has_many :clicks , class_name: "Click"

  def valid_url?
    url = URI.parse(self.original_url) rescue false
    url.kind_of?(URI::HTTPS) || url.kind_of?(URI::HTTP)
  end

  def self.pick_slug

    # 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P
    # A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
    map = {
      "0" => "A",
      "1" => "B",
      "2" => "C",
      "3" => "D",
      "4" => "E",
      "5" => "F",
      "6" => "G",
      "7" => "H",
      "8" => "I",
      "9" => "J",
      "a" => "K",
      "b" => "L",
      "c" => "M",
      "d" => "N",
      "e" => "O",
      "f" => "P",
      "g" => "Q",
      "h" => "R",
      "i" => "S",
      "j" => "T",
      "k" => "U",
      "l" => "V",
      "m" => "Z",
      "n" => "X",
      "o" => "Y",
      "p" => "Z",
    }

    # AAAAA to ZZZZZ    so it the 26 power of 5 minus 1
    chars = rand(0..11881375).to_s(26) #  26.pow 5 = 11881376  , pick a number between 0 and 11881375
    converted = ""
    # convert using map
    chars.each_char do |char|
      converted += map[char]
    end
    # will add the missing AAA for the small numbers 0 to AAA.
    (5 - converted.length).times do
      converted = "A#{converted}"
    end

    return self.pick_slug if Url.exists?(short_url: converted) # if already exists pick another slug
    converted
  end

end
