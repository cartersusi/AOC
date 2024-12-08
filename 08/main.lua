print("--- Day 8: Resonant Collinearity ---")

local inputfiles = {
    "data/example",
    "data/input",
}
local args = {...}
local fname = inputfiles[args[1]+1]

function FileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end

    return f ~= nil
end

function ReadFile(fpath)
    local res = {}
    for line in io.lines(fpath) do
        res[#res + 1] = line
    end

    return res
end

function PrintTable(t, head)
    local k = 5 if not head then k = #t end
    for i = 1, k do
        print(t[i])
    end
end

function PrintAntennas(m)
    for k, v in pairs(m) do
        for i = 1, #v do
            print(k, v[i][1], v[i][2])
        end
    end
end

function Antinodes(t, x, d)
    local da = {x[1] + d[1], x[2] + d[2]}
    if da[1] < 1 or da[1] > #t then return t end

    local ch = t[da[1]]:sub(da[2], da[2])
    if ch ~= "." then return t end
    print("Antinode: ", ch, da[1], da[2])

    -- wtf
    t[da[1]] = t[da[1]]:sub(1, da[2] - 1) .. "#" .. t[da[1]]:sub(da[2] + 1)

    return t
end

function Frequencies(t, c, l)
    for i = 1, #t do
        local r = t[i]
        for j = 1, #r do
            local ch = r:sub(j, j)
            local loc = {i, j}
            if ch ~= c then goto continue end
            if loc[1] == l[1] and loc[2] == l[2] then goto continue end

            local d = {l[1] - i, l[2] - j}
            -- Apply Diff to l
            t = Antinodes(t, l, d)
            -- Apply Diff to loc
            d = {-d[1], -d[2]}
            t = Antinodes(t, loc, d)

            ::continue::
        end
    end

    return t
end

function CountMat(t, ch)
    local count = 0
    for i = 1, #t do
        local r = t[i]
        for j = 1, #r do
            local c = r:sub(j, j)
            if c == ch then count = count + 1 end
        end
    end

    return count
end

assert(fname ~= nil, "No input file specified")
print("Using input file: " .. fname)

assert(FileExists(fname))
local t = ReadFile(fname)
assert(#t > 0)
PrintTable(t , true)

local antennas = {}
for i = 1, #t do
    local r = t[i]
    for j = 1, #r do
        local ch = r:sub(j, j)
        if ch == "." then goto continue end
        
        if antennas[ch] == nil then antennas[ch] = {} end
        local loc = {i, j}
        antennas[ch][#antennas[ch] + 1] = loc
        ::continue::
    end
end

PrintAntennas(antennas)

for k, v in pairs(antennas) do
    print("Antenna: ", k)
    for i = 1, #v do
        local loc = v[i]
        t = Frequencies(t, k, loc)
        print()
    end
end

PrintTable(t, false)
print("Count: ", CountMat(t, "#"))