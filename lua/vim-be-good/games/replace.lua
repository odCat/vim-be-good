local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")
local gameLineCount = 5

local instructions = {
    "Replace the word with copy",
    "",
    "e.g.",
    "",
    "tar bar COPY car           tar bar COPY car",
    "                     ->",
    "cor far REPLACE har        cor far COPY har",
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

    local noWords = 6
    local function genLine(wordCount, specialWord)
        local position = math.random(wordCount-1)
        local line = GameUtils.getRandomWord()
        local function inner(wordPos)
            for word = 1, wordCount-1 do

                if word == wordPos then
                    line = line .. " " .. specialWord
                else
                    line = line .. " " .. GameUtils.getRandomWord()
                end

            end

            return line
        end

        return inner(position)
    end

    local line1 = genLine(noWords, "COPY")
    local line2 = genLine(noWords, "REPLACE")

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)

    self.config = {
        roundTime = GameUtils.difficultyToTime[self.difficulty],
        lines = lines,
        expected = string.gsub(table.concat(lines, " "), "REPLACE", "COPY"),
    }

    return self.config
end


function ReplaceRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local trimmed = GameUtils.trimLines(lines)
    local concatenated = table.concat(GameUtils.filterEmptyLines(trimmed), " ")

    log.info("Replace:concateneted ", concatenated)
    log.info("Replace: expected    ", self.config.expected)

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
