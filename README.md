# IRON
IRON a.k.a. Intermediate Representation Object Notation is a Interpreter/Database that is used to create Programming Languages.
IRON is entirely written in assembly, It is currently only compatible with Linux on 86-64 CPUs. 
Porting to MacOS and Windows is not a challenge and will be done in the near future, Although ARM will have to wait.

# How it is used
You create a database, then input source code into IRON and it will match that source code to the database and output the IR as specified.

# How it works
In normal Object Notations you match a key to a value by doing something akin to: 
"key": value
This is really slow, as it requires comparing an input with every single key until a match is found.
IRON has jump tables built into the database, which solves this issue.
For the uninformed, a jump table is essentially a list of destinations.
Ex:
option 1. destination

option 2. destination

option 3. destination

option 4. destination

Based on the input, a number 1-4 for will be generated, and then IRON will move to the destination for that specific option.
With the use of a jump table, IRON will only do 1 comparison in order to evaluate which option is picked.
While a naive, if else implementation would require a maximum of 4.

This naturally has a compounding effect when the destinations lead to more jump tables.

# Limitations
You can, more or less, create an entire programming language by solely using IRON, this comes at the caveat that you must use explicit types.
You can of course, make a program that reads the IR and determines if it is using the correct types and have it handle implicit types.
Or have the IR be in another programming language and have that programming language handle implicit types.
But I don't intend on adding in such functionality directly into IRON.

Although, IRON gives you a lot of control, so it may be possible to force it to consider implicit types.

This can be removed later on, but IRON removes "filler text" from the source code.
The filler words are, "as" "by" "is" "of" "or" "to" "so" "and" "for" "has" "the" "from" "into" "that" "with"
if you would like to use these words, simply remove this text from "iron_compiler.asm"

```
    mov rax, [input_size]
    mov [orignial_size], rax

    call delete_filler
```

Also IRON considers only Parenthesis "()" in the source code to be comments and will remove them. There are no comments in the database.
If you want to use parenthesis or want comments to be something else, 
change the "lefts" and "rights" variables in "filter_text.asm" to a ascii hexcode of your choice.

# Creating Databases
You make a script and IRON will remove all whitespace from it, compute the jump tables, and then IRON will use it as the database in the future.
The command for this is:

./iron factor script.txt database.txt

"script.txt" and "database.txt" can be anything you want.

To create the IR for source code, the command is:
./iron build source.txt database.txt output.txt

"source.txt", "database.txt" and "output.txt" can be anything you want.

# To Build IRON
You first need to install nasm, then use these commands in the folder you have downloaded the IRON source code into.

nasm -f elf64 iron_compiler.asm -o iron_compiler.o
nasm -f elf64 delete_filler.asm -o delete_filler.o
nasm -f elf64 filter_text.asm -o filter_text.o
nasm -f elf64 setup.asm -o setup.o
nasm -f elf64 clear_whitespace.asm -o clear_whitespace.o
ld iron_compiler.o delete_filler.o filter_text.o setup.o clear_whitespace.o -o iron

# Syntax
IRON intentionally uses one symbol per instruction for maximum performance.

Currently the existing jump tables are fairly basic, and more interoptabiltiy may be added in the future.

# "#"
"#" Used to indicate a jump table with 16 options, it considers the length of a source code word.
i.e.
If i were to write
```print "hello world" ```
and feed this into IRON, it would read "print" then it would determine the length is 5, and jump to the 5th option.

The "#" jump table currently requires that it must have exactly 16 options, and that each option is exactly 2 characters long.
Ex:
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

# "&"
This brings me to the next symbol, "&" is used to indicate a label.
You can only have a maximum of 16 letters per Label.

When "&" is read by IRON, it jumps to the next instance of that label, but with a "$" instead of a "&".
Ex:
```
&Print
$Print
```
IRON will jump from "&Print" to "$Print"

If you want to have multiple labels with the name, that is fine, IRON only cares about the closest label of the same name.

Jumps are precomputed, so you wont have to worry about searching for a string when building your source code.

When using "&" and "$" the "$" must always be below the "&" and never above it.
# ";"
If you want to jump to a "$" that is before a "&" instead of ahead, use ";" and ":" instead.
Ex:
```
;Print
:Print
```
IRON will jump from ":Print" to ";Print"

The maximum jump size currently has a 32 bit unsigned integer limit or 4,294,967,295. Which is effectively 4gb. 

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
"=" The equal sign is used to designate the next string to be outputted into the IR.
Ex:

`= Hello = World` Would print out: `Hello World`
IRON adds a space between every individual string that is outputted into the IR.

# "\"
to prevent this use a "\" backslash.
Ex:
`= Hello \ = World` Would print out: `HelloWorld`

Backslash doesn't just get rid of a space but the previous character that is outputted.
Ex:
`= Hello \ \` Would print out: `Hell`


IRON doesn't stop you from printing any of the symbols.
Ex:
`= = = &Print` Would print out: `= &Print`

# ","
this just adds a comma
Ex:
`= Hello , = World` Would print out: `Hello, World`

# "."
This is used to add a new line a.k.a. /n or 0x10 to the end of an command, and to begin the next command.
EX:
`= "Hello World" . = "Hello World"`
Outputs:
`Hello World`

at the end of "Hello World", the process returns back to the start of the database and searches for the word using the jump tables.

# "|"
if you want to add a new line but don't want to end the command use the vertical bar"|"

# "/"
if you want to end the command but don't want to add a new line use "/"

# "?"
"?" the question mark symbol compares the next string, with the current source code string.
The question mark will only compare the first 16 bytes of a string.
However, is no limit to the size of a string that can be outputted with "=".

If the strings match, the first option is selected, otherwise the second option is selected.
The "?" Must have exactly two options.

Ex:
`? Print &Print &Something_Else`
In this case, "&Print# is the first option and "&Something_Else" is the second option.

Talking about what exactly the question mark instruction does at the hardware level is important in order to use the following instructions correctly.

Firstly, the first word of a line of text is stored in a variable more or less.
The next word is being looked at in memory.

When IRON sees "?" it compares the word in the database to the word stored in a variable.
If they are a match, "?" copies the word that is being looked at in memory into the variable, then it looks at the next word in memory.
Using `Print "Hello World"` as an example:
Before:
`Variable: Print`
`Memory: "Hello World"`
Then:
`? Print &Print &Something_Else`
After:
`Variable: "Hello World"`
`Memory:`

If they are not a match, then IRON does not do that.

# "<" and "("
These two symbols both serve the same purpose, they each copy the location of a word in memory into distinct variables.
This does not affect the main Variable or the Memory word.

This is used to print this word into the IR output at a later time.

To print either Variable into IR, use the closing ">" or ")" respectively.

# "^"
"^" prints the word that is in memory then looks at the next word in memory.

This is database code that I have written as an example:
```
$t4-
? turn &turn &then

    $turn <
    ? 8bit &8bit &next
        $8bit = mov = byte > , ^ .
```
If the conditions are met it converts 
`turn 8bit param1 param2` 
into:
`mov byte param1, param2`

This may seem confusing at first, but i will outline what is happening at each step.
At: `$t4-`
`Variable: turn`
`Memory: 8bit`

At: `? turn &turn &then`
`Variable: 8bit`
`Memory: param1`

At: `$turn <`
`Variable: 8bit`
`2nd Variable: param1`
`Memory: param2`

At: `? 8bit &8bit &next`
`Variable: param1`
`2nd Variable: param1`
`Memory:param2`

Then it prints `mov byte` and then the first and second paramaters.
As you can see the 2nd variable holds the first param, and the memory is looking at the second one.

# "{" 
`[` stores a word that is in the database to another variable.
Ex:
`[ Hello`
`4th Variable: Hello`
The closing `}` prints that variable to the output.

# "["
`[` is used for storing a position in the database.
whenever the closing `]` is read, the database pointer jumps back to wherever the `[` was found.
This is used to create loops.
And there is nothing stopping you from making an infinite loop and having IRON crash your computer, so i would suggest not doing that.

# "+"
"+" loads the next word in memory to the main variable and looks at the next word in memory. It doesn't print anything out and is used to skip words.
I won't lie, the "+" is where this language becomes cursed and confusing, In the "Idiomatic IRON" section, I explain how to mitigate this complexity, but it is still a pain regardless.
Ex: "turn 8bit param1"
Before: "+"
`Variable: turn`
`Memory: 8bit`
After:
`Variable: 8bit`
`Memory: param1`

# "`" and "~"
Like the open and close pairs, the backtick represents open and "~" represents closed. There were no more sane ascii keys so I just picked these.
The back tick saves the source read pointer into a variable, and the tilde "~" moves the source memory pointer to the saved one.
So if you wanted to move back to a word after doing "+" you can do it with this.
Ex: "turn 8bit param1"
`Variable: turn`
`Memory: 8bit`
After: back tick
`Variable: turn`
`Memory: 8bit`
`Variable5: 8bit`
After: "+"
`Variable: 8bit`
`Memory: param1`
`Variable5: 8bit`
After: "~"
`Variable: 8bit`
`Memory: 8bit`
`Variable5: 8bit`

As you can probably tell this instruction can make the Memory and Main Variable Synchronized or even make the Main Variable be ahead of the memory pointer.
Which is not very good, because this will effect what the next Variable will be.

# "-"
This is similar to the "+" instruction except it only moves the read pointer forward and doesnt change the Main Variable.
This should only be used in conjunction with "~" if absolutely necessary. I can think of no reason as to why this should be used in any other situation.

# Idiomatic IRON
Quite frankly the phrase "Idiomatic IRON" is somewhat ironic since I have no intention of making the syntax readable.
But that is mainly due to the fact that most instructions cannot be represented intuitively by a single word, and because ascii symbols only take up 1 byte of space.

IRON doesnt care about whitespace and will delete any and all whitespace you have in your precompiled database.
But If you do not use whitespace in the very specific manner im about to show you, it becomes impossible to write anything in IRON.

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
`$label ? string &label1 &label2`
but this is good:
```
$label
? string &label1 &label2
```

Thats everything that the IRON compiler can do at the moment, I hope you will find it to be useful or insightful.
