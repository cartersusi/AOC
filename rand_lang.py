import random
import datetime

languages = [
    "Python",
    "Java",
    "C",
    "C++",
    "C#",
    "JavaScript",
    "Ruby",
    "Perl",
    "PHP",
    #"Go",
    "Swift",
    "Objective-C",
    "Rust",
    "TypeScript",
    "Lua",
    "Haskell",
    "Zig",
    #"Julia",
    "R",
    "Elixir",
    "Clojure",
    "Erlang",
    "Julia",
    "Lisp",
    "OCaml"
]
print(f"{datetime.datetime.now().strftime("%m-%d")} | Language: {random.choice(languages)}")