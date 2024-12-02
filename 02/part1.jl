function ordered(x)
    inc = false
    
    for i in eachindex(x)
        if i == 1 # Last time using julia
            continue
        end
        l = x[i-1]
        r = x[i]
        d = (l - r)

        if i == 2
            inc = (d > 0)
            continue
        end

        if inc != (d > 0)
            return false
        end
    end

    return true
end

function ranged(x, low, high)
    for i in eachindex(x)
        if i == 1
            continue
        end
        l = x[i-1]
        r = x[i]
        d = (l - r)
        if d < 0
            d = -d
        end

        if (d < low) || (d > high)
            return false
        end
        
    end

    return true
end

function checker(x)
    lfn = p -> parse(Int64, p)
    y = map(lfn, x)

    if ranged(y, 1, 3) && ordered(y)
        return 1
    end

    return 0
end


safe = 0
open("input") do f
    line = 0

    while ! eof(f)
        sc = readline(f)
        x = split(sc)
        
        global safe += checker(x)
        
        line += 1
    end
end
println(safe)