# IRON
IRON a.k.a. Intermediate Representation Object Notation is a Interpreter/Database that is used to create Programming Languages.
It can compile source code into IR at 6.3 million lines of code per second.

IRON is entirely written in assembly, It is currently only compatible with Linux on 86-64 CPUs. 
Porting to MacOS and Windows is not a challenge and will be done in the near future, Although ARM CPU's and such will have to wait.

# Stats
It takes roughly 1,569,451 nano seconds to convert 10,000 lines of source code into IR.

10,000 ÷ 0.001569451 = 6,371,658.86 or 6.3 million LOC/s 

# What is IR
Intermediate Representation, is essentially a lower level form of code. 
If a compiler converts your code into assembly before compiling it into machine code, then Assembly would be the IR for your code.

# How it is used
You create a database, then input source code into IRON and it will match that source code to the database and output the IR as specified.

# How it works
In normal Object Notations you match a key to a value by doing something akin to: 
"key": value
This is really slow, as it requires comparing an input with every single key until a match is found.
IRON has jump tables built into the database, which solves this issue.
For the uninformed, a jump table is essentially a list of destinations.
Ex:
```
option 1. destination
option 2. destination
option 3. destination
option 4. destination
```
Based on the input, a number 1-4 for will be generated, and then IRON will move to the destination for that specific option.
With the use of a jump table, In this example, IRON will only do 1 comparison in order to evaluate which option is picked.
While a naive, if else implementation would require a maximum of 4.

This naturally has a compounding effect when the destinations lead to more jump tables. Which allows for extremely low lookup times in large databases.

# Limitations
Currently IRON does not allow for the implementation of type checking, this is planned to be introduced in future updates. 
Along with error handling and such.

This can be stopped, but IRON deletes "filler text" from source code.
The filler words are, "as" "by" "is" "of" "or" "to" "so" "and" "for" "has" "the" "from" "into" "that" "with"
if you would like to use these words, simply remove this text from "iron_compiler.asm"

```
    mov rax, [input_size]
    mov [orignial_size], rax

    call delete_filler
```

Also IRON considers Parenthesis "()" in the source code to be comments and will remove them.
If you want to use parenthesis or want comments to be something else, 
change the "lefts" and "rights" variables in "filter_text.asm" to a ascii hexcode of your choice.

# Creating Databases
You make a script and IRON will remove all whitespace from it, compute the jump tables, and then IRON can use it as a database in the future.
The command for this is:
```
./iron factor script.txt database.txt
```
"script.txt" is the input and "database.txt" is the output, the names can be anything.

To create the IR for source code, the command is:
```
./iron build source.txt database.txt output.txt
```
"source.txt" is the input source code, "database.txt" is the database and "output.txt" is the outputted IR, the names can be anything.

# To Build IRON
You first need to install nasm, then use these commands in the folder you have downloaded the IRON source code into, run these commands in the terminal.
```
nasm -f elf64 iron_compiler.asm -o iron_compiler.o
nasm -f elf64 delete_filler.asm -o delete_filler.o
nasm -f elf64 filter_text.asm -o filter_text.o
nasm -f elf64 setup.asm -o setup.o
nasm -f elf64 clear_whitespace.asm -o clear_whitespace.o
ld iron_compiler.o delete_filler.o filter_text.o setup.o clear_whitespace.o -o iron
```

# Examples
If you would like to see a working example of IRON in practice check out the example.MD in the examples folder.

# Syntax
IRON intentionally uses one symbol per instruction for minimum file size.

# "#"
"#" Used to indicate a jump table with 16 options, it considers the length of a source code word.
i.e.
If i were to write
```
print "hello world"
```
and feed this into IRON, it would read "print" then it would determine the length is 5, and jump to the 5th option.

The "#" jump table currently requires that it must have exactly 16 options, and that each option is exactly 2 characters long.
Ex:
```
#
&0
&1
&2
&3
&4
&5
&6
&7
&8
&9
&A
&B
&C
&D
&E
&F
```

# "_"
The "_" jump table requires that each label below it is exactly 2 characters long, it can have up to a maximum of 16 options. 
It can have any number of options between 1-16.
it compares the first letter in the word to the provided string of letters and jumps accordingly.

Ex:
```
_ abcdef789213
&a
&b
&c
&d
&e
&f
&7
&8
&9
&2
&1
&3
&error
```
it can take any number or symbol, if the letter is not within the provided string it will jump to the very end of the list, i.e. where the "&error" label is currenty located.

# "&"
This brings me to the next symbol, "&" is used to indicate a label.
You can only have a maximum of 16 letters per Label.

When "&" is read by IRON, it jumps to the next instance of that label, but with a "$" instead of a "&".
Ex:
```
&Print
...
$Print
```
In this example, IRON will jump from "&Print" to "$Print"

$Print is considered the end point for &Print, i.e. the location that is jumped to when "&Print" is read.

If you want to have multiple labels with the name, that is fine, IRON only cares about the closest label of the same name.

Jumps are precomputed, so IRON does not search for string during the compilation of source code. 
Only when factoring the database does IRON match labels to their end points.

The maximum jump size currently has a 32 bit unsigned integer limit or 4,294,967,295. Which is effectively 4gb. 

When using "&" and "$" the "$" must always be below the "&" and never above it.
# ";"
If you want to jump to a "$" that is before a "&" instead of ahead, use ";" and ":" instead.
Ex:
```
;Print
:Print
```
IRON will jump from ":Print" to ";Print"

# "!"
The exclamation mark "!" is used to indicate undefined behavior, if IRON reads this symbol, it will stop and return an error.

# "@" 
"@" is another jump table, but this one must have exactly 26 options. 
It takes the first letter of the word, and jumps to the corresponding table representing that letter.
Each option must be exactly 4 letters long.

Ex:
`&a1-`

The "-" is used to fulfill the 4 letter requirement and doesnt serve any other purpose.

# "="
"=" The equal sign is used to indicate the string ahead of the "=" in the database is to be outputted from the database into the IR.
Ex:

```
= Hello = World
``` 
Would print out: 
```
Hello World
```
IRON adds a space between every individual string that is outputted into the IR.

# -
to prevent this use a "-" minus.
Ex:
```
= Hello - = World
``` 
Would print out: 
```
HelloWorld
```

Minus doesn't just get rid of a space but the previous character that is outputted.
Ex:
```
= Hello - -
``` 
Would print out: 
```
Hell
```
# "+"
a plus does the opposite of minus and adds a space.

IRON doesn't stop you from printing anything out.
Ex:
```
= = = &
``` 
Would print out: 
```
= &
```
Its okay to print symbols by themselves but do not print out a label, i.e. 
Not okay:`= &print`
Okay:`= & - = print`

# ","
this just adds a comma
Ex:
```
= Hello , = World
```
Would print out: 
```
Hello, World
```
# "."
This is used to add a new line a.k.a. /n or 0x10 to the end of an command, and to begin the next command.
EX:
```
= "Hello World" . = "Hello World"
```
Outputs:
```
"Hello World"
```
At the end of "Hello World", the process returns back to the start of the database and searches for the word using the jump tables.
So the second instruction is ignored.

# "|"
if you want to add a new line but don't want to end the command use the vertical bar "|"

# "/"
if you want to end the command but don't want to add a new line use "/"

# "?"
"?" the question mark symbol compares the next string, with the string inside of the register.
The question mark will only compare the first 16 bytes of a string.
However, is no limit to the size of a string that can be outputted with "=".

If the strings match, the first option is selected, otherwise the second option is selected.
The "?" Must have exactly two options.

Ex:
```
? Print &Print &Something_Else
```
In this case, "&Print" is the "if string is print" option and "&Something_Else" is the "if string is not print" option.

# "^"
"^" prints the word that is in the source code file then jumps to the next word in the source code file.

# "*"
"*" stores the word in the source code file to the register and jumps to the next word in the source code file. 
It doesn't print anything out and is used to skip words.
Ex: "turn 8bit param1"
Before: "+"
```
Register: turn
Source Code Word: 8bit
```
After: "+"
```
Register: 8bit
Source Code Word: param1
```

# "<" and "("
These two symbols both serve the same purpose, they each store the current Source Code Word into memory.
This does not affect the Register or the Source Code Word.

To print either Variable into the output, use the closing ">" or ")" respectively.
This is used to save a word in the Source Code for later.

This is database code that I have written as an example:
```
$t4-
? turn &turn &then

    $turn *
    ? 8bit &8bit &next
        $8bit = mov = byte ^ , ^ .
```
If the conditions are met it converts 
```
turn 8bit param1 param2
``` 
into:
```
mov byte param1, param2
```

This may seem confusing at first, but i will outline what is happening at each step.
At: `$t4-`
```
Register: turn
Source Code Word: 8bit
```
It jumped from the jump table at the start of the database to here.

At: `? turn &turn &then`
it resolves to true and jumps to $turn

At: $turn *
```
Register: 8bit
Stored Word: param1
Source Code Word: param2
```

At: `? 8bit &8bit &next`
it resolves to true and jumps to $8bit

Then it prints `mov byte` and then the first and second paramaters.



# "{" 
`{` stores a word in the database into memory to be outputted into IR later.
Ex:
```
{ Hello
4th Variable: Hello
```
The closing `}` prints that variable to the output.

# "["
`[` is used for storing a position in the database.
whenever the closing `]` is read, the database pointer jumps back to wherever the `[` was found.
This is used to create loops.
And there is nothing stopping you from making an infinite loop, so I would suggest avoiding that.

# "`" and "~"
Like the previous open and close pairs, the backtick represents open and the tilde represents closed.
The back tick saves the source read pointer into a variable, and the tilde moves the source memory pointer to the saved one.
So if you wanted to move back to a word after doing "*" you can do it with this.
Ex: "turn 8bit param1"
```
Variable: turn
Memory: 8bit
```
After: back tick
```
Variable: turn
Memory: 8bit
Variable5: 8bit
```
After: "*"
```
Variable: 8bit
Memory: param1
Variable5: 8bit
```
After: "~"
```
Variable: 8bit
Memory: 8bit
Variable5: 8bit
```

# Idiomatic IRON
Quite frankly the phrase "Idiomatic IRON" is somewhat ironic since I have no intention of making the syntax readable.
But that is mainly due to the fact that most instructions cannot be represented intuitively by a single word, and because ascii symbols only take up 1 byte of space.

IRON doesnt care about whitespace and will delete any and all whitespace you have in your precompiled database. 
The following whitespace guidline is purely for clarity and isn't required.

That is, for every label1 in a: 
`? string &label1 &label2`
the end point must always be a tab or 4 spaces ahead of the "?"
i.e.
```
? string &label1 &label2
    $label1
```
And for every label2 the end point must always be on the same level as the "?"
i.e.
```
? string &label1 &label2
    $label1
$label2
```

every "?" must be on a new line, and can't be on the same line as something before it.

i.e. this is bad:
```
$label ? string &label1 &label2
```
but this is good:
```
$label
? string &label1 &label2
```

Thats everything that the IRON compiler can do at the moment, I hope you will find it to be useful or insightful.
