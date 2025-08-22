local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 5

local instructions = {
    "Replace the second word in uppercase with the first or switch the words",
    "",
    "e.g.",
    "",
    "car car BAR car     ->    car car BAR car",
    "cor FAR cor cor           cor BAR cor cor",
    "",
    "car car BAR car     ->    car car SWI car",
    "cor SWI cor cor           cor BAR cor cor",
    "",
    "----------------------------------------------------------------------",
    "",
}


local ReplaceRound = {}
function ReplaceRound:new(difficulty, window)
    log.info("NewReplace", difficulty, window)

    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    return setmetatable(round, self)
end


function ReplaceRound:name()
    return "surround"
end


function ReplaceRound:getInstructions()
    return instructions
end


function ReplaceRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])

    local function genLine(wordCount, specialWord)
        local position = math.random(wordCount)
        local staticWord = GameUtils.getRandomWord()
        while staticWord == specialWord do
            staticWord = GameUtils.getRandomWord()
        end
        local line = position == 1 and specialWord or staticWord

        local function inner(wordPos)

            for word = 2, wordCount do
                if word == wordPos then
                    line = line .. " " .. specialWord
                else
                    line = line .. " " .. staticWord
                end
            end

            return line
        end

        return inner(position)
    end

    local noWords = 6
    local switch = "SWI"
    local firstWord
    if math.random(4) == 4 then
        firstWord = switch
    else
        firstWord = GameUtils.getRandomWord():upper()
    end
    local secondWord = GameUtils.getRandomWord():upper()
    while firstWord == secondWord do
        secondWord = GameUtils.getRandomWord():upper()
    end
    if math.random(3) == 3 then
        firstWord = firstWord .. "." .. firstWord
        secondWord = secondWord .. "." .. secondWord
    end

    local line1 = genLine(noWords, firstWord)
    local line2 = genLine(noWords, secondWord)

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)

    local expected
    if string.find(firstWord, switch) then
        expected = string.gsub(table.concat(lines, " "), secondWord, firstWord)
        expected = string.gsub(expected, firstWord, secondWord, 1)
    else
        expected = string.gsub(table.concat(lines, " "), secondWord, firstWord)
    end

    log.info("Config:Replace " .. table.concat(lines))
    log.info("Config:Replace " .. expected)

    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
        lines = lines,
        expected = expected,
    }

    return self.config
end


function ReplaceRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), " ")

    log.info("ReplaceRound:checkForWin", vim.inspect(concatenated))
    log.info("ReplaceRound:expected   ", self.config.expected)

    local winner = concatenated == self.config.expected

    if winner then
        vim.cmd("stopinsert")
    end

    return winner
end


function ReplaceRound:render()
    local lines = GameUtils.createEmpty(gameLineCount)

    local cursorLine = 4

    lines[4] = self.config.lines[1]
    lines[5] = self.config.lines[2]

    return lines, cursorLine
end

return ReplaceRound
