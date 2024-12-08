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

function PrintTable(x, head)
    local k = 5 if not head then k = #x end
    for i = 1, k do
        print(x[i])
    end
end

assert(fname ~= nil, "No input file specified")
print("Using input file: " .. fname)

assert(FileExists(fname))
local x = ReadFile(fname)
assert(#x > 0)
PrintTable(x , true)