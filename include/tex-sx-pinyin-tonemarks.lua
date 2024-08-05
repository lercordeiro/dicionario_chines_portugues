-----------------------------------------------------------------------
--         FILE:  tex-sx-pinyin-tonemarks.lua
--        USAGE:  ./tex-sx-pinyin-tonemarks.lua 
--  DESCRIPTION:  http://tex.stackexchange.com/q/125030
-- REQUIREMENTS:  luatex
--       AUTHOR:  Philipp Gesang (Phg), <phg42.2a@gmail.com>
--      VERSION:  1.0
--      CREATED:  2013-07-23 09:39:04+0200
-----------------------------------------------------------------------
--

local utf                 = utf or require "unicode.utf8"
local lpeg                = require "lpeg"

local unpack              = unpack or table.unpack
local type                = type
local iowrite             = io.write
local stringformat        = string.format
local tableconcat         = table.concat
local utfchar             = utf.char
local texsprint           = tex.sprint

local C, Cg, Ct           = lpeg.C, lpeg.Cg, lpeg.Ct
local P, R, S, lpegmatch  = lpeg.P, lpeg.R, lpeg.S, lpeg.match

packagedata               = packagedata or { }
packagedata.pinyintones   = packagedata.pinyintones or { }
local pinyintones         = packagedata.pinyintones

-----------------------------------------------------------------------
---                           conversion
-----------------------------------------------------------------------

local toneno      = R"05"
local consonant   = S"bcdfghjklmnpqrstvwxyz" + S"BCDFGHJKLMNPQRSTVWXYZ"
local vowel       = S"aeiou" + S"AEIOU" + "ü" + "Ü"
local nucleus     = Ct(C(vowel)^1)
local syllable    = Cg((consonant^1)^-1, "onset")
                  * Cg(nucleus,          "nucleus")
                  * Cg((consonant^1)^-1, "coda")
                  * Cg(toneno^-1,        "tone")
local skip        = (1 - syllable)^1 --- keep this stuff
local pinyin      = Ct((Ct(syllable) + C(skip))^1)

local vowelpositions = function (nucleus)
  local tmp = { }
  for pos, vowel in next, nucleus do
    tmp[vowel] = pos
  end
  return tmp
end

local precedence = { "a", "e", "o" }

local cmacron = utfchar (0x0304)
local cacute  = utfchar (0x0301)
local ccaron  = utfchar (0x030c)
local cgrave  = utfchar (0x0300)

local todiacritic = function (str)
  -- print(str)
  local result   = { }
  local analyzed = lpegmatch (pinyin, str)
  --inspect (analyzed)
  for i = 1, #analyzed do
    local elm = analyzed[i]
    local t   = type (elm)

    if t == "table" then --- syllable
      local nucleus  = elm.nucleus
      local nvowels  = #nucleus
      local tone     = elm.tone
      if tone then
        tone = tonumber (tone)
      end

      if not tone then --- add unmodified
        result[#result+1] = elm.onset
        result[#result+1] = tableconcat (nucleus)
        result[#result+1] = elm.coda
      else
        local tonified
        if nvowels == 1 then --- single vowel receives tone
          local vowel = nucleus[1]
          if tone == 1 then --- inlined for performance
            tonified = vowel .. cmacron
          elseif tone == 2 then
            tonified = vowel .. cacute
          elseif tone == 3 then
            tonified = vowel .. ccaron
          elseif tone == 4 then
            tonified = vowel .. cgrave
          else
            tonified = vowel
          end

        elseif nvowels > 1 then
          local positions = vowelpositions (nucleus)
          local pos

          --- 1) locate correct vowel
          for j = 1, 3 do
            pos = positions[precedence[j]]
            if pos then
              break
            end
          end
          if not pos then -- iu or ui, thus second gets tone
            pos = 2
          end

          local vowel = nucleus[pos]

          --- 2) place tone mark
          if tone == 1 then
            nucleus[pos] = vowel .. cmacron
          elseif tone == 2 then
            nucleus[pos] = vowel .. cacute
          elseif tone == 3 then
            nucleus[pos] = vowel .. ccaron
          elseif tone == 4 then
            nucleus[pos] = vowel .. cgrave
          end

          tonified = tableconcat (nucleus)
        else --- no vowel, could be mismatch
          tonified = ""
        end
        result[#result+1] = elm.onset
        result[#result+1] = tonified
        result[#result+1] = elm.coda
      end

    elseif t == "string" then
      result[#result+1] = elm
    end

  end
  return tableconcat (result)
end

-----------------------------------------------------------------------
--- export
-----------------------------------------------------------------------

pinyintones.convert = function (str)
  local converted = todiacritic (str)
  -- print ("\n>>", str, converted)
  if converted then
    texsprint (converted)
  end
end

