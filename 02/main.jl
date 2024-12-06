function ordered(x::Array{Int64, 1})
    inc::Bool = x[2] > x[1]
    
    for i in 3:length(x)
        if inc != ((x[i] - x[i-1]) > 0)
            return false
        end
    end

    return true
end

function inrange(x::Array{Int64, 1}, low::Int64, high::Int64)
    for i in 2:length(x)
        d = abs(x[i-1] - x[i])

        if (d < low) || (d > high)
            return false
        end
    end

    return true
end

function checker(y)
    if inrange(y, 1, 3) && ordered(y)
        return true
    end

    return false
end


safe::Int64 = 0
open("input") do f
    n::Int64 = 0

    while ! eof(f)
        sc::String = readline(f)
        x::Array{String, 1} = split(sc)
        
        lfn = p -> parse(Int64, p)
        y::Array{Int64, 1} = map(lfn, x)

        # Part 1
        #if checker(y)
            #global safe += 1
        #end

        if checker(y)
            global safe += 1
            n += 1
            continue
        end
        
        for i in eachindex(y)
            tmp::Array{Int64, 1} = [y[1:i-1]; y[i+1:end]]
            if checker(tmp)
                global safe += 1
                break
            end
        end
        
        n += 1
    end
end
println(safe)