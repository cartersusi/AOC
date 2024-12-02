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

function checker(y)
    if ranged(y, 1, 3) && ordered(y)
        return true
    end

    return false
end


safe = 0
open("input") do f
    line = 0

    while ! eof(f)
        sc = readline(f)
        x = split(sc)
        
        lfn = p -> parse(Int64, p)
        y = map(lfn, x)

        # Part 1
        #if checker(y)
            #global safe += 1
        #end

        if checker(y)
            global safe += 1
        else
            for i in eachindex(y)
                tmp = [y[1:i-1]; y[i+1:end]]
                if checker(tmp)
                    global safe += 1
                    break
                end
            end
        end
        
        line += 1
    end
end
println(safe)