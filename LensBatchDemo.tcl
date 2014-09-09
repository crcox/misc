# The follow is a basic and heavily annotated script for running a "batch"
# process with lens. A batch process is one that does not utilize the graphic
# user interface (GUI). This is done to aid in automation and replication of
# your analysis, and to exert additional control that you might not have
# through the GUI. It is not necessary for the course, but some of your may be
# inclined to explore lens from this angle. The following runs the XOR example
# network that is bundled with lens. It was writting on my own MacBook, and
# certain things, such as the paths at the very beginning of the script, may
# need to be updated for your own machine and system environment.
#
# Make sure to make heavy use of the Lens manual:
# http://tedlab.mit.edu/~dr/Lens/
#
# and specifically the command reference is very helpful.
# http://tedlab.mit.edu/~dr/Lens/Commands/topical.html
#
# If you really start to dig deep, you'll find yourself pouring over this page, also:
# http://tedlab.mit.edu/~dr/Lens/progStructures.html

set examplePath [file join /Applications LensOSX.app Contents MacOS examples]
set ExFile [file join $examplePath xor.ex]
set InFile [file join $examplePath xor.in]

puts $ExFile
puts $InFile

# This next line runs the entire .in file and sets up the network. This is
# where things really get going.
source $InFile

# We can now load the training examples that go along with this network.
# Notice that this time we are using a lens-specific command, "loadExamples"
# http://tedlab.mit.edu/~dr/Lens/Commands/loadExamples.html
# Notice that we give it a file to read (ExFile) and then give the contents of
# that file a name within lens (-set TrainSet).
loadExamples $ExFile -set TrainSet

# Next, we are going to tell lens how to read through this list of examples we
# just told lens to store in TrainSet. PERMUTED means it will sample randomly
# WITHOUT replacement---it will shuffle the items, read the shuffled list from
# top to bottom, and then shuffle the list again before making another pass
# over the list.
exampleSetMode TrainSet PERMUTED

# When you TRAIN the network, that causes the weights to update. It is also
# important to evaluate what the model knows, without introducing any changes
# to the network. This is done by TESTING it. If you want to TEST the network, you
# will need to repeat the steps above. You can use the same example file or a
# different one, but you MUST -set to a different name, otherwise lens will
# think you want to REPLACE the list you loaded before. Reading the same
# information into lens twice under different names might sound strange, but it
# will let you handle these sets differently without needing to constantly
# switch attributes back and forth for when you want to train and test, for
# example.
loadExamples $ExFile -set TestSet

# Now we can tell lens when we use the TestSet, we should loop over the items
# in the order they appeared in the ex file. This is very important---if you
# ever want to write out data about individual items, it is much easier to
# interpret that output if things are in the order you expect!
exampleSetMode TestSet ORDERED

# There is one more step in setting up the training and test sets. And that is:
# actually tell lens which should be used for training and which should be used
# for testing! Although we told lens to call the first thing we loaded
# "TrainSet" and the second "TestSet" THOSE WERE JUST ARBITRARY LABELS. Lens
# does not interpret those labels or read into them whatsoever. It just tells
# lens how to find that information. For lens to know something is training
# set, you need to be explicit with the following function:
useTrainingSet TrainSet

# Same goes for the test set:
useTestingSet TestSet

# Now, if you tell lens to "train", it will run through TrainSet in PERMUTED
# order, and if you tell lens to "test" it will run through TestSet in ORDERED
# order---that is, the order specified in the .ex file.

# resetNet randomizes all the weights, clears the error and activation history,
# etc. It makes sure your are starting fresh.
resetNet

# train is like pressing the train button in the GUI. This means that it will
# run for as many iterations as are specified. Where is this information
# specified? If you do not specify anything, you will be running with lens's
# built in defaults. In this case, this, and a lot of other information, was
# specified in xor.in, which we sourced way back at the beginning. Have a look
# through that file to see how it was done!
train

# From here until the end is ONE strategy for writing out activation values
# from the model. By adding these extra flags to your groups of interest (lens
# refers to these flags as "types"), you are prepping them for writing. I
# probably would have specified this line closer to the top, but this is not
# the only way to write data out of a network, and it may not be the way Tim
# teaches, so I want to downplay it a little.
changeGroupType {hidden output} +USE_OUTPUT_HIST +USE_TARGET_HIST +WRITE_OUTPUTS

# With that step of setup handled, you can open an output file for writing. If
# you call it with the append flag, then it will add more output to a file
# witout overwriting it. In this case, since we are only opening and closing
# the output file once, we do not need to -append. But, if you were training
# and testing repeatedly, then you would want to use append.
openNetOutputFile foo.out -append

# Now when we run "test", all of the network activation from the hidden and
# output layers will be written to the file "foo.out". The important thing to
# keep in mind, is that after opening the output file, EVERY time lens
# processes an example, it will also write to the file. So, if you opened the
# output file and then issued the train command, and lens was set to train for
# 100000 iterations, you just wrote to the file 10000 times. This may or may
# not be what you want.
test

# So, there is also the closeNetOutputFile command. After running this, writing
# to the file will stop. But, you can start it up again by calling
# openNetworkOutputFile with the -append flag---IF YOU FORGET THE APPEND FLAG,
# you will OVERWRITE all the previous data the next time you openNetOutputFile.
# Yikes.
closeNetOutputFile

# If you go look at foo.out, your first thought is probably going to be "WTF?!
# Lens is stoopid." While I sympathize, there is actually a very logical method
# to the apparent madness. See http://tedlab.mit.edu/~dr/Lens/outputFiles.html
# for an explanation for how to parse this output. Again, this may not be how
# you want to handle writing activations to file, and Tim will probably offer
# other solutions. But this is one way.
#
# Now you have the basics! For the intrepid, note that this is nothing more
# than a script written in the tcl programming language, which takes advantage
# of some functionality that comes with lens. That means you can script out
# quite elaborate procedures, and exert a great deal of control. Becoming
# familiar with tcl and all the inner workins of lens is NOT, and I repeat:
# NOT!!! essential to doing well in this course. These are just tools at your
# disposal. It is possible to go a very long way with the GUI. But there are
# some things you just won't be able to do easily without a little
# programming...
# - Chris
#
# PS: If you are a trve masochist, you can even write your own extensions to
# lens in C. For example, if you do not like how lens handles writing to a file
# by default, you could modify or replace that function with "minimal" effort
# (assuming you know C...). Lens was written to be very extensible. So if
# that's your jam, have at it! To get started down this dark path:
# http://tedlab.mit.edu/~dr/Lens/progCode.html Note especially extension.h and
# extension.c
