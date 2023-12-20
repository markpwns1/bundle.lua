local ALPHABET_ANIMALS = {
    "AARDVARK",
    "BEAR",
    "CAMEL",
    "DINGO",
    "ELEPHANT",
    "FLAMINGO",
    "GORILLA",
    "HIPPO",
    "IGUANA",
    "JACKAL",
    "KANGAROO",
    "LEMUR",
    "MONKEY",
    "NARWHAL",
    "OCTOPUS",
    "PENGUIN",
    "QUAIL",
    "RABBIT",
    "SNAKE",
    "TIGER",
    "UNICORN",
    "VULTURE",
    "WHALE",
    "YAK",
    "ZEBRA"
}

local function select_animal(i)
    return ALPHABET_ANIMALS[math.fmod(i, #ALPHABET_ANIMALS + 1)] or "SANTA CLAUS"
end

local function generate_animal_hash()
    return select_animal(os.date("%H") + os.date("%M")) .. " <3 " .. select_animal(os.date("%H") + os.date("%S"))
end

return generate_animal_hash
