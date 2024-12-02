import random
import subprocess

subprocess.run(["./zig-out/bin/christmas"])

neededfile = "langs/needed.txt"
donefile = "langs/done.txt"

def readfile(file):
    with open(file, "r") as f:
        return f.read().splitlines()
    
def writefile(file, data):
    with open(file, "w") as f:
        for line in data:
            f.write(line + "\n")

need = readfile(neededfile)
done = readfile(donefile)

choice = random.choice(need)
print(f"Today's Language: {choice}")

need.remove(choice)
done.append(choice)

writefile(neededfile, need)
writefile(donefile, done)